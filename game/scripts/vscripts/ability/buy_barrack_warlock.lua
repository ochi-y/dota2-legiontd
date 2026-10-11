LinkLuaModifier( "modifier_buy_barrack_warlock", "ability/buy_barrack_warlock.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if buy_barrack_warlock == nil then
	buy_barrack_warlock = class({})
end
function buy_barrack_warlock:OnSpellStart()
	if not IsServer() then return end
	GamePlay:buyBarrackUnit(self:GetCaster(),self)
end

function buy_barrack_warlock:OnAbilityPhaseStart()
    return GamePlay:buyBarrackUnitStart(self:GetCaster(), self)
end

function buy_barrack_warlock:onRoundUpdate()
	GamePlay:updateSendAbility(self:GetCaster(), self)
end