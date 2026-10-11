LinkLuaModifier( "modifier_buy_barrack_ballista", "ability/buy_barrack_ballista.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if buy_barrack_ballista == nil then
	buy_barrack_ballista = class({})
end

function buy_barrack_ballista:OnAbilityPhaseStart()
    return GamePlay:buyBarrackUnitStart(self:GetCaster(), self)
end

function buy_barrack_ballista:OnSpellStart()
	if not IsServer() then return end
	GamePlay:buyBarrackUnit(self:GetCaster(),self)
end

function buy_barrack_ballista:onRoundUpdate()
	GamePlay:updateSendAbility(self:GetCaster(), self)
end
