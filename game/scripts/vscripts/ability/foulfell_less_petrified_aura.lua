LinkLuaModifier("modifier_foulfell_less_petrified_aura", "ability/foulfell_less_petrified_aura.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_foulfell_less_petrified_aura_buff", "ability/foulfell_less_petrified_aura.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
foulfell_less_petrified_aura = class({})

foulfell_less_petrified_aura = foulfell_less_petrified_aura
function foulfell_less_petrified_aura:GetIntrinsicModifierName()
	return "modifier_foulfell_less_petrified_aura"
end
--
modifier_foulfell_less_petrified_aura = class({
	IsHidden      = function(self) return true end,
	IsPurgable    = function(self) return false end,
	IsDebuff      = function(self) return false end,
	IsBuff        = function(self) return true end,
	RemoveOnDeath = function(self) return true end,
	GetAttributes = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})

function modifier_foulfell_less_petrified_aura:OnCreated(params)
	local ability = self:GetAbility()
	if not ability then
		return
	end

	self.radius = ability:GetSpecialValueFor("radius")
end

function modifier_foulfell_less_petrified_aura:OnRefresh(params)
	if IsServer() then
	end
end

function modifier_foulfell_less_petrified_aura:OnDestroy()
	if IsServer() then
	end
end

function modifier_foulfell_less_petrified_aura:DeclareFunctions()
	return {
	}
end

function modifier_foulfell_less_petrified_aura:IsAura()
	return true
end

function modifier_foulfell_less_petrified_aura:GetModifierAura()
	return "modifier_foulfell_less_petrified_aura_buff"
end

function modifier_foulfell_less_petrified_aura:GetAuraRadius()
	return self.radius
end

function modifier_foulfell_less_petrified_aura:GetAuraDuration()
	return 0
end

function modifier_foulfell_less_petrified_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_foulfell_less_petrified_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_foulfell_less_petrified_aura:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_foulfell_less_petrified_aura:GetAuraEntityReject(hEntity)
	return false
end

--
modifier_foulfell_less_petrified_aura_buff = class({
	IsHidden      = function(self) return false end,
	IsPurgable    = function(self) return false end,
	IsDebuff      = function(self) return true end,
	IsBuff        = function(self) return false end,
	RemoveOnDeath = function(self) return true end,
	GetAttributes = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})
function modifier_foulfell_less_petrified_aura_buff:OnCreated()
	if not self:GetAbility() then return end
	local ability = self:GetAbility()
	self.damage_amp = ability:GetSpecialValueFor("damage_amp")
	self.bonus_magic_resistance = ability:GetSpecialValueFor("bonus_magic_resistance")
end

function modifier_foulfell_less_petrified_aura_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
	}
end

function modifier_foulfell_less_petrified_aura_buff:GetModifierIncomingDamage_Percentage(params)
	if params.damage_type == DAMAGE_TYPE_PHYSICAL then
		return self.damage_amp
	end
end

function modifier_foulfell_less_petrified_aura_buff:GetModifierMagicalResistanceBonus()
	return self.bonus_magic_resistance
end
