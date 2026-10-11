LinkLuaModifier( "modifier_buy_barrack_pandaren", "ability/buy_barrack_pandaren.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if buy_barrack_pandaren == nil then
	buy_barrack_pandaren = class({})
end
function buy_barrack_pandaren:OnSpellStart()
	if not IsServer() then return end
	GamePlay:buyBarrackUnit(self:GetCaster(),self)
end

function buy_barrack_pandaren:OnAbilityPhaseStart()
    return GamePlay:buyBarrackUnitStart(self:GetCaster(), self)
end


function buy_barrack_pandaren:onRoundUpdate()
	GamePlay:updateSendAbility(self:GetCaster(), self)
end
