LinkLuaModifier( "modifier_buy_barrack_dino", "ability/buy_barrack_dino.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if buy_barrack_dino == nil then
	buy_barrack_dino = class({})
end

function buy_barrack_dino:OnAbilityPhaseStart()
    return GamePlay:buyBarrackUnitStart(self:GetCaster(), self)
end

function buy_barrack_dino:OnSpellStart()
	if not IsServer() then return end
	GamePlay:buyBarrackUnit(self:GetCaster(),self)
end

function buy_barrack_dino:onRoundUpdate()
	GamePlay:updateSendAbility(self:GetCaster(), self)
end