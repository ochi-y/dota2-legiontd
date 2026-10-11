LinkLuaModifier("modifier_paladin_divine_favor", "ability/paladin_divine_favor", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_paladin_divine_favor_buff", "ability/paladin_divine_favor", LUA_MODIFIER_MOTION_NONE)

if paladin_divine_favor == nil then
	paladin_divine_favor = class({})
end

--------------------------------------------------------------------------------
function paladin_divine_favor:GetIntrinsicModifierName()
	return "modifier_paladin_divine_favor"
end

--------------------------------------------------------------------------------


modifier_paladin_divine_favor = class({
	IsHidden      = function(self) return true end,
	IsPurgable    = function(self) return false end,
	IsDebuff      = function(self) return false end,
	IsBuff        = function(self) return true end,
	RemoveOnDeath = function(self) return true end,
})


--------------------------------------------------------------------------------

function modifier_paladin_divine_favor:IsAura()
	return true
end

function modifier_paladin_divine_favor:GetModifierAura()
	return "modifier_paladin_divine_favor_buff"
end

function modifier_paladin_divine_favor:GetAuraRadius()
	return self:GetAbility():GetSpecialValueFor("aura_radius")
end

function modifier_paladin_divine_favor:GetAuraDuration()
	return 0.5
end

function modifier_paladin_divine_favor:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_paladin_divine_favor:GetAuraSearchType()
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_paladin_divine_favor:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD
end

--------------------------------------------------------------------------------


modifier_paladin_divine_favor_buff = class({
	IsHidden      = function(self) return false end,
	IsPurgable    = function(self) return false end,
	IsDebuff      = function(self) return false end,
	IsBuff        = function(self) return true end,
	RemoveOnDeath = function(self) return true end,

})
function modifier_paladin_divine_favor_buff:OnCreated()
	if not self:GetAbility() then return end
	local ability = self:GetAbility()
	self.regen_amp = ability:GetSpecialValueFor("regen_amp")
end

function modifier_paladin_divine_favor_buff:DeclareFunctions()
	return {

		MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
		MODIFIER_PROPERTY_SPELL_LIFESTEAL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_LIFESTEAL_AMPLIFY_PERCENTAGE
	}
end

function modifier_paladin_divine_favor_buff:GetModifierHealAmplify_PercentageTarget(params)
	return 1 * self.regen_amp
end

function modifier_paladin_divine_favor_buff:GetModifierSpellLifestealRegenAmplify_Percentage(params)
	return 1 * self.regen_amp
end

function modifier_paladin_divine_favor_buff:GetModifierHPRegenAmplify_Percentage(params)
	return 1 * self.regen_amp
end

function modifier_paladin_divine_favor_buff:GetModifierLifestealRegenAmplify_Percentage(params)
	return 1 * self.regen_amp
end
