LinkLuaModifier( "modifier_demi_human_slave_trade", "ability/demi_human_slave_trade.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if demi_human_slave_trade == nil then
	demi_human_slave_trade = class({})
end
function demi_human_slave_trade:GetIntrinsicModifierName()
	return "modifier_demi_human_slave_trade"
end
---------------------------------------------------------------------
--Modifiers
modifier_demi_human_slave_trade = class({
IsHidden                = function(self) return true end,
IsPurgable              = function(self) return false end,
IsDebuff                = function(self) return false end,
IsBuff                  = function(self) return true end,
RemoveOnDeath           = function(self) return true end,
GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})
function modifier_demi_human_slave_trade:OnCreated(params)
	if IsServer() then
	end
end
function modifier_demi_human_slave_trade:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_demi_human_slave_trade:IsPurgable(params)
	return false
end
function modifier_demi_human_slave_trade:OnDestroy()
	if IsServer() then
	end
end
function modifier_demi_human_slave_trade:DeclareFunctions()
	return {
	}
end