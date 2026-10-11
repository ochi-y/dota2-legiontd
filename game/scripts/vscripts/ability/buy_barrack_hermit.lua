LinkLuaModifier( "modifier_buy_barrack_hermit", "ability/buy_barrack_hermit.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if buy_barrack_hermit == nil then
	buy_barrack_hermit = class({})
end
function buy_barrack_hermit:OnSpellStart()
	if not IsServer() then return end
	GamePlay:buyBarrackUnit(self:GetCaster(),self)
end

function buy_barrack_hermit:OnAbilityPhaseStart()
    return GamePlay:buyBarrackUnitStart(self:GetCaster(), self)
end
function buy_barrack_hermit:onRoundUpdate()
	GamePlay:updateSendAbility(self:GetCaster(), self)
end