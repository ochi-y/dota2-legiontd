--Abilities
if buy_barrack_pudge == nil then
	buy_barrack_pudge = class({})
end
function buy_barrack_pudge:OnSpellStart()
	if not IsServer() then return end
	GamePlay:buyBarrackUnit(self:GetCaster(),self)
end

function buy_barrack_pudge:OnAbilityPhaseStart()
    return GamePlay:buyBarrackUnitStart(self:GetCaster(), self)
end
function buy_barrack_pudge:onRoundUpdate()
	GamePlay:updateSendAbility(self:GetCaster(), self)
end