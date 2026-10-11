LinkLuaModifier( "modifier_buy_barrack_gargoyle", "ability/buy_barrack_gargoyle.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if buy_barrack_gargoyle == nil then
	buy_barrack_gargoyle = class({})
end

function buy_barrack_gargoyle:OnSpellStart()
	if not IsServer() then return end
	GamePlay:buyBarrackUnit(self:GetCaster(),self)
end


function buy_barrack_gargoyle:OnAbilityPhaseStart()
    return GamePlay:buyBarrackUnitStart(self:GetCaster(), self)
end
function buy_barrack_gargoyle:onRoundUpdate()
	GamePlay:updateSendAbility(self:GetCaster(), self)
end