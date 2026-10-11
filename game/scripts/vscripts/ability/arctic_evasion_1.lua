LinkLuaModifier( "modifier_arctic_evasion_1", "ability/arctic_evasion_1.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if arctic_evasion_1 == nil then
	arctic_evasion_1 = class({})
end
function arctic_evasion_1:GetIntrinsicModifierName()
	return "modifier_arctic_evasion_1"
end
---------------------------------------------------------------------
--Modifiers
modifier_arctic_evasion_1 = class({
IsHidden                = function(self) return true end,
IsPurgable              = function(self) return false end,
IsDebuff                = function(self) return false end,
IsBuff                  = function(self) return true end,
RemoveOnDeath           = function(self) return true end,
GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})
function modifier_arctic_evasion_1:OnCreated(params)
	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.evasion_chance_pct=ability:GetSpecialValueFor("evasion_chance_pct")
end
function modifier_arctic_evasion_1:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_arctic_evasion_1:OnDestroy()
	if IsServer() then
	end
end
function modifier_arctic_evasion_1:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_EVASION_CONSTANT
	}
end

function modifier_arctic_evasion_1:GetModifierEvasion_Constant()
	return self.evasion_chance_pct
end