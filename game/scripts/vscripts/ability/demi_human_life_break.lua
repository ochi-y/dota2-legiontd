-- Created by Elfansoer
--[[
Ability checklist (erase if done/checked):
- Break behavior
- Spell Immune/Invulnerable/Invisible behavior
- Illusion behavior
- Stolen behavior
]]
--------------------------------------------------------------------------------
demi_human_life_break = class({})
LinkLuaModifier("modifier_demi_human_life_break", "ability/demi_human_life_break", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_demi_human_life_break_buff", "ability/demi_human_life_break", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_demi_human_life_break_debuff", "ability/demi_human_life_break", LUA_MODIFIER_MOTION_NONE)
local tempTable = require("utils/tempTable")
--------------------------------------------------------------------------------
-- Custom KV
function demi_human_life_break:GetCooldown(level)
	return self.BaseClass.GetCooldown(self, level)
end

-- --------------------------------------------------------------------------------
-- -- Ability Cast Filter
-- function demi_human_life_break:CastFilterResultTarget( hTarget )
-- 	if self:GetCaster() == hTarget then
-- 		return UF_FAIL_CUSTOM
-- 	end

-- 	local nResult = UnitFilter(
-- 		hTarget,
-- 		DOTA_UNIT_TARGET_TEAM_BOTH,
-- 		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
-- 		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
-- 		self:GetCaster():GetTeamNumber()
-- 	)
-- 	if nResult ~= UF_SUCCESS then
-- 		return nResult
-- 	end

-- 	return UF_SUCCESS
-- end

-- function demi_human_life_break:GetCustomCastErrorTarget( hTarget )
-- 	if self:GetCaster() == hTarget then
-- 		return "#dota_hud_error_cant_cast_on_self"
-- 	end

-- 	return ""
-- end

--------------------------------------------------------------------------------
-- Ability Start
function demi_human_life_break:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	-- load data
	local duration = 5

	-- add modifiers
	local tgt = tempTable:AddATValue(target)
	caster:AddNewModifier(
		caster,                     -- player source
		self,                       -- ability source
		"modifier_demi_human_life_break", -- modifier name
		{
			target = tgt,
		} -- kv
	)
	caster:AddNewModifier(
		caster,                          -- player source
		self,                            -- ability source
		"modifier_demi_human_life_break_buff", -- modifier name
		{ duration = duration }          -- kv
	)

	-- play effects
	local sound_cast = "Hero_Huskar.Life_Break"
	EmitSoundOn(sound_cast, caster)
end

--------------------------------------------------------------------------------
-- function demi_human_life_break:PlayEffects()
-- 	-- Get Resources
-- 	local particle_cast = "particles/units/heroes/hero_heroname/heroname_ability.vpcf"
-- 	local sound_cast = "string"

-- 	-- Get Data

-- 	-- Create Particle
-- 	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_NAME, hOwner )
-- 	ParticleManager:SetParticleControl( effect_cast, iControlPoint, vControlVector )
-- 	ParticleManager:SetParticleControlEnt(
-- 		effect_cast,
-- 		iControlPoint,
-- 		hTarget,
-- 		PATTACH_NAME,
-- 		"attach_name",
-- 		vOrigin, -- unknown
-- 		bool -- unknown, true
-- 	)
-- 	ParticleManager:SetParticleControlForward( effect_cast, iControlPoint, vForward )
-- 	SetParticleControlOrientation( effect_cast, iControlPoint, vForward, vRight, vUp )
-- 	ParticleManager:ReleaseParticleIndex( effect_cast )

-- 	-- Create Sound
-- 	EmitSoundOnLocationWithCaster( vTargetPosition, sound_location, self:GetCaster() )
-- 	EmitSoundOn( sound_target, target )
-- end



--------------------------------------------------------------------------------
modifier_demi_human_life_break = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_demi_human_life_break:IsHidden()
	return false
end

function modifier_demi_human_life_break:IsDebuff()
	return false
end

function modifier_demi_human_life_break:IsStunDebuff()
	return false
end

function modifier_demi_human_life_break:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_demi_human_life_break:OnCreated(kv)
	-- references
	self.speed           = self:GetAbility():GetSpecialValueFor("charge_speed")
	self.duration        = self:GetAbility():GetSpecialValueFor("duration")
	self.boss_damage_pct = self:GetAbility():GetSpecialValueFor("boss_damage_pct")

	self.damage_pct      = self:GetAbility():GetSpecialValueFor("health_damage") / 100

	self.cost_pct        = self:GetAbility():GetSpecialValueFor("health_cost_percent") / 100

	self.close_distance  = 80
	self.far_distance    = 1450

	if IsServer() then
		self.target = tempTable:RetATValue(kv.target)

		-- basic purge
		self:GetParent():Purge(false, true, false, false, false)

		-- try apply
		if self:ApplyHorizontalMotionController() == false then
			self:Destroy()
		end
	end
end

function modifier_demi_human_life_break:OnRefresh(kv)

end

function modifier_demi_human_life_break:OnRemoved()
end

function modifier_demi_human_life_break:OnDestroy()
	if IsServer() then
		-- IMPORTANT: this is a must, or else the game will crash!
		self:GetParent():InterruptMotionControllers(true)

		-- destroy buff
		local modifier = self:GetParent():FindModifierByNameAndCaster("modifier_demi_human_life_break_buff",
			self:GetParent())
		if modifier then
			modifier:Destroy()
		end

		if not self.success then return end

		-- percentage enemy damage

		local enemyDamage = self.damage_pct * self.target:GetHealth()

		if self.target:IsAncient() then
			enemyDamage = self.boss_damage_pct * self.target:GetHealth()/100
		end

		local damageTable = {
			victim = self.target,
			attacker = self:GetCaster(),
			damage = enemyDamage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self:GetAbility(), --Optional.
			damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
		}
		ApplyDamage(damageTable)

		-- percentage self damage
		damageTable.victim = self:GetCaster()
		damageTable.damage = self.cost_pct * self:GetCaster():GetHealth()
		damageTable.damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL
		ApplyDamage(damageTable)

		local duration = self.duration

		duration = duration * (1 - CalUnitStatusResistance(self.target))
		-- apply debuff
		self.target:AddNewModifier(
			self:GetCaster(),               -- player source
			self:GetAbility(),              -- ability source
			"modifier_demi_human_life_break_debuff", -- modifier name
			{ duration = duration }         -- kv
		)
		-- play effects
		self:PlayEffects()
	end
end

--------------------------------------------------------------------------------
-- Status Effects
function modifier_demi_human_life_break:CheckState()
	local state = {
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_DISARMED] = true,
	}

	return state
end

--------------------------------------------------------------------------------
-- Motion Effects
function modifier_demi_human_life_break:UpdateHorizontalMotion(me, dt)
	local origin = self:GetParent():GetOrigin()

	if not self.target:IsAlive() then
		self:EndCharge(false)
	end

	-- get direction
	local direction = self.target:GetOrigin() - origin
	direction.z = 0
	local distance = direction:Length2D()
	direction = direction:Normalized()

	-- stop if close to target
	if distance < self.close_distance then
		self:EndCharge(true)
	elseif distance > self.far_distance then
		self:EndCharge(false)
	end

	-- move towards direction
	local target = origin + direction * self.speed * dt
	self:GetParent():SetOrigin(target)

	-- face towards target
	self:GetParent():FaceTowards(self.target:GetOrigin())
end

function modifier_demi_human_life_break:OnHorizontalMotionInterrupted()
	self:Destroy()
end

function modifier_demi_human_life_break:EndCharge(success)
	-- cancel debuff if linken
	if success and (not self.target:TriggerSpellAbsorb(self:GetAbility())) then
		self.success = true
	end
	self:Destroy()
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_demi_human_life_break:PlayEffects()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_huskar/huskar_life_break.vpcf"
	local sound_target = "Hero_Huskar.Life_Break.Impact"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.target)
	ParticleManager:SetParticleControl(effect_cast, 1, self.target:GetOrigin())
	ParticleManager:ReleaseParticleIndex(effect_cast)

	-- Create Sound
	EmitSoundOn(sound_target, self.target)
end

modifier_demi_human_life_break_buff = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_demi_human_life_break_buff:IsHidden()
	return true
end

function modifier_demi_human_life_break_buff:IsDebuff()
	return false
end

function modifier_demi_human_life_break_buff:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_demi_human_life_break_buff:OnCreated(kv)
end

function modifier_demi_human_life_break_buff:OnRefresh(kv)
end

function modifier_demi_human_life_break_buff:OnRemoved()
end

function modifier_demi_human_life_break_buff:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
-- function modifier_demi_human_life_break_buff:DeclareFunctions()
-- 	local funcs = {
-- 		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
-- 		MODIFIER_EVENT_ON_ATTACKED,
-- 	}

-- 	return funcs
-- end

--------------------------------------------------------------------------------
-- Status Effects
function modifier_demi_human_life_break_buff:CheckState()
	local state = {
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_DISARMED] = true,
	}

	return state
end

modifier_demi_human_life_break_debuff = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_demi_human_life_break_debuff:IsHidden()
	return false
end

function modifier_demi_human_life_break_debuff:IsDebuff()
	return true
end

function modifier_demi_human_life_break_debuff:IsStunDebuff()
	return false
end

function modifier_demi_human_life_break_debuff:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_demi_human_life_break_debuff:OnCreated(kv)
	-- references
	self.slow = self:GetAbility():GetSpecialValueFor("movespeed")
end

function modifier_demi_human_life_break_debuff:OnRefresh(kv)

end

function modifier_demi_human_life_break_debuff:OnRemoved()
end

function modifier_demi_human_life_break_debuff:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_demi_human_life_break_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}

	return funcs
end

function modifier_demi_human_life_break_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_demi_human_life_break_debuff:GetStatusEffectName()
	return "particles/status_fx/status_effect_huskar_lifebreak.vpcf"
end
