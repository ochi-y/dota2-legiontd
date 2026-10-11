LinkLuaModifier( "modifier_buy_barrack_ghoul", "ability/buy_barrack_ghoul.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if buy_barrack_ghoul == nil then
	buy_barrack_ghoul = class({})
end
function buy_barrack_ghoul:OnSpellStart()
	if not IsServer() then return end
	GamePlay:buyBarrackUnit(self:GetCaster(),self)
end

function buy_barrack_ghoul:OnAbilityPhaseStart()
    return GamePlay:buyBarrackUnitStart(self:GetCaster(), self)
end
function buy_barrack_ghoul:onRoundUpdate()
	GamePlay:updateSendAbility(self:GetCaster(), self)
end