-- Created by Elfansoer
--[[
Ability checklist (erase if done/checked):
- Scepter Upgrade
- Break behavior
- Linken/Reflect behavior
- Spell Immune/Invulnerable/Invisible behavior
- Illusion behavior
- Stolen behavior
]]
--------------------------------------------------------------------------------
barrack_blood_rush = class({})
LinkLuaModifier("modifier_barrack_blood_rush", "ability/barrack_blood_rush", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_barrack_blood_rush_tag", "ability/barrack_blood_rush", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_barrack_blood_rush_buff", "ability/barrack_blood_rush", LUA_MODIFIER_MOTION_NONE)


--------------------------------------------------------------------------------
-- Ability Start
function barrack_blood_rush:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	-- load data
	local duration = self:GetSpecialValueFor("duration")
	local duration_boss = self:GetSpecialValueFor("duration_boss")
	if target:IsAncient() then
		duration = duration_boss
	end
	-- add buff
	target:AddNewModifier(
		caster,                       -- player source
		self,                         -- ability source
		"modifier_barrack_blood_rush_buff", -- modifier name
		{ duration = duration }       -- kv
	)

	-- play effects
	self:PlayEffects(target)
end

--------------------------------------------------------------------------------
function barrack_blood_rush:PlayEffects(target)
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_ogre_magi/ogre_magi_bloodlust_cast.vpcf"
	local sound_cast = "Hero_OgreMagi.Bloodlust.Cast"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		self:GetCaster(),
		PATTACH_POINT_FOLLOW,
		"attach_attack1",
		Vector(0, 0, 0), -- unknown
		true     -- unknown, true
	)
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		2,
		self:GetCaster(),
		PATTACH_POINT_FOLLOW,
		"attach_attack1",
		Vector(0, 0, 0), -- unknown
		true     -- unknown, true
	)
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		3,
		target,
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0, 0, 0), -- unknown
		true     -- unknown, true
	)
	ParticleManager:ReleaseParticleIndex(effect_cast)

	-- Create Sound
	EmitSoundOn(sound_cast, self:GetCaster())
end

-- Created by Elfansoer
--[[
Ability checklist (erase if done/checked):
- Scepter Upgrade
- Break behavior
- Linken/Reflect behavior
- Spell Immune/Invulnerable/Invisible behavior
- Illusion behavior
- Stolen behavior
]]
--------------------------------------------------------------------------------
modifier_barrack_blood_rush = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_barrack_blood_rush:IsHidden()
	return true
end

function modifier_barrack_blood_rush:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_barrack_blood_rush:OnCreated(kv)
	if not self:GetAbility() then return end
	if not IsServer() then return end
	-- references
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	self.radius = self.ability:GetCastRange(self.caster:GetOrigin(), self.caster)
	local interval = 1
	if not IsServer() then return end
	-- Start interval
	--self:StartIntervalThink( interval )
end

function modifier_barrack_blood_rush:OnRefresh(kv)

end

function modifier_barrack_blood_rush:OnRemoved()
end

function modifier_barrack_blood_rush:OnDestroy()
end

--------------------------------------------------------------------------------
-- Interval Effects
-- function modifier_barrack_blood_rush:OnIntervalThink()
-- 	-- check autocast state
-- 	if not self.ability:GetAutoCastState() then return end

-- 	-- check castability
-- 	if not self.ability:IsFullyCastable() then return end

-- 	-- somehow silenced is not included in castability
-- 	if self.caster:IsSilenced() then return end

-- 	-- find allied hero in radius
-- 	local allies = FindUnitsInRadius(
-- 		self.caster:GetTeamNumber(),	-- int, your team number
-- 		self.caster:GetOrigin(),	-- point, center point
-- 		nil,	-- handle, cacheUnit. (not known)
-- 		self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
-- 		DOTA_UNIT_TARGET_TEAM_FRIENDLY,	-- int, team filter
-- 		DOTA_UNIT_TARGET_HERO,	-- int, type filter
-- 		0,	-- int, flag filter
-- 		0,	-- int, order filter
-- 		false	-- bool, can grow cache
-- 	)

-- 	for _,ally in pairs(allies) do
-- 		-- check if ally doesn't have buff yet
-- 		if not ally:HasModifier( "modifier_barrack_blood_rush_buff" ) then
-- 			-- cast ability
-- 			self.caster:CastAbilityOnTarget( ally, self.ability, self.caster:GetPlayerOwnerID() )
-- 			break
-- 		end
-- 	end
-- end

-- Created by Elfansoer
--[[
Ability checklist (erase if done/checked):
- Scepter Upgrade
- Break behavior
- Linken/Reflect behavior
- Spell Immune/Invulnerable/Invisible behavior
- Illusion behavior
- Stolen behavior
]]
--------------------------------------------------------------------------------
modifier_barrack_blood_rush_buff = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_barrack_blood_rush_buff:IsHidden()
	return false
end

function modifier_barrack_blood_rush_buff:IsDebuff()
	return false
end

function modifier_barrack_blood_rush_buff:IsBuff()
	return true
end

function modifier_barrack_blood_rush_buff:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_barrack_blood_rush_buff:OnCreated(kv)
	-- references
	self.model_scale = self:GetAbility():GetSpecialValueFor("modelscale")
	self.ms_bonus = self:GetAbility():GetSpecialValueFor("bonus_movement_speed")
	self.as_bonus = self:GetAbility():GetSpecialValueFor("bonus_attack_speed")


	if not IsServer() then return end

	-- play effects
	local sound_cast = "Hero_OgreMagi.Bloodlust.Target"
	EmitSoundOn(sound_cast, self:GetParent())

	local sound_player = "Hero_OgreMagi.Bloodlust.Target.FP"
	EmitSoundOnClient(sound_player, self:GetParent():GetPlayerOwner())
end

function modifier_barrack_blood_rush_buff:OnRefresh(kv)
	-- do what oncreated do
	self:OnCreated(kv)
end

function modifier_barrack_blood_rush_buff:OnRemoved()
end

function modifier_barrack_blood_rush_buff:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_barrack_blood_rush_buff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE,
		MODIFIER_PROPERTY_MODEL_SCALE,
	}

	return funcs
end

function modifier_barrack_blood_rush_buff:GetModifierMoveSpeedBonus_Percentage()
	return self.ms_bonus
end

function modifier_barrack_blood_rush_buff:GetModifierAttackSpeedPercentage()
	return self.as_bonus
end

function modifier_barrack_blood_rush_buff:GetModifierModelScale()
	return self.model_scale
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_barrack_blood_rush_buff:GetEffectName()
	return "particles/units/heroes/hero_ogre_magi/ogre_magi_bloodlust_buff.vpcf"
end

function modifier_barrack_blood_rush_buff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

modifier_barrack_blood_rush_tag = class({
	IsHidden               = function(self) return true end,
	IsPurgable             = function(self) return false end,
	IsDebuff               = function(self) return false end,
	IsBuff                 = function(self) return true end,
	RemoveOnDeath          = function(self) return true end,
	AllowIllusionDuplicate = function(self) return false end,
	GetAttributes          = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})
