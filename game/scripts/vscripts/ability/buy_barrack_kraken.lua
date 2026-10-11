LinkLuaModifier( "modifier_buy_barrack_kraken", "ability/buy_barrack_kraken.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if buy_barrack_kraken == nil then
	buy_barrack_kraken = class({})
end
function buy_barrack_kraken:OnSpellStart()
	if not IsServer() then return end
	GamePlay:buyBarrackUnit(self:GetCaster(),self)
end


function buy_barrack_kraken:OnAbilityPhaseStart()
    return GamePlay:buyBarrackUnitStart(self:GetCaster(), self)
end
function buy_barrack_kraken:onRoundUpdate()
	GamePlay:updateSendAbility(self:GetCaster(), self)
end