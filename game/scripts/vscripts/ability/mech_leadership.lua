LinkLuaModifier("modifier_mech_leadership", "ability/mech_leadership.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mech_leadership_buff", "ability/mech_leadership.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if mech_leadership == nil then
	mech_leadership = class({})
end
function mech_leadership:GetIntrinsicModifierName()
	return "modifier_mech_leadership"
end

---------------------------------------------------------------------
--Modifiers

modifier_mech_leadership = class({
	IsHidden      = function(self) return true end,
	IsPurgable    = function(self) return false end,
	IsDebuff      = function(self) return false end,
	IsBuff        = function(self) return true end,
	RemoveOnDeath = function(self) return true end,
	GetAttributes = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})

function modifier_mech_leadership:OnCreated(params)
	if not self:GetAbility() then return end
	local ability = self:GetAbility()
	self.radius = ability:GetSpecialValueFor("radius")
	if IsServer() then
	end
end

function modifier_mech_leadership:OnRefresh(params)
	if IsServer() then
	end
end

function modifier_mech_leadership:OnDestroy()
	if IsServer() then
	end
end

function modifier_mech_leadership:DeclareFunctions()
	return {
	}
end

function modifier_mech_leadership:IsAura()
	return true
end

function modifier_mech_leadership:GetModifierAura()
	return "modifier_mech_leadership_buff"
end

function modifier_mech_leadership:GetAuraRadius()
	local radius = self.radius
	return radius
end

function modifier_mech_leadership:GetAuraDuration()
	return 0
end

function modifier_mech_leadership:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_mech_leadership:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_mech_leadership:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

function modifier_mech_leadership:GetAuraEntityReject(hEntity)
	return false
end

--
modifier_mech_leadership_buff = class({
	IsHidden      = function(self) return false end,
	IsPurgable    = function(self) return false end,
	IsDebuff      = function(self) return false end,
	IsBuff        = function(self) return true end,
	RemoveOnDeath = function(self) return true end,
	GetAttributes = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})
function modifier_mech_leadership_buff:OnCreated()
	if not self:GetAbility() then return end
	local ability = self:GetAbility()
	self.damage = ability:GetSpecialValueFor("damage")
end

function modifier_mech_leadership_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE
	}
end

function modifier_mech_leadership_buff:GetModifierDamageOutgoing_Percentage()
	return self.damage
end
