LinkLuaModifier( "modifier_buy_barrack_bowman", "ability/buy_barrack_bowman.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if buy_barrack_bowman == nil then
	buy_barrack_bowman = class({})
end
function buy_barrack_bowman:OnSpellStart()
	if not IsServer() then return end
	GamePlay:buyBarrackUnit(self:GetCaster(),self)
end
function buy_barrack_bowman:OnAbilityPhaseStart()
    return GamePlay:buyBarrackUnitStart(self:GetCaster(), self)
end

function buy_barrack_bowman:onRoundUpdate()
	GamePlay:updateSendAbility(self:GetCaster(), self)
end
