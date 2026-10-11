LinkLuaModifier( "modifier_foulfell_night_stalker_darkness", "ability/foulfell_night_stalker_darkness.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if foulfell_night_stalker_darkness == nil then
	foulfell_night_stalker_darkness = class({})
end

function foulfell_night_stalker_darkness:OnSpellStart()
	local caster =  self:GetCaster()
	EmitSoundOn("Hero_Nightstalker.Darkness", caster)

	local effect=ParticleManager:CreateParticle("particles/units/heroes/hero_night_stalker/nightstalker_ulti.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(effect, 0, caster, PATTACH_ABSORIGIN_FOLLOW, nil,
	caster:GetAbsOrigin(), true)
	-- ParticleManager:SetParticleControl(effect, 1, Vector(500,500,500))
	ParticleManager:ReleaseParticleIndex(effect)


	local duration = self:GetSpecialValueFor("duration")

	GameRules:BeginNightstalkerNight(duration)

	caster: AddNewModifier(caster, self, "modifier_foulfell_night_stalker_darkness", {
		duration=duration
	})

end

-------------------------------------------------------------------------------------------------------
-- modifier   ---------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
modifier_foulfell_night_stalker_darkness = class({
	IsHidden = function(self)
		return false
	end,
	IsPurgable = function(self)
		return false
	end,
	IsPurgeException = function(self)
		return true
	end,
	IsDebuff = function(self)
		return false
	end,
	IsBuff = function(self)
		return true
	end,
	RemoveOnDeath = function(self)
		return true
	end,
	GetAttributes = function(self)
		return MODIFIER_ATTRIBUTE_NONE
	end
})
function modifier_foulfell_night_stalker_darkness:AllowIllusionDuplicate()
	return false
end
function modifier_foulfell_night_stalker_darkness:OnCreated(params)
	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.bonus_damage=ability:GetSpecialValueFor("bonus_damage")
	self.bonus_move_speed=ability:GetSpecialValueFor("bonus_move_speed")
	self.bonus_attack_speed=ability:GetSpecialValueFor("bonus_attack_speed")
	if not IsServer() then return end
end
function modifier_foulfell_night_stalker_darkness:OnRefresh(params)
	self:OnCreated(params)
end
function modifier_foulfell_night_stalker_darkness:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
		-- MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE,
		-- MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE ,
	}
end


function modifier_foulfell_night_stalker_darkness:GetModifierAttackSpeedPercentage(params)
	return self.bonus_attack_speed
end

function modifier_foulfell_night_stalker_darkness:GetModifierMoveSpeedBonus_Percentage(params)
	return self.bonus_move_speed
end

-- function modifier_foulfell_night_stalker_darkness:GetActivityTranslationModifiers(params)
-- 	return "haste"
-- end

function modifier_foulfell_night_stalker_darkness:GetModifierPreAttack_BonusDamage(params)
	return self.bonus_damage
end
function modifier_foulfell_night_stalker_darkness:CheckState()
	local state = {
		[MODIFIER_STATE_FLYING]=true,

	}
	return state
end

