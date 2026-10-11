LinkLuaModifier( "modifier_buy_barrack_shaman", "ability/buy_barrack_shaman.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if buy_barrack_shaman == nil then
	buy_barrack_shaman = class({})
end
function buy_barrack_shaman:OnSpellStart()
	if not IsServer() then return end
	GamePlay:buyBarrackUnit(self:GetCaster(),self)
end

function buy_barrack_shaman:OnAbilityPhaseStart()
    return GamePlay:buyBarrackUnitStart(self:GetCaster(), self)
end
function buy_barrack_shaman:onRoundUpdate()
	GamePlay:updateSendAbility(self:GetCaster(), self)
end