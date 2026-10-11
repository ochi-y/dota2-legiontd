--Abilities
if upgrade_shadow_hades == nil then
	upgrade_shadow_hades = class({})
end

function upgrade_shadow_hades:OnAbilityPhaseStart()
	if not IsServer() then return end

	return legionOnAbilityPhaseStart(self:GetCaster(),self)
end

function upgrade_shadow_hades:OnSpellStart()
	if not IsServer() then return end
	legionUpgradeBuilding(self:GetCaster(),self)
end

