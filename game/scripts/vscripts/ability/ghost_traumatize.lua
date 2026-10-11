LinkLuaModifier( "modifier_ghost_traumatize", "ability/ghost_traumatize.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ghost_traumatize_tag", "ability/ghost_traumatize.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if ghost_traumatize == nil then
	ghost_traumatize = class({})
end
function ghost_traumatize:OnSpellStart()
	if not IsServer() then return end
	local caster=self:GetCaster()
	local target=self:GetCursorTarget()

	local duration=self:GetSpecialValueFor("duration_day")
	duration = duration * (1 - CalUnitStatusResistance(target))

	target:AddNewModifier(caster, self, "modifier_ghost_traumatize", {duration=duration})
	SimplePlayEffOnUnit(target,"particles/units/heroes/hero_night_stalker/nightstalker_void_hit.vpcf")
	EmitSoundOn("Hero_Nightstalker.Void", target)
end

function ghost_traumatize:OnAbilityPhaseStart()
	local caster=self:GetCaster()
	local target=self:GetCursorTarget()

	if target:HasModifier("modifier_ghost_traumatize_tag") then
		return false
	end

	target:AddNewModifier(caster, self, "modifier_ghost_traumatize_tag", {duration=1})
	return true
end
---------------------------------------------------------------------
--Modifiers
if modifier_ghost_traumatize == nil then
	modifier_ghost_traumatize = class({})
end
function modifier_ghost_traumatize:OnCreated(params)
	if IsServer() then
	end
	local ability=self:GetAbility()
	self.movespeed_slow=ability:GetSpecialValueFor("movespeed_slow")
	self.attackspeed_slow=ability:GetSpecialValueFor("attackspeed_slow")
end
function modifier_ghost_traumatize:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_ghost_traumatize:OnDestroy()
	if IsServer() then
	end
end
function modifier_ghost_traumatize:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE
	}
end
function modifier_ghost_traumatize:GetModifierMoveSpeedBonus_Percentage()
    return self.movespeed_slow
end
function modifier_ghost_traumatize:GetModifierAttackSpeedPercentage(params)
	if self:GetParent():IsAncient() then
        return self.attackspeed_slow*(100-BOSS_ATTACK_SPEED_REDUCTION_RESISTANCE)/100
	end
    return self.attackspeed_slow
end

function modifier_ghost_traumatize:GetEffectName()
	return "particles/units/heroes/hero_night_stalker/nightstalker_void.vpcf"
end
function modifier_ghost_traumatize:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

modifier_ghost_traumatize_tag = class({
IsHidden                = function(self) return true end,
IsPurgable              = function(self) return false end,
IsDebuff                = function(self) return false end,
IsBuff                  = function(self) return true end,
RemoveOnDeath           = function(self) return true end,
GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})


