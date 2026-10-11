LinkLuaModifier( "modifier_arctic_evasion", "ability/arctic_evasion.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if arctic_evasion == nil then
	arctic_evasion = class({})
end
function arctic_evasion:GetIntrinsicModifierName()
	return "modifier_arctic_evasion"
end
---------------------------------------------------------------------
--Modifiers
modifier_arctic_evasion = class({
IsHidden                = function(self) return true end,
IsPurgable              = function(self) return false end,
IsDebuff                = function(self) return false end,
IsBuff                  = function(self) return true end,
RemoveOnDeath           = function(self) return true end,
GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})
function modifier_arctic_evasion:OnCreated(params)
	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.evasion_chance_pct=ability:GetSpecialValueFor("evasion_chance_pct")
end
function modifier_arctic_evasion:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_arctic_evasion:OnDestroy()
	if IsServer() then
	end
end
function modifier_arctic_evasion:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_EVASION_CONSTANT
	}
end

function modifier_arctic_evasion:GetModifierEvasion_Constant()
	return self.evasion_chance_pct
end