LinkLuaModifier( "modifier_buy_barrack_demon", "ability/buy_barrack_demon.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if buy_barrack_demon == nil then
	buy_barrack_demon = class({})
end
function buy_barrack_demon:OnSpellStart()
	if not IsServer() then return end
	GamePlay:buyBarrackUnit(self:GetCaster(),self)
end

function buy_barrack_demon:OnAbilityPhaseStart()
    return GamePlay:buyBarrackUnitStart(self:GetCaster(), self)
end

function buy_barrack_demon:onRoundUpdate()
	GamePlay:updateSendAbility(self:GetCaster(), self)
end