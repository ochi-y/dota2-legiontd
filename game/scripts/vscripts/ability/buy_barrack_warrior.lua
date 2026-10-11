LinkLuaModifier( "modifier_buy_barrack_warrior", "ability/buy_barrack_warrior.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if buy_barrack_warrior == nil then
	buy_barrack_warrior = class({})
end
function buy_barrack_warrior:OnSpellStart()
	if not IsServer() then return end
	GamePlay:buyBarrackUnit(self:GetCaster(),self)
end

function buy_barrack_warrior:OnAbilityPhaseStart()
    return GamePlay:buyBarrackUnitStart(self:GetCaster(), self)
end

function buy_barrack_warrior:onRoundUpdate()
	GamePlay:updateSendAbility(self:GetCaster(), self)
end