LinkLuaModifier( "modifier_buy_barrack_infernal", "ability/buy_barrack_infernal.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if buy_barrack_infernal == nil then
	buy_barrack_infernal = class({})
end
function buy_barrack_infernal:OnSpellStart()
	if not IsServer() then return end
	GamePlay:buyBarrackUnit(self:GetCaster(),self)
end

function buy_barrack_infernal:OnAbilityPhaseStart()
    return GamePlay:buyBarrackUnitStart(self:GetCaster(), self)
end
function buy_barrack_infernal:onRoundUpdate()
	GamePlay:updateSendAbility(self:GetCaster(), self)
end