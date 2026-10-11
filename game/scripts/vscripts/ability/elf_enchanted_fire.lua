elf_enchanted_fire = class({})
LinkLuaModifier( "modifier_elf_enchanted_fire", "ability/elf_enchanted_fire", LUA_MODIFIER_MOTION_NONE )


elf_enchanted_fire2=elf_enchanted_fire
--------------------------------------------------------------------------------
-- Init Abilities
function elf_enchanted_fire:Precache( context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_spectre.vsndevts", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_spectre/spectre_desolate.vpcf", context )
end

function elf_enchanted_fire:Spawn()
	if not IsServer() then return end
end

--------------------------------------------------------------------------------
-- Passive Modifier
function elf_enchanted_fire:GetIntrinsicModifierName()
	return "modifier_elf_enchanted_fire"
end

--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------
modifier_elf_enchanted_fire = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_elf_enchanted_fire:IsHidden()
	return true
end

function modifier_elf_enchanted_fire:IsDebuff()
	return false
end

function modifier_elf_enchanted_fire:IsStunDebuff()
	return false
end

function modifier_elf_enchanted_fire:IsPurgable()
	return false
end

function modifier_elf_enchanted_fire:AllowIllusionDuplicate()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_elf_enchanted_fire:OnCreated( kv )
	if not self:GetAbility() then return end
	self.parent = self:GetParent()

	-- references
	self.bonus = self:GetAbility():GetSpecialValueFor( "bonus_damage" )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )

	if not IsServer() then return end
	-- ability properties
	self.abilityDamageType = self:GetAbility():GetAbilityDamageType()

	-- precache damage
	self.damageTable = {
		-- victim = target,
		attacker = self:GetParent(),
		damage = self.bonus,
		damage_type = self.abilityDamageType,
		ability = self:GetAbility(), --Optional.
	}
end

function modifier_elf_enchanted_fire:OnRefresh( kv )
	self:OnCreated( kv )
end

function modifier_elf_enchanted_fire:OnRemoved()
end

function modifier_elf_enchanted_fire:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_elf_enchanted_fire:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK,
	}

	return funcs
end

function modifier_elf_enchanted_fire:OnAttack( params )
	if params.attacker~=self.parent then return end
	if self.parent:PassivesDisabled() then return end

	local enemies = FindUnitsInRadius(
		params.target:GetTeamNumber(),	-- int, your team number
		params.target:GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_FRIENDLY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		0,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)
	-- the target is counted in enemies
	if #enemies>1 then return end

	self.damageTable.victim = params.target
	ApplyDamage(self.damageTable)

	self:PlayEffects( params.target )
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_elf_enchanted_fire:PlayEffects( target )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_spectre/spectre_desolate.vpcf"
	local sound_cast = "Hero_Spectre.Desolate"

	-- Get Data
	local forward = (target:GetOrigin()-self.parent:GetOrigin()):Normalized()

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_POINT_FOLLOW, target )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		target,
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:SetParticleControl( effect_cast, 4, target:GetOrigin() )
	ParticleManager:SetParticleControlForward( effect_cast, 0, forward )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOn( sound_cast, target )
end
