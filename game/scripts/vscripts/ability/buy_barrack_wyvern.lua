--Abilities
if buy_barrack_wyvern == nil then
	buy_barrack_wyvern = class({})
end
function buy_barrack_wyvern:OnSpellStart()
	if not IsServer() then return end
	GamePlay:buyBarrackUnit(self:GetCaster(),self)
end

function buy_barrack_wyvern:OnAbilityPhaseStart()
    return GamePlay:buyBarrackUnitStart(self:GetCaster(), self)
end


function buy_barrack_wyvern:onRoundUpdate()
	GamePlay:updateSendAbility(self:GetCaster(), self)
end