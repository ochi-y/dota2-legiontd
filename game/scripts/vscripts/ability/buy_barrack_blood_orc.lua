--Abilities
if buy_barrack_blood_orc == nil then
	buy_barrack_blood_orc = class({})
end
function buy_barrack_blood_orc:OnSpellStart()
	if not IsServer() then return end
	GamePlay:buyBarrackUnit(self:GetCaster(),self)
end

function buy_barrack_blood_orc:OnAbilityPhaseStart()
    return GamePlay:buyBarrackUnitStart(self:GetCaster(), self)
end
function buy_barrack_blood_orc:onRoundUpdate()
	GamePlay:updateSendAbility(self:GetCaster(), self)
end