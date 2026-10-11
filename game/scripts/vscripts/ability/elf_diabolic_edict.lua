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
elf_diabolic_edict = class({})
LinkLuaModifier("modifier_elf_diabolic_edict", "ability/elf_diabolic_edict", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_elf_diabolic_edict_self", "ability/elf_diabolic_edict", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------
-- Ability Start
function elf_diabolic_edict:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()

	-- load data
	local duration = self:GetSpecialValueFor("duration")

	-- add modifier
	caster:AddNewModifier(
		caster,                          -- player source
		self,                            -- ability source
		"modifier_elf_diabolic_edict", -- modifier name
		{ duration = duration }          -- kv
	)
end
function elf_diabolic_edict:GetIntrinsicModifierName()
	return "modifier_elf_diabolic_edict_self"
end


-------------------------------------------------------------------------------------------------------
modifier_elf_diabolic_edict_self = class({
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return false
    end,
    IsDebuff = function(self)
        return false
    end,
    IsBuff = function(self)
        return true
    end,
    RemoveOnDeath = function(self)
        return true
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_MULTIPLE
    end
})
function modifier_elf_diabolic_edict_self:AllowIllusionDuplicate()
    return true
end
function modifier_elf_diabolic_edict_self:OnCreated(params)
    -- self.damage = params.damage
    -- self:SetHasCustomTransmitterData(true) 
end
function modifier_elf_diabolic_edict_self:OnRefresh(params)
    self:OnCreated(params)
end

function modifier_elf_diabolic_edict_self:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS
	}
end
function modifier_elf_diabolic_edict_self:GetActivityTranslationModifiers( params )
	return "torment"
end
-- --------------------------------------------------------------------------------
-- function elf_diabolic_edict:PlayEffects()
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
modifier_elf_diabolic_edict = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_elf_diabolic_edict:IsHidden()
	return false
end

function modifier_elf_diabolic_edict:IsDebuff()
	return false
end

function modifier_elf_diabolic_edict:IsPurgable()
	return true
end

function modifier_elf_diabolic_edict:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_elf_diabolic_edict:RemoveOnDeath()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_elf_diabolic_edict:OnCreated(kv)
	if not IsServer() then return end
	-- references
	local explosion = self:GetAbility():GetSpecialValueFor("num_explosions")
	local duration = self:GetAbility():GetSpecialValueFor("duration")
	self.radius = self:GetAbility():GetSpecialValueFor("radius")
	self.tower_bonus = 1
	self.damage = self:GetAbility():GetSpecialValueFor("damage")

	-- init data and precache
	local interval = duration / explosion
	self.parent = self:GetParent()
	self.damageTable = {
		-- victim = target,
		attacker = self:GetParent(),
		-- damage = self:GetAbility():GetAbilityDamage(),
		damage_type = self:GetAbility():GetAbilityDamageType(),
		damage_flags=DOTA_DAMAGE_FLAG_BYPASSES_BLOCK,
		ability = self:GetAbility(), --Optional.
	}
	-- ApplyDamage(damageTable)

	-- Start interval
	self:StartIntervalThink(interval)
	self:OnIntervalThink()

	-- play effects
	local sound_loop = "Hero_Leshrac.Diabolic_Edict_lp"
	EmitSoundOn(sound_loop, self.parent)
end

function modifier_elf_diabolic_edict:OnRefresh(kv)
end

function modifier_elf_diabolic_edict:OnRemoved()
end

function modifier_elf_diabolic_edict:OnDestroy()
	if not IsServer() then return end
	local sound_loop = "Hero_Leshrac.Diabolic_Edict_lp"
	StopSoundOn(sound_loop, self.parent)
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_elf_diabolic_edict:OnIntervalThink()
	-- find enemies
	local enemies = FindUnitsInRadius(
		self.parent:GetTeamNumber(),                                          -- int, your team number
		self.parent:GetOrigin(),                                              -- point, center point
		nil,                                                                  -- handle, cacheUnit. (not known)
		self.radius,                                                          -- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,                                          -- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING, -- int, type filter
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,                                                                    -- int, flag filter
		0,                                                                    -- int, order filter
		false                                                                 -- bool, can grow cache
	)

	local enemy = nil
	if #enemies > 0 then
		enemy = enemies[1]
		-- apply damage
		self.damageTable.victim = enemy
		if enemy:IsBuilding() then
			self.damageTable.damage = self.damage * self.tower_bonus
		else
			self.damageTable.damage = self.damage
		end
		ApplyDamage(self.damageTable)
	end

	-- play effects
	self:PlayEffects(enemy)
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_elf_diabolic_edict:PlayEffects(unit)
	-- Get Resources
	local particle_cast = "particles/econ/items/leshrac/leshrac_ti9_immortal_head/leshrac_ti9_immortal_edict.vpcf"
	local sound_cast = "Hero_Leshrac.Diabolic_Edict"


	local pos = nil
	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent)

	if unit then
		ParticleManager:SetParticleControlEnt(
			effect_cast,
			1,
			unit,
			PATTACH_ABSORIGIN_FOLLOW,
			"attach_hitloc",
			Vector(0, 0, 0), -- unknown
			true    -- unknown, true
		)
	else
		pos = self.parent:GetOrigin() + RandomVector(RandomInt(0, self.radius))
		ParticleManager:SetParticleControl(effect_cast, 1,
			pos)
	end
	ParticleManager:ReleaseParticleIndex(effect_cast)

	-- Create Sound
	if unit then
		EmitSoundOn(sound_cast, unit)
	end
	if pos then
		EmitSoundOnLocationWithCaster(pos, sound_cast, self.parent)
	end
end
