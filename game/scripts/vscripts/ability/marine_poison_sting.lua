--------------------------------------------------------------------------------
marine_poison_sting = class({})
LinkLuaModifier("modifier_marine_poison_sting", "ability/marine_poison_sting", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_marine_poison_sting_debuff", "ability/marine_poison_sting", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------
-- Init Abilities
function marine_poison_sting:Precache(context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_venomancer.vsndevts", context)
	PrecacheResource("particle", "particles/units/heroes/hero_venomancer/venomancer_poison_debuff.vpcf", context)
end

function marine_poison_sting:Spawn()
	if not IsServer() then return end
end

--------------------------------------------------------------------------------
-- Passive Modifier
function marine_poison_sting:GetIntrinsicModifierName()
	return "modifier_marine_poison_sting"
end

--------------------------------------------------------------------------------
modifier_marine_poison_sting = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_marine_poison_sting:IsHidden()
	return true
end

function modifier_marine_poison_sting:IsDebuff()
	return false
end

function modifier_marine_poison_sting:IsStunDebuff()
	return false
end

function modifier_marine_poison_sting:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_marine_poison_sting:OnCreated(kv)
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	self.team = self:GetCaster():GetTeamNumber()

	-- references
	self.duration = self:GetAbility():GetSpecialValueFor("duration")

	if not IsServer() then return end
	-- ability properties
	self.abilityDamageType = self:GetAbility():GetAbilityDamageType()
	self.abilityTargetTeam = self:GetAbility():GetAbilityTargetTeam()
	self.abilityTargetType = self:GetAbility():GetAbilityTargetType()
	self.abilityTargetFlags = self:GetAbility():GetAbilityTargetFlags()
end

function modifier_marine_poison_sting:OnRefresh(kv)
	self:OnCreated(kv)
end

function modifier_marine_poison_sting:OnRemoved()
end

function modifier_marine_poison_sting:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_marine_poison_sting:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
	}

	return funcs
end

function modifier_marine_poison_sting:GetModifierProcAttack_Feedback(params)
	if not IsServer() then return end
	if self.caster:PassivesDisabled() then return end

	local filter = UnitFilter(
		params.target,
		self.abilityTargetTeam,
		self.abilityTargetType,
		self.abilityTargetFlags,
		self.team
	)
	if not filter == UF_SUCCESS then return end

	-- apply debuff
	params.target:AddNewModifier(
		self.caster,                     -- player source
		self.ability,                    -- ability source
		"modifier_marine_poison_sting_debuff", -- modifier name
		{ duration = self.duration }     -- kv
	)
end

--------------------------------------------------------------------------------
modifier_marine_poison_sting_debuff = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_marine_poison_sting_debuff:IsHidden()
	return false
end

function modifier_marine_poison_sting_debuff:IsDebuff()
	return true
end

function modifier_marine_poison_sting_debuff:IsStunDebuff()
	return false
end

function modifier_marine_poison_sting_debuff:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_marine_poison_sting_debuff:OnCreated(kv)
	if not self:GetAbility() then return end

	self.parent = self:GetParent()
	self.caster = self:GetCaster()

	-- references
	local damage = self:GetAbility():GetSpecialValueFor("damage")
	self.slow = self:GetAbility():GetSpecialValueFor("movement_speed")
	self.regen_reduction = self:GetAbility():GetSpecialValueFor("regen_reduction")




	if not IsServer() then return end

	-- precache damage
	self.damageTable = {
		victim = self:GetParent(),
		attacker = self:GetCaster(),
		damage = damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self:GetAbility(),      --Optional.
		damage_flags = DOTA_DAMAGE_FLAG_HPLOSS, --Optional.
	}
	-- ApplyDamage(damageTable)

	self:StartIntervalThink(1)
	-- self:OnIntervalThink()
end

function modifier_marine_poison_sting_debuff:OnRefresh(kv)
	self:OnCreated(kv)
end

function modifier_marine_poison_sting_debuff:OnRemoved()
end

function modifier_marine_poison_sting_debuff:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_marine_poison_sting_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
		MODIFIER_PROPERTY_SPELL_LIFESTEAL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_LIFESTEAL_AMPLIFY_PERCENTAGE
	}

	return funcs
end

function modifier_marine_poison_sting_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_marine_poison_sting_debuff:OnIntervalThink()
	if not IsActiveUnit(self.caster) then
		self.damageTable.attacker=self:GetParent()
	end

	ApplyDamage(self.damageTable)
	-- overhead damage info
	SendOverheadEventMessage(
		nil,
		OVERHEAD_ALERT_BONUS_SPELL_DAMAGE,
		self.parent,
		self.damageTable.damage,
		nil
	)
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_marine_poison_sting_debuff:GetEffectName()
	return "particles/units/heroes/hero_venomancer/venomancer_poison_debuff.vpcf"
end

function modifier_marine_poison_sting_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_marine_poison_sting_debuff:GetModifierHealAmplify_PercentageTarget(params)
	return -1 * self.regen_reduction
end

function modifier_marine_poison_sting_debuff:GetModifierSpellLifestealRegenAmplify_Percentage(params)
	return -1 * self.regen_reduction
end

function modifier_marine_poison_sting_debuff:GetModifierHPRegenAmplify_Percentage(params)
	return -1 * self.regen_reduction
end

function modifier_marine_poison_sting_debuff:GetModifierLifestealRegenAmplify_Percentage(params)
	return -1 * self.regen_reduction
end
