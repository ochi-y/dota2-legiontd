--Abilities
if buy_barrack_furbolg == nil then
	buy_barrack_furbolg = class({})
end
function buy_barrack_furbolg:OnSpellStart()
	if not IsServer() then return end
	GamePlay:buyBarrackUnit(self:GetCaster(),self)
end

function buy_barrack_furbolg:OnAbilityPhaseStart()
    return GamePlay:buyBarrackUnitStart(self:GetCaster(), self)
end
function buy_barrack_furbolg:onRoundUpdate()
	GamePlay:updateSendAbility(self:GetCaster(), self)
end