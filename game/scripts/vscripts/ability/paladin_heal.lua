LinkLuaModifier( "modifier_paladin_heal_tag", "ability/paladin_heal.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if paladin_heal == nil then
	paladin_heal = class({})
end
function paladin_heal:OnSpellStart()
	if not IsServer() then return end
	local caster=self:GetCaster()
	local target=self:GetCursorTarget()

	
	local health=self:GetSpecialValueFor("health")



	-- target:Heal(health, self)

	target:HealWithParams(health, self, false, true,self:GetCaster() , false)

	SimplePlayEffOnUnit(target,"particles/neutral_fx/troll_heal.vpcf")
	EmitSoundOn("n_creep_ForestTrollHighPriest.Heal", target)

	SendOverheadEventMessage( nil, OVERHEAD_ALERT_HEAL, target, health, nil )
	
end

modifier_paladin_heal_tag = class({
IsHidden                = function(self) return false end,
IsPurgable              = function(self) return false end,
IsDebuff                = function(self) return false end,
IsBuff                  = function(self) return true end,
RemoveOnDeath           = function(self) return true end,
AllowIllusionDuplicate           = function(self) return false end,
GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})