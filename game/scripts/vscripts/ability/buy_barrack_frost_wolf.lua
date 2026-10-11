LinkLuaModifier( "modifier_buy_barrack_frost_wolf", "ability/buy_barrack_frost_wolf.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if buy_barrack_frost_wolf == nil then
	buy_barrack_frost_wolf = class({})
end
function buy_barrack_frost_wolf:OnSpellStart()
	if not IsServer() then return end
	GamePlay:buyBarrackUnit(self:GetCaster(),self)
end

function buy_barrack_frost_wolf:OnAbilityPhaseStart()
    return GamePlay:buyBarrackUnitStart(self:GetCaster(), self)
end
function buy_barrack_frost_wolf:onRoundUpdate()
	GamePlay:updateSendAbility(self:GetCaster(), self)
end