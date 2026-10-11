LinkLuaModifier( "modifier_buy_barrack_behemoth", "ability/buy_barrack_behemoth.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if buy_barrack_behemoth == nil then
	buy_barrack_behemoth = class({})
end
function buy_barrack_behemoth:OnSpellStart()
	if not IsServer() then return end
	GamePlay:buyBarrackUnit(self:GetCaster(),self)
end
function buy_barrack_behemoth:OnAbilityPhaseStart()
    return GamePlay:buyBarrackUnitStart(self:GetCaster(), self)
end

function buy_barrack_behemoth:onRoundUpdate()
	GamePlay:updateSendAbility(self:GetCaster(), self)
end