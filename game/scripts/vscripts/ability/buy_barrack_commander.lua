LinkLuaModifier( "modifier_buy_barrack_commander", "ability/buy_barrack_commander.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if buy_barrack_commander == nil then
	buy_barrack_commander = class({})
end
function buy_barrack_commander:OnSpellStart()
	if not IsServer() then return end
	GamePlay:buyBarrackUnit(self:GetCaster(),self)
end


function buy_barrack_commander:OnAbilityPhaseStart()
    return GamePlay:buyBarrackUnitStart(self:GetCaster(), self)
end

function buy_barrack_commander:onRoundUpdate()
	GamePlay:updateSendAbility(self:GetCaster(), self)
end