marine_frogmen_arm_of_the_deep = class({})
LinkLuaModifier("modifier_generic_stunned_lua", "lua_abilities/generic/modifier_generic_stunned_lua",
	LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_generic_knockback_lua", "lua_abilities/generic/modifier_generic_knockback_lua",
	LUA_MODIFIER_MOTION_BOTH)


LinkLuaModifier("modifier_marine_frogmen_arm_of_the_deep_tag", "ability/marine_frogmen_arm_of_the_deep",
	LUA_MODIFIER_MOTION_NONE)


marine_impale = marine_frogmen_arm_of_the_deep
--------------------------------------------------------------------------------
-- Ability Start
function marine_frogmen_arm_of_the_deep:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local point = self:GetCursorPosition()

	-- load data
	if target then
		point = target:GetOrigin()
	end

	local projectile_name = "particles/neutral_fx/frogmen_arm_of_the_deep_projectile.vpcf"
	local projectile_distance = self:GetCastRange(point, target)
	local projectile_radius = self:GetSpecialValueFor("projectile_width")
	local projectile_speed = self:GetSpecialValueFor("speed")
	local projectile_direction = (point - caster:GetOrigin()):Normalized()
	local info = {
		Source = caster,
		Ability = self,
		vSpawnOrigin = caster:GetAbsOrigin(),

		bDeleteOnHit = false,

		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,

		EffectName = projectile_name,
		fDistance = projectile_distance,
		fStartRadius = projectile_radius,
		fEndRadius = projectile_radius,
		vVelocity = projectile_direction * projectile_speed,
	}
	ProjectileManager:CreateLinearProjectile(info)

	-- play effects
	local sound_cast = "Hero_Tidehunter.ArmsOfTheDeep"
	EmitSoundOn(sound_cast, caster)
end

--------------------------------------------------------------------------------
-- Projectile
function marine_frogmen_arm_of_the_deep:OnProjectileHit(target, location)
	if not target then return end
	if target:TriggerSpellAbsorb(self) then return end

	local stun = self:GetSpecialValueFor("duration")
	local air_time = self:GetSpecialValueFor("duration")

	air_time = air_time * (1 - CalUnitStatusResistance(target))

	local damage = self:GetSpecialValueFor("damage")


	if target:HasFlyMovementCapability() then
		return
	end

	-- stun
	target:AddNewModifier(
		self:GetCaster(),         -- player source
		self,                     -- ability source
		"modifier_generic_stunned_lua", -- modifier name
		{ duration = stun }       -- kv
	)
	-- knockback
	local knockback = target:AddNewModifier(
		self:GetCaster(),           -- player source
		self,                       -- ability source
		"modifier_generic_knockback_lua", -- modifier name
		{
			duration = air_time,
			height = 150,
			IsStun = 1,
		} -- kv
	)
	--local callback = function()
	-- damage on landed
	local damageTable = {
		victim = target,
		attacker = self:GetCaster(),
		damage = damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self, --Optional.
	}
	ApplyDamage(damageTable)
	-- play effects
	-- local sound_cast = "Hero_Lion.ImpaleTargetLand"
	-- EmitSoundOn( sound_cast, target )
	-- end
	-- knockback:SetEndCallback( callback )

	-- play effects
	self:PlayEffects(target)
end

--------------------------------------------------------------------------------
function marine_frogmen_arm_of_the_deep:PlayEffects(target)
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_tidehunter/tidehunter_arm_of_the_deep_hit_model.vpcf"
	local sound_cast = "Hero_Tidehunter.ArmsOfTheDeep.Stun"
	-- -- Create Particle

	PlayEffOnLocation(particle_cast, target:GetAbsOrigin())
	-- Create Sound
	EmitSoundOn(sound_cast, target)
end

-------------------------------------------------------------------------------------------------------
modifier_marine_frogmen_arm_of_the_deep_tag = class({
	IsHidden = function(self)
		return true
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
		return MODIFIER_ATTRIBUTE_NONE
	end
})
function modifier_marine_frogmen_arm_of_the_deep_tag:AllowIllusionDuplicate()
	return false
end

function modifier_marine_frogmen_arm_of_the_deep_tag:OnCreated(params)
end

function modifier_marine_frogmen_arm_of_the_deep_tag:OnRefresh(params)
	self:OnCreated(params)
end

function modifier_marine_frogmen_arm_of_the_deep_tag:DeclareFunctions()
	return {

	}
end
