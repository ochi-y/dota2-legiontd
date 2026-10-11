--------------------------------------------------------------------------------
undead_meat_hook = class({})
LinkLuaModifier("modifier_undead_meat_hook", "ability/undead_meat_hook", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_undead_meat_hook_self", "ability/undead_meat_hook", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------
-- Init Abilities
function undead_meat_hook:Precache(context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_pudge.vsndevts", context)
	PrecacheResource("particle", "particles/units/heroes/hero_pudge/pudge_meathook.vpcf", context)
end

function undead_meat_hook:Spawn()
	if not IsServer() then return end
end

function undead_meat_hook:OnAbilityPhaseStart()
	local caster=self:GetCaster()
	caster:StartGesture(ACT_DOTA_OVERRIDE_ABILITY_1)
	return true
end
--------------------------------------------------------------------------------
-- Ability Start
function undead_meat_hook:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	-- load data
	local projectile_name = ""
	local projectile_distance = self:GetSpecialValueFor("hook_distance")
	local projectile_speed = self:GetSpecialValueFor("hook_speed")
	local projectile_radius = self:GetSpecialValueFor("hook_width")

	-- calculate direction
	local origin = caster:GetOrigin()
	local dir = point - origin
	dir.z = 0
	local projectile_direction = dir:Normalized()

	-- calculate target
	local target = origin + projectile_direction * projectile_distance

	-- create projectiles
	local info = {
		Source = caster,
		Ability = self,
		vSpawnOrigin = caster:GetAbsOrigin(),

		bDeleteOnHit = true,

		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,

		EffectName = projectile_name,
		fDistance = projectile_distance,
		fStartRadius = projectile_radius,
		fEndRadius = projectile_radius,
		vVelocity = projectile_direction * projectile_speed,
	}
	local id = ProjectileManager:CreateLinearProjectile(info)

	-- create projectile data
	local data = {}
	data.cast_location = origin
	self.projectiles[id] = data

	-- add self stun modifier
	local duration = projectile_distance / projectile_speed
	caster:AddNewModifier(
		caster,                     -- player source
		self,                       -- ability source
		"modifier_undead_meat_hook_self", -- modifier name
		{ duration = duration }     -- kv
	)

	-- play effects
	self:PlayEffects(target, data)
end

--------------------------------------------------------------------------------
-- Projectile
undead_meat_hook.projectiles = {}
function undead_meat_hook:OnProjectileHitHandle(target, location, handle)
	local data = self.projectiles[handle]
	if not data then return true end




	if not target then
		-- remove ref
		self.projectiles[handle] = nil

		-- set effects
		self:SetEffects1(data)

		return true
	end


	if target == self:GetCaster() then
		-- pass
		return false
	end
	if target:HasModifier("modifier_undead_meat_hook") then
		return false
	end
	if GamePlay.state ~= "in-round" then
		return false
	end
	-- add drag modifier
	target:AddNewModifier(
		self:GetCaster(),      -- player source
		self,                  -- ability source
		"modifier_undead_meat_hook", -- modifier name
		{ handle = handle }    -- kv
	)
	
	-- damage
	if target:GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then
		local damage = self:GetSpecialValueFor("damage")
		local damageTable = {
			victim = target,
			attacker = self:GetCaster(),
			damage = damage,
			damage_type = DAMAGE_TYPE_PURE,
			ability = self, --Optional.
		}
		ApplyDamage(damageTable)

		-- if target:IsCreep() and not target:IsCreepHero() and not target:IsAncient() then
		-- 	target:Kill( self, self:GetCaster() )
		-- end
	end

	-- add FOW
	local radius = self:GetSpecialValueFor("vision_radius")
	local duration = self:GetSpecialValueFor("vision_duration")
	AddFOWViewer(self:GetCaster():GetTeamNumber(), target:GetOrigin(), radius, duration, false)

	-- set effects
	self:SetEffects2(data, target)

	self:GetCaster():RemoveGesture(ACT_DOTA_OVERRIDE_ABILITY_1);
	self:GetCaster():StartGesture(ACT_DOTA_CHANNEL_ABILITY_1);

	return true
end

--------------------------------------------------------------------------------
-- Effects
function undead_meat_hook:PlayEffects(point, data)
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_pudge/pudge_meathook.vpcf"
	local sound_cast = "Hero_Pudge.AttackHookExtend"

	-- Get Data
	local speed = self:GetSpecialValueFor("hook_speed")
	local distance = self:GetSpecialValueFor("hook_distance")
	local radius = self:GetSpecialValueFor("hook_width")
	local duration = distance / speed * 2

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_CUSTOMORIGIN, self:GetCaster())
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		self:GetCaster(),
		PATTACH_POINT_FOLLOW,
		"attach_attack1",
		Vector(0, 0, 0), -- unknown
		true       -- unknown, true
	)
	ParticleManager:SetParticleControl(effect_cast, 1, point)
	ParticleManager:SetParticleControl(effect_cast, 2, Vector(speed, distance, radius))
	ParticleManager:SetParticleControl(effect_cast, 3, Vector(duration, 0, 0))
	ParticleManager:SetParticleControl(effect_cast, 4, Vector(1, 0, 0))
	ParticleManager:SetParticleControl(effect_cast, 5, Vector(0, 0, 0))
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		7,
		self:GetCaster(),
		PATTACH_CUSTOMORIGIN,
		"attach_hitloc",
		Vector(0, 0, 0), -- unknown
		true       -- unknown, true
	)
	ParticleManager:SetParticleAlwaysSimulate(effect_cast)
	ParticleManager:SetParticleShouldCheckFoW(effect_cast, false)

	-- Create Sound
	EmitSoundOn(sound_cast, self:GetCaster())

	-- store effect
	data.effect_cast = effect_cast
end

function undead_meat_hook:SetEffects1(data)
	-- set return effect
	ParticleManager:SetParticleControlEnt(
		data.effect_cast,
		1,
		self:GetCaster(),
		PATTACH_POINT_FOLLOW,
		"attach_attack1",
		Vector(0, 0, 0), -- unknown
		true       -- unknown, true
	)
	ParticleManager:ReleaseParticleIndex(data.effect_cast)


		local caster=self:GetCaster()
		caster:FadeGesture(ACT_DOTA_OVERRIDE_ABILITY_1)

	EmitSoundOn("Hero_Pudge.AttackHookRetract", self:GetCaster())
end

function undead_meat_hook:SetEffects2(data, target)
	-- set effects
	ParticleManager:SetParticleControlEnt(
		data.effect_cast,
		1,
		target,
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0, 0, 0), -- unknown
		true       -- unknown, true
	)
	ParticleManager:SetParticleControl(data.effect_cast, 4, Vector(0, 0, 0))
	ParticleManager:SetParticleControl(data.effect_cast, 5, Vector(1, 0, 0))

	EmitSoundOn("Hero_Pudge.AttackHookImpact", target)
	EmitSoundOn("Hero_Pudge.AttackHookRetract", self:GetCaster())
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
modifier_undead_meat_hook = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_undead_meat_hook:IsHidden()
	return false
end

function modifier_undead_meat_hook:IsDebuff()
	return self.enemy
end

function modifier_undead_meat_hook:IsStunDebuff()
	return true
end

function modifier_undead_meat_hook:IsPurgable()
	return true
end

-- Optional Classifications
function modifier_undead_meat_hook:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_undead_meat_hook:RemoveOnDeath()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_undead_meat_hook:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	-- references
	self.offset = 80
	self.threshold = 80
	self.speed = self:GetAbility():GetSpecialValueFor("hook_speed")

	if not IsServer() then return end

	-- get position data
	self.data = self.ability.projectiles[kv.handle]
	if not self.data then
		self.failed = true
		self:Destroy()
		return
	end
	self.origin = self.data.cast_location

	-- remove ref
	self.ability.projectiles[kv.handle] = nil

	-- get additional data
	self.enemy = self.parent:GetTeamNumber() ~= self.caster:GetTeamNumber()
	self.stunned = self.enemy and (not self.parent:IsMagicImmune())
	self.interrupted = false

	-- calculate direction
	self.direction = self.origin - self.parent:GetOrigin()
	self.direction.z = 0

	self.distance = self.direction:Length2D() - self.offset
	self.direction = self.direction:Normalized()

	-- calculate duration
	self.duration = self.distance / self.speed
	self:SetDuration(self.duration, true)

	-- set facing direction
	self.parent:SetForwardVector(self.direction)

	-- apply motion
	if not self:ApplyHorizontalMotionController() then
		self:GetParent():RemoveHorizontalMotionController(self)
	end
end

function modifier_undead_meat_hook:OnRefresh(kv)
end

function modifier_undead_meat_hook:OnRemoved()
end

function modifier_undead_meat_hook:OnDestroy()
	if not IsServer() then return end
	if self.failed then return end

	-- remove particle ref
	ParticleManager:DestroyParticle(self.data.effect_cast, true)
	ParticleManager:ReleaseParticleIndex(self.data.effect_cast)

	if not self.interrupted then
		self:GetParent():RemoveHorizontalMotionController(self)
	end

	-- force parent to the cast location
	FindClearSpaceForUnit(self.parent, self.origin - self.direction * self.offset, true)

	-- play effects
	EmitSoundOn("Hero_Pudge.AttackHookRetractStop", self.caster)
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_undead_meat_hook:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end

function modifier_undead_meat_hook:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end

--------------------------------------------------------------------------------
-- Status Effects
function modifier_undead_meat_hook:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = self.stunned,
	}

	return state
end

--------------------------------------------------------------------------------
-- Motion Effects
function modifier_undead_meat_hook:UpdateHorizontalMotion(me, dt)
	if self.interrupted then return end

	local nextpos = me:GetOrigin() + self.direction * self.speed * dt
	nextpos = GetGroundPosition(nextpos, me)
	me:SetOrigin(nextpos)

	-- check caster still in cast position
	if (self.caster:GetOrigin() - self.origin):Length2D() > self.threshold then
		-- set effects
		ParticleManager:SetParticleControlEnt(
			self.data.effect_cast,
			0,
			self:GetCaster(),
			PATTACH_WORLDORIGIN,
			"attach_hitloc",
			self.origin, -- unknown
			true -- unknown, true
		)
		ParticleManager:SetParticleControl(self.data.effect_cast, 0, self.origin)
	end
end

function modifier_undead_meat_hook:OnHorizontalMotionInterrupted()
	-- set effects
	ParticleManager:SetParticleControlEnt(
		self.data.effect_cast,
		0,
		self:GetCaster(),
		PATTACH_WORLDORIGIN,
		"attach_hitloc",
		self.origin, -- unknown
		true   -- unknown, true
	)
	ParticleManager:SetParticleControlEnt(
		self.data.effect_cast,
		1,
		self:GetCaster(),
		PATTACH_WORLDORIGIN,
		"attach_hitloc",
		self.origin, -- unknown
		true   -- unknown, true
	)
	ParticleManager:SetParticleControl(self.data.effect_cast, 0, self.origin)
	ParticleManager:SetParticleControl(self.data.effect_cast, 1, self.origin)

	self:GetParent():RemoveHorizontalMotionController(self)
	self.interrupted = true
end

modifier_undead_meat_hook_self = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_undead_meat_hook_self:IsHidden()
	return true
end

function modifier_undead_meat_hook_self:IsDebuff()
	return false
end

function modifier_undead_meat_hook_self:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Status Effects
function modifier_undead_meat_hook_self:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
	}

	return state
end
