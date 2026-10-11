LinkLuaModifier("modifier_mech_superiority", "ability/mech_superiority.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mech_superiority_buff", "ability/mech_superiority.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if mech_superiority == nil then
	mech_superiority = class({})
end
function mech_superiority:GetIntrinsicModifierName()
	return "modifier_mech_superiority"
end

---------------------------------------------------------------------
--Modifiers

modifier_mech_superiority = class({
	IsHidden      = function(self) return true end,
	IsPurgable    = function(self) return false end,
	IsDebuff      = function(self) return false end,
	IsBuff        = function(self) return true end,
	RemoveOnDeath = function(self) return true end,
	GetAttributes = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})

function modifier_mech_superiority:OnCreated(params)
	if not self:GetAbility() then return end
	local ability = self:GetAbility()
	self.radius = ability:GetSpecialValueFor("radius")

	if IsServer() then
	end
end

function modifier_mech_superiority:OnRefresh(params)
	if IsServer() then
	end
end

function modifier_mech_superiority:OnDestroy()
	if IsServer() then
	end
end

function modifier_mech_superiority:DeclareFunctions()
	return {
	}
end

function modifier_mech_superiority:IsAura()
	return true
end

function modifier_mech_superiority:GetModifierAura()
	return "modifier_mech_superiority_buff"
end

function modifier_mech_superiority:GetAuraRadius()
	local radius = self.radius
	return radius
end

function modifier_mech_superiority:GetAuraDuration()
	return 0
end

function modifier_mech_superiority:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_mech_superiority:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_mech_superiority:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

function modifier_mech_superiority:GetAuraEntityReject(hEntity)
	return false
end

--
modifier_mech_superiority_buff = class({
	IsHidden      = function(self) return false end,
	IsPurgable    = function(self) return false end,
	IsDebuff      = function(self) return false end,
	IsBuff        = function(self) return true end,
	RemoveOnDeath = function(self) return true end,
	GetAttributes = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})

function modifier_mech_superiority_buff:OnCreated()
	if not self:GetAbility() then return end
	local ability = self:GetAbility()
	self.damage = ability:GetSpecialValueFor("damage")
end

function modifier_mech_superiority_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE
	}
end

function modifier_mech_superiority_buff:GetModifierDamageOutgoing_Percentage()
	return self.damage
end
