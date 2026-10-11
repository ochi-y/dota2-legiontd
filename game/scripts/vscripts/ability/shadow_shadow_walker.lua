LinkLuaModifier( "modifier_shadow_shadow_walker", "ability/shadow_shadow_walker.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if shadow_shadow_walker == nil then
	shadow_shadow_walker = class({})
end
function shadow_shadow_walker:GetIntrinsicModifierName()
	return "modifier_shadow_shadow_walker"
end
---------------------------------------------------------------------
--Modifiers
if modifier_shadow_shadow_walker == nil then
	modifier_shadow_shadow_walker = class({})
end
function modifier_shadow_shadow_walker:IsHidden(params)
	return true
end
function modifier_shadow_shadow_walker:OnCreated(params)
	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.crit_chance=ability:GetSpecialValueFor("crit_chance")
	self.evasion=ability:GetSpecialValueFor("evasion")

	if IsServer() then
	end
end
function modifier_shadow_shadow_walker:IsPurgable(params)
	return false
end
function modifier_shadow_shadow_walker:IsPurgable(params)
	return false
end
function modifier_shadow_shadow_walker:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_shadow_shadow_walker:OnDestroy()
	if IsServer() then
	end
end
function modifier_shadow_shadow_walker:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
		MODIFIER_PROPERTY_EVASION_CONSTANT
	}
end
function modifier_shadow_shadow_walker:GetModifierEvasion_Constant()
	return self.evasion
end
function modifier_shadow_shadow_walker:GetModifierPreAttack_CriticalStrike()
	if RandomInt(1,100)<=self.crit_chance then
		return 200
	end
end