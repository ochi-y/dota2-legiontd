
singed_fling = class({})

LinkLuaModifier( "modifier_singed_fling_tag", "ability/singed_fling.lua", LUA_MODIFIER_MOTION_NONE )


function singed_fling:OnAbilityPhaseStart()
	local caster=self:GetCaster()
	local target=self:GetCursorTarget()

	if target:HasModifier("modifier_singed_fling_tag") then
		return false
	end
	target:AddNewModifier(caster, self, "modifier_singed_fling_tag", {duration=1})
	return true
end

function singed_fling:GetCastAnimation()
	return ACT_DOTA_CAST_ABILITY_3
end
function singed_fling:OnSpellStart()
	local caster = self:GetCaster()
	local origin = caster:GetOrigin()
	local ability = self
	local target = self:GetCursorTarget()
	local team_id = caster:GetTeamNumber()


	EmitSoundOn("Hero_Marci.Grapple.Cast", caster)

	
	if target:TriggerSpellAbsorb( self ) then return end


	

	local duration = ability:GetSpecialValueFor("duration")
	local distance = ability:GetSpecialValueFor("distance")
	local root = ability:GetSpecialValueFor("root_duration")
	
	local basedamage = ability:GetSpecialValueFor("damage")
	local damage = basedamage
	
	local knockbackProperties =
    {
        center_x = origin.x,
        center_y = origin.y,
        center_z = origin.z,
        duration = duration * (1-target:GetStatusResistance()),
        knockback_duration = duration * (1-target:GetStatusResistance()),
        knockback_distance = -distance * (1-target:GetStatusResistance()),
        knockback_height = 150
    }
	target:AddNewModifier(caster, ability, "modifier_knockback", knockbackProperties)
	ApplyDamage({victim = target, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})
	Timers:CreateTimer(duration, function()
		if target:HasModifier("modifier_singed_mega_adhesive_debuff") then
			target:AddNewModifier(caster, ability, "modifier_rooted", {duration = root * (1-target:GetStatusResistance())})
		end

		EmitSoundOn("Hero_Marci.Grapple.Impact", target)
	end)
	return true
end

modifier_singed_fling_tag = class({
IsHidden                = function(self) return true end,
IsPurgable              = function(self) return false end,
IsDebuff                = function(self) return false end,
IsBuff                  = function(self) return true end,
RemoveOnDeath           = function(self) return true end,
GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})