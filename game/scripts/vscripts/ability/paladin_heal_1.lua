LinkLuaModifier( "modifier_paladin_heal_1_tag", "ability/paladin_heal_1.lua", LUA_MODIFIER_MOTION_NONE )

--Abilities
if paladin_heal_1 == nil then
	paladin_heal_1 = class({})
end
function paladin_heal_1:OnSpellStart()
	if not IsServer() then return end
	local caster=self:GetCaster()
	local target=self:GetCursorTarget()
	local health=self:GetSpecialValueFor("health")


	target:Purge(false, true, false, true, true)
	-- target:Heal(health, self)

	target:HealWithParams(health, self, false, true,self:GetCaster() , false)

	

	SimplePlayEffOnUnit(target,"particles/units/heroes/hero_chen/chen_hand_of_god.vpcf")
	EmitSoundOnLocationForAllies(caster:GetAbsOrigin(),"Hero_Chen.HandOfGodHealHero", caster)
	SendOverheadEventMessage( nil, OVERHEAD_ALERT_HEAL, target, health, nil )
end

modifier_paladin_heal_1_tag = class({
IsHidden                = function(self) return false end,
IsPurgable              = function(self) return false end,
IsDebuff                = function(self) return false end,
IsBuff                  = function(self) return true end,
RemoveOnDeath           = function(self) return true end,
AllowIllusionDuplicate           = function(self) return false end,
GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})
