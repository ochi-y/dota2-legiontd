--Abilities
if upgrade_undead_necrolyte == nil then
	upgrade_undead_necrolyte = class({})
end

function upgrade_undead_necrolyte:OnAbilityPhaseStart()
	if not IsServer() then return end
	return legionOnAbilityPhaseStart(self:GetCaster(),self)
end

function upgrade_undead_necrolyte:OnSpellStart()
	if not IsServer() then return end
	legionUpgradeBuilding(self:GetCaster(),self)
end
