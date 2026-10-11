LinkLuaModifier( "modifier_buy_barrack_whelp", "ability/buy_barrack_whelp.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if buy_barrack_whelp == nil then
	buy_barrack_whelp = class({})
end
function buy_barrack_whelp:OnSpellStart()
	if not IsServer() then return end
	GamePlay:buyBarrackUnit(self:GetCaster(),self)
end
function buy_barrack_whelp:OnAbilityPhaseStart()
    return GamePlay:buyBarrackUnitStart(self:GetCaster(), self)
end

function buy_barrack_whelp:onRoundUpdate()
	GamePlay:updateSendAbility(self:GetCaster(), self)
end