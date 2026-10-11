LinkLuaModifier("modifier_radiant_granite_golem_hp_aura", "ability/radiant_granite_golem_hp_aura",
	LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_radiant_granite_golem_hp_aura_bonus", "ability/radiant_granite_golem_hp_aura",
	LUA_MODIFIER_MOTION_NONE)
--Abilities
if radiant_granite_golem_hp_aura == nil then
	radiant_granite_golem_hp_aura = class({})
end

function radiant_granite_golem_hp_aura:GetIntrinsicModifierName()
	return "modifier_radiant_granite_golem_hp_aura"
end

---------------------------------------------------------------------
--Modifiers

modifier_radiant_granite_golem_hp_aura = class({
	IsHidden      = function(self) return true end,
	IsPurgable    = function(self) return false end,
	IsDebuff      = function(self) return false end,
	IsBuff        = function(self) return true end,
	RemoveOnDeath = function(self) return true end,
	GetAttributes = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})

function modifier_radiant_granite_golem_hp_aura:OnCreated(params)
	local ability = self:GetAbility()
	self.bonus_hp = ability:GetSpecialValueFor("bonus_hp")
	self.radius = ability:GetSpecialValueFor("radius")
end

function modifier_radiant_granite_golem_hp_aura:OnRefresh(params)
	local ability = self:GetAbility()
	self.bonus_hp = ability:GetSpecialValueFor("bonus_hp")
	self.radius = ability:GetSpecialValueFor("radius")
end

function modifier_radiant_granite_golem_hp_aura:OnDestroy()
	if IsServer() then
	end
end

function modifier_radiant_granite_golem_hp_aura:DeclareFunctions()
	return {
	}
end

function modifier_radiant_granite_golem_hp_aura:IsAura()
	return true
end

function modifier_radiant_granite_golem_hp_aura:GetModifierAura()
	return "modifier_radiant_granite_golem_hp_aura_bonus"
end

function modifier_radiant_granite_golem_hp_aura:GetAuraRadius()
	return self.radius
end

function modifier_radiant_granite_golem_hp_aura:GetAuraDuration()
	return 0
end

function modifier_radiant_granite_golem_hp_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_radiant_granite_golem_hp_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_radiant_granite_golem_hp_aura:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

function modifier_radiant_granite_golem_hp_aura:GetAuraEntityReject(hEntity)
	return false
end

--
modifier_radiant_granite_golem_hp_aura_bonus = class({
	IsHidden      = function(self) return false end,
	IsPurgable    = function(self) return false end,
	IsDebuff      = function(self) return false end,
	IsBuff        = function(self) return true end,
	RemoveOnDeath = function(self) return true end,
	GetAttributes = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})
function modifier_radiant_granite_golem_hp_aura_bonus:OnCreated(params)
	self.bonus_hp = self:GetAbility():GetSpecialValueFor("bonus_hp")
end

function modifier_radiant_granite_golem_hp_aura_bonus:OnRefresh(params)
	self:OnCreated(params)
end

function modifier_radiant_granite_golem_hp_aura_bonus:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE
	}
end

function modifier_radiant_granite_golem_hp_aura_bonus:GetModifierExtraHealthPercentage()
	return self.bonus_hp
end
