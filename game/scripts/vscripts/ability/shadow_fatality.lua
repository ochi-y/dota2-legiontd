LinkLuaModifier( "modifier_shadow_fatality", "ability/shadow_fatality.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if shadow_fatality == nil then
	shadow_fatality = class({})
end
function shadow_fatality:GetIntrinsicModifierName()
	return "modifier_shadow_fatality"
end
---------------------------------------------------------------------
--Modifiers
if modifier_shadow_fatality == nil then
	modifier_shadow_fatality = class({})
end
function modifier_shadow_fatality:IsHidden(params)
	return true
end
function modifier_shadow_fatality:IsPurgable(params)
	return false
end
function modifier_shadow_fatality:OnCreated(params)
	if not self:GetAbility() then return end
	if IsServer() then
	end
	local ability=self:GetAbility()
	self.crit_chance=ability:GetSpecialValueFor("crit_chance")
	self.evasion=ability:GetSpecialValueFor("evasion")
end
function modifier_shadow_fatality:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_shadow_fatality:OnDestroy()
	if IsServer() then
	end
end
function modifier_shadow_fatality:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
		MODIFIER_PROPERTY_EVASION_CONSTANT
	}
end
function modifier_shadow_fatality:GetModifierEvasion_Constant()
	return self.evasion
end
function modifier_shadow_fatality:GetModifierPreAttack_CriticalStrike()
	if RandomInt(1,100)<=self.crit_chance then
		return 300
	end
end