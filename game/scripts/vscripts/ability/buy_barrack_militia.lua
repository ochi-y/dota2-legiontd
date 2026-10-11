LinkLuaModifier( "modifier_buy_barrack_militia", "ability/buy_barrack_militia.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if buy_barrack_militia == nil then
	buy_barrack_militia = class({})
end
function buy_barrack_militia:OnSpellStart()
	if not IsServer() then return end
	GamePlay:buyBarrackUnit(self:GetCaster(),self)
end

function buy_barrack_militia:OnAbilityPhaseStart()
    return GamePlay:buyBarrackUnitStart(self:GetCaster(), self)
end
function buy_barrack_militia:onRoundUpdate()
	GamePlay:updateSendAbility(self:GetCaster(), self)
end