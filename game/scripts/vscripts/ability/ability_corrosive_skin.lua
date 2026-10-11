ability_corrosive_skin = class({})
LinkLuaModifier( "modifier_ability_corrosive_skin", "ability/ability_corrosive_skin", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ability_corrosive_skin_debuff", "ability/ability_corrosive_skin", LUA_MODIFIER_MOTION_NONE )


wave_13_champion_corrosive_skin=ability_corrosive_skin
--------------------------------------------------------------------------------
-- Passive Modifier
function ability_corrosive_skin:GetIntrinsicModifierName()
	return "modifier_ability_corrosive_skin"
end

--------------------------------------------------------------------------------
modifier_ability_corrosive_skin = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_ability_corrosive_skin:IsHidden()
	return true
end

function modifier_ability_corrosive_skin:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_ability_corrosive_skin:OnCreated( kv )
	-- references
	self.duration = self:GetAbility():GetSpecialValueFor( "duration" )
	self.max_range = self:GetAbility():GetSpecialValueFor( "max_range" )
	self.magic_resist = self:GetAbility():GetSpecialValueFor( "bonus_magic_resistance" )
end

function modifier_ability_corrosive_skin:OnRefresh( kv )
	-- references
	self.duration = self:GetAbility():GetSpecialValueFor( "duration" )
	self.max_range = self:GetAbility():GetSpecialValueFor( "max_range" )
	self.magic_resist = self:GetAbility():GetSpecialValueFor( "bonus_magic_resistance" )
end

function modifier_ability_corrosive_skin:OnRemoved()
end

function modifier_ability_corrosive_skin:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_ability_corrosive_skin:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,

		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}

	return funcs
end

function modifier_ability_corrosive_skin:GetModifierMagicalResistanceBonus()
	if not self:GetParent():PassivesDisabled() then
		return self.magic_resist
	end
end

function modifier_ability_corrosive_skin:OnTakeDamage( params )
	if not IsServer() then return end

	-- filter
	if params.unit~=self:GetParent() then return end
	if self:GetParent():PassivesDisabled() then return end
	if params.attacker:GetTeamNumber()==self:GetParent():GetTeamNumber() then return end

	-- check distance
	local distance = (params.attacker:GetOrigin()-params.unit:GetOrigin()):Length2D()
	if distance>self.max_range then return end

	-- add debuff
	params.attacker:AddNewModifier(
		self:GetParent(), -- player source
		self:GetAbility(), -- ability source
		"modifier_ability_corrosive_skin_debuff", -- modifier name
		{ duration = self.duration } -- kv
	)

	-- play effects
	local sound_cast = "hero_viper.CorrosiveSkin"
	EmitSoundOn( sound_cast, params.attacker )
end
-- Created by Elfansoer
--[[
Ability checklist (erase if done/checked):
- Scepter Upgrade
- Break behavior
- Linken/Reflect behavior
- Spell Immune/Invulnerable/Invisible behavior
- Illusion behavior
- Stolen behavior
]]
--------------------------------------------------------------------------------
modifier_ability_corrosive_skin_debuff = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_ability_corrosive_skin_debuff:IsHidden()
	return false
end

function modifier_ability_corrosive_skin_debuff:IsDebuff()
	return true
end

function modifier_ability_corrosive_skin_debuff:IsStunDebuff()
	return false
end

function modifier_ability_corrosive_skin_debuff:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_ability_corrosive_skin_debuff:OnCreated( kv )
	-- references
	self.attack_slow = self:GetAbility():GetSpecialValueFor( "attack_slow" )
	self.move_slow = self:GetAbility():GetSpecialValueFor( "move_slow" )

	local damage = self:GetAbility():GetSpecialValueFor( "damage" )

	if not IsServer() then return end
	-- precache damage
	self.damageTable = {
		victim = self:GetParent(),
		attacker = self:GetCaster(),
		damage = damage,
		damage_type = self:GetAbility():GetAbilityDamageType(),
		ability = self:GetAbility(), --Optional.
		damage_flags = DOTA_DAMAGE_FLAG_REFLECTION, --Optional.
	}

	-- Start interval
	self:StartIntervalThink( 1 )
end

function modifier_ability_corrosive_skin_debuff:OnRefresh( kv )
	-- references
	self.attack_slow = self:GetAbility():GetSpecialValueFor( "attack_slow" )
	self.move_slow = self:GetAbility():GetSpecialValueFor( "move_slow" )
	local damage = self:GetAbility():GetSpecialValueFor( "damage" )

	if not IsServer() then return end
	-- update damage
	self.damageTable.damage = damage
end

function modifier_ability_corrosive_skin_debuff:OnRemoved()
end

function modifier_ability_corrosive_skin_debuff:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_ability_corrosive_skin_debuff:DeclareFunctions()
	local funcs = {
		-- MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,

		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE
	}

	return funcs
end

function modifier_ability_corrosive_skin_debuff:GetModifierAttackSpeedPercentage()
	return -self.attack_slow
end
function modifier_ability_corrosive_skin_debuff:GetModifierMoveSpeedBonus_Percentage()
	return -self.move_slow
end
--------------------------------------------------------------------------------
-- Interval Effects
function modifier_ability_corrosive_skin_debuff:OnIntervalThink()
	-- Apply damage
	ApplyDamage( self.damageTable )
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_ability_corrosive_skin_debuff:GetEffectName()
	return "particles/units/heroes/hero_viper/viper_corrosive_debuff.vpcf"
end

function modifier_ability_corrosive_skin_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
