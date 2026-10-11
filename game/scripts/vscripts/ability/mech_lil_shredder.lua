--------------------------------------------------------------------------------
mech_lil_shredder = class({})
LinkLuaModifier("modifier_mech_lil_shredder", "ability/mech_lil_shredder", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mech_lil_shredder_debuff", "ability/mech_lil_shredder", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------
-- Ability Start
function mech_lil_shredder:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()

	-- load data
	local duration = self:GetSpecialValueFor("buff_duration_tooltip")
	
	-- addd buff
	caster:AddNewModifier(
		caster,                 -- player source
		self,                   -- ability source
		"modifier_mech_lil_shredder", -- modifier name
		{ duration = duration } -- kv
	)
end

modifier_mech_lil_shredder = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_mech_lil_shredder:IsHidden()
	return false
end

function modifier_mech_lil_shredder:IsDebuff()
	return false
end

function modifier_mech_lil_shredder:IsStunDebuff()
	return false
end

function modifier_mech_lil_shredder:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_mech_lil_shredder:OnCreated(kv)
	-- references
	self.attacks = self:GetAbility():GetSpecialValueFor("buffed_attacks")
	self.damage = self:GetAbility():GetSpecialValueFor("damage")


	self.as_bonus = self:GetAbility():GetSpecialValueFor("attack_speed_bonus")
	self.range_bonus = self:GetAbility():GetSpecialValueFor("attack_range_bonus")
	self.bat = self:GetAbility():GetSpecialValueFor("base_attack_time")

	self.armor_duration = self:GetAbility():GetSpecialValueFor("armor_duration")

	if not IsServer() then return end
	self:SetStackCount(self.attacks)

	self.records = {}

	-- play Effects & Sound
	self:PlayEffects()
	local sound_cast = "Hero_Snapfire.ExplosiveShells.Cast"
	EmitSoundOn(sound_cast, self:GetParent())
end

function modifier_mech_lil_shredder:OnRefresh(kv)
	-- references
	self.attacks = self:GetAbility():GetSpecialValueFor("buffed_attacks")
	self.damage = self:GetAbility():GetSpecialValueFor("damage")

	
	self.as_bonus = self:GetAbility():GetSpecialValueFor("attack_speed_bonus")
	self.range_bonus = self:GetAbility():GetSpecialValueFor("attack_range_bonus")
	self.bat = self:GetAbility():GetSpecialValueFor("base_attack_time")

	self.armor_duration = self:GetAbility():GetSpecialValueFor("armor_duration")

	if not IsServer() then return end
	self:SetStackCount(self.attacks)

	-- play sound
	local sound_cast = "Hero_Snapfire.ExplosiveShells.Cast"
	EmitSoundOn(sound_cast, self:GetParent())
end

function modifier_mech_lil_shredder:OnRemoved()
end

function modifier_mech_lil_shredder:OnDestroy()
	if not IsServer() then return end

	-- stop sound
	local sound_cast = "Hero_Snapfire.ExplosiveShells.Cast"
	StopSoundOn(sound_cast, self:GetParent())
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_mech_lil_shredder:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY,

		MODIFIER_PROPERTY_PROJECTILE_NAME,
		MODIFIER_PROPERTY_OVERRIDE_ATTACK_DAMAGE,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
	}

	return funcs
end

function modifier_mech_lil_shredder:OnAttack(params)
	if params.attacker ~= self:GetParent() then return end
	if self:GetStackCount() <= 0 then return end

	-- record attack
	self.records[params.record] = true

	-- play sound
	local sound_cast = "Hero_Snapfire.ExplosiveShellsBuff.Attack"
	EmitSoundOn(sound_cast, self:GetParent())

	-- decrement stack
	if self:GetStackCount() > 0 then
		self:DecrementStackCount()
	end
end

function modifier_mech_lil_shredder:OnAttackLanded(params)
	if self.records[params.record] then
		-- add modifier
		params.target:AddNewModifier(
			self:GetParent(),           -- player source
			self:GetAbility(),          -- ability source
			"modifier_mech_lil_shredder_debuff", -- modifier name
			{ duration = self.armor_duration } -- kv
		)
	end

	-- play sound
	local sound_cast = "Hero_Snapfire.ExplosiveShellsBuff.Target"
	EmitSoundOn(sound_cast, params.target)
end

function modifier_mech_lil_shredder:OnAttackRecordDestroy(params)
	if self.records[params.record] then
		self.records[params.record] = nil

		-- if table is empty and no stack left, destroy
		if next(self.records) == nil and self:GetStackCount() <= 0 then
			self:Destroy()
		end
	end
end

function modifier_mech_lil_shredder:GetModifierProjectileName()
	if self:GetStackCount() <= 0 then return end
	return "particles/units/heroes/hero_snapfire/hero_snapfire_shells_projectile.vpcf"
end

function modifier_mech_lil_shredder:GetModifierOverrideAttackDamage()
	if self:GetStackCount() <= 0 then return end
	return self.damage
end

function modifier_mech_lil_shredder:GetModifierAttackRangeBonus()
	if self:GetStackCount() <= 0 then return end
	return self.range_bonus
end

function modifier_mech_lil_shredder:GetModifierAttackSpeedBonus_Constant()
	if self:GetStackCount() <= 0 then return end
	return self.as_bonus
end

function modifier_mech_lil_shredder:GetModifierBaseAttackTimeConstant()
	if self:GetStackCount() <= 0 then return end
	return self.bat
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_mech_lil_shredder:PlayEffects()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_snapfire/hero_snapfire_shells_buff.vpcf"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		3,
		self:GetParent(),
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0, 0, 0), -- unknown
		true     -- unknown, true
	)
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		4,
		self:GetParent(),
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0, 0, 0), -- unknown
		true     -- unknown, true
	)
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		5,
		self:GetParent(),
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0, 0, 0), -- unknown
		true     -- unknown, true
	)

	-- buff particle
	self:AddParticle(
		effect_cast,
		false, -- bDestroyImmediately
		false, -- bStatusEffect
		-1, -- iPriority
		false, -- bHeroEffect
		false -- bOverheadEffect
	)
end

modifier_mech_lil_shredder_debuff = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_mech_lil_shredder_debuff:IsHidden()
	return false
end

function modifier_mech_lil_shredder_debuff:IsDebuff()
	return true
end

function modifier_mech_lil_shredder_debuff:IsStunDebuff()
	return false
end

function modifier_mech_lil_shredder_debuff:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_mech_lil_shredder_debuff:OnCreated(kv)
	if not self:GetAbility() then return end
	-- references
	self.armor_reduction_per_attack = -self:GetAbility():GetSpecialValueFor("armor_reduction_per_attack")

	if not IsServer() then return end
	self:SetStackCount(1)
end

function modifier_mech_lil_shredder_debuff:OnRefresh(kv)
	if not IsServer() then return end
	self:IncrementStackCount()
end

function modifier_mech_lil_shredder_debuff:OnRemoved()
end

function modifier_mech_lil_shredder_debuff:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_mech_lil_shredder_debuff:DeclareFunctions()
	local funcs = {
		-- MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS

	}

	return funcs
end

function modifier_mech_lil_shredder_debuff:GetModifierPhysicalArmorBonus()
	return self.armor_reduction_per_attack * self:GetStackCount()
end

-- function modifier_mech_lil_shredder_debuff:GetModifierAttackSpeedBonus_Constant()
-- 	return self.slow * self:GetStackCount()
-- end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_mech_lil_shredder_debuff:GetEffectName()
	-- return "particles/units/heroes/hero_snapfire/hero_snapfire_slow_debuff.vpcf"
	return "particles/items2_fx/medallion_of_courage.vpcf"
end

function modifier_mech_lil_shredder_debuff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end
