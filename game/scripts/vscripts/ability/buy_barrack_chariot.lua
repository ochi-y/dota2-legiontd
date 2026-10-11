--Abilities
if buy_barrack_chariot == nil then
	buy_barrack_chariot = class({})
end
function buy_barrack_chariot:OnSpellStart()
	if not IsServer() then return end
	GamePlay:buyBarrackUnit(self:GetCaster(),self)
end

function buy_barrack_chariot:OnAbilityPhaseStart()
    return GamePlay:buyBarrackUnitStart(self:GetCaster(), self)
end

function buy_barrack_chariot:onRoundUpdate()
	GamePlay:updateSendAbility(self:GetCaster(), self)
end