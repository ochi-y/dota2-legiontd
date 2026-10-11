LinkLuaModifier( "modifier_shadow_decrepify", "ability/shadow_decrepify", LUA_MODIFIER_MOTION_NONE )
--Abilities
if shadow_decrepify == nil then
	shadow_decrepify = class({})
end

function shadow_decrepify:OnSpellStart()
	local caster=self:GetCaster()
	local target=self:GetCursorTarget()
	
	local eff="particles/units/heroes/hero_necrolyte/necrolyte_death_seeker_enemy.vpcf"
	SimpleTrackingProjectile(self, self:GetCaster(), target, eff, 1500)
	EmitSoundOn( "Hero_Necrolyte.DeathSeeker",caster )
end

function shadow_decrepify:OnProjectileHit( hTarget, vLocation )
	if hTarget ~= nil and ( not hTarget:IsInvulnerable() ) and ( not hTarget:TriggerSpellAbsorb( self ) ) then
		EmitSoundOn( "DOTA_Item.GhostScepter.Activate", hTarget )
		local duration=self:GetSpecialValueFor("duration")
		local caster=self:GetCaster()
		hTarget:AddNewModifier(self:GetCaster(), self, "modifier_shadow_decrepify", {duration=duration})
	end
	return true
end
---------------------------------------------------------------------
--Modifiers
-------------------------------------------------------------------------------------------------------
modifier_shadow_decrepify = class({
	IsHidden = function(self)
		return false
	end,
	IsPurgable = function(self)
		return false
	end,
	IsDebuff = function(self)
		return true
	end,
	IsBuff = function(self)
		return false
	end,
	RemoveOnDeath = function(self)
		return true
	end,
	GetAttributes = function(self)
		return MODIFIER_ATTRIBUTE_NONE
	end
})
function modifier_shadow_decrepify:AllowIllusionDuplicate()
	return false
end
function modifier_shadow_decrepify:OnCreated(params)
	-- self.damage = params.damage
	-- self:SetHasCustomTransmitterData(true) 
	local ability=self:GetAbility()
	self.move_slow=ability:GetSpecialValueFor("move_slow")
	self.extra_spell_damage_percent=ability:GetSpecialValueFor("extra_spell_damage_percent")
end
function modifier_shadow_decrepify:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_DECREPIFY_UNIQUE,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL
	}
end
function modifier_shadow_decrepify:CheckState()
	local state = {
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
		[MODIFIER_STATE_DISARMED] = true
	}
	return state
end
function modifier_shadow_decrepify:GetModifierMagicalResistanceDecrepifyUnique()
    return self.extra_spell_damage_percent
end

function modifier_shadow_decrepify:GetAbsoluteNoDamagePhysical()
	return 1
end
function modifier_shadow_decrepify:GetModifierMoveSpeedBonus_Percentage()
	return -self.move_slow
end
-- function modifier_shadow_decrepify:GetStatusEffectName()
-- 	return "particles/status_fx/status_effect_ghost.vpcf"
-- end

function modifier_shadow_decrepify:GetEffectName()
	return "particles/units/heroes/hero_pugna/pugna_decrepify.vpcf"
end
function modifier_shadow_decrepify:GetEffectAttachType()
	return PATTACH_POINT_FOLLOW
end



