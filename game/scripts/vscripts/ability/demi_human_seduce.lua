LinkLuaModifier( "modifier_demi_human_seduce", "ability/demi_human_seduce.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_demi_human_seduce_tag", "ability/demi_human_seduce.lua", LUA_MODIFIER_MOTION_NONE )

--Abilities
if demi_human_seduce == nil then
	demi_human_seduce = class({})
end
function demi_human_seduce:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function demi_human_seduce:OnSpellStart()
	local eff="particles/units/heroes/hero_queenofpain/queen_blink_shard_start.vpcf"
	local pos=self:GetCursorPosition()
	local caster=self:GetCaster()
	local params={}
	local radius=self:GetSpecialValueFor("radius")
	local duration=self:GetSpecialValueFor("duration")

	params[2]=Vector(radius,0,0)
	SimplePlayEffAtlocation(eff,caster:GetAbsOrigin(),{0, 1, 2, 3, 4},params)
	SimplePlayEffAtlocation("particles/units/heroes/hero_queenofpain/queen_blink_shard_end.vpcf",pos,{0, 1, 2, 3, 4},params)
	EmitSoundOnLocationWithCaster(pos,"Hero_QueenOfPain.Blink_in.Shard",self:GetCaster())
	local units=SimpleFindEnemy(caster:GetTeamNumber(), pos, radius, nil)
	for key, unit in pairs(units) do
		local realDuration = duration * (1 - CalUnitStatusResistance(unit))
		unit:AddNewModifier(caster, self, "modifier_demi_human_seduce", {duration=realDuration})
	end
	FindClearSpaceForUnit(caster, pos, true)
end
---------------------------------------------------------------------
--Modifiers
modifier_demi_human_seduce = class({
IsHidden                = function(self) return false end,
IsPurgable              = function(self) return false end,
IsDebuff                = function(self) return true end,
IsBuff                  = function(self) return false end,
RemoveOnDeath           = function(self) return true end,
GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})
function modifier_demi_human_seduce:OnCreated(params)
	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.miss=ability:GetSpecialValueFor("miss")
	
	if IsServer() then
	end
end
function modifier_demi_human_seduce:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_demi_human_seduce:OnDestroy()
	if IsServer() then
	end
end
function modifier_demi_human_seduce:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MISS_PERCENTAGE
	}
end
function modifier_demi_human_seduce:GetModifierMiss_Percentage()
	return self.miss
end

modifier_demi_human_seduce_tag = class({
IsHidden                = function(self) return true end,
IsPurgable              = function(self) return false end,
IsDebuff                = function(self) return false end,
IsBuff                  = function(self) return true end,
RemoveOnDeath           = function(self) return true end,
AllowIllusionDuplicate           = function(self) return false end,
GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})