LinkLuaModifier( "modifier_buy_barrack_ice_troll", "ability/buy_barrack_ice_troll.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if buy_barrack_ice_troll == nil then
	buy_barrack_ice_troll = class({})
end
function buy_barrack_ice_troll:OnSpellStart()
	if not IsServer() then return end
	GamePlay:buyBarrackUnit(self:GetCaster(),self)
end
function buy_barrack_ice_troll:OnAbilityPhaseStart()
    return GamePlay:buyBarrackUnitStart(self:GetCaster(), self)
end

function buy_barrack_ice_troll:onRoundUpdate()
	GamePlay:updateSendAbility(self:GetCaster(), self)
end