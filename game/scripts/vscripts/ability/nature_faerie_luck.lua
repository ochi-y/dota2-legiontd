LinkLuaModifier( "modifier_nature_faerie_luck", "ability/nature_faerie_luck.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if nature_faerie_luck == nil then
	nature_faerie_luck = class({})
end
function nature_faerie_luck:GetIntrinsicModifierName()
	return "modifier_nature_faerie_luck"
end
---------------------------------------------------------------------
--Modifiers
modifier_nature_faerie_luck = class({
IsHidden                = function(self) return true end,
IsPurgable              = function(self) return false end,
IsDebuff                = function(self) return false end,
IsBuff                  = function(self) return true end,
RemoveOnDeath           = function(self) return true end,
GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})
function modifier_nature_faerie_luck:OnCreated(params)
	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.evasion_chance_pct=ability:GetSpecialValueFor("evasion_chance_pct")
end
function modifier_nature_faerie_luck:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_nature_faerie_luck:IsPurgable(params)
	return false
end
function modifier_nature_faerie_luck:OnDestroy()
	if IsServer() then
	end
end
function modifier_nature_faerie_luck:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_EVASION_CONSTANT
	}
end

function modifier_nature_faerie_luck:GetModifierEvasion_Constant()
	return self.evasion_chance_pct
end