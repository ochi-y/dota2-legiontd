paladin_windrun = class({
	GetIntrinsicModifierName = function() return "modifier_paladin_windrun_autocast" end
})
LinkLuaModifier("modifier_paladin_windrun", "ability/paladin_windrun", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_paladin_windrun_debuff", "ability/paladin_windrun", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_paladin_windrun_autocast", "ability/paladin_windrun", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------
-- Ability Start
function paladin_windrun:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()

	-- load data
	local duration = self:GetSpecialValueFor("duration")

	-- add modifier
	caster:AddNewModifier(
		caster,               -- player source
		self,                 -- ability source
		"modifier_paladin_windrun", -- modifier name
		{ duration = duration } -- kv
	)

	-- Play effects
	local sound_cast = "Ability.Windrun"
	EmitSoundOn(sound_cast, caster)
end

modifier_paladin_windrun = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_paladin_windrun:IsHidden()
	return false
end

function modifier_paladin_windrun:IsDebuff()
	return false
end

function modifier_paladin_windrun:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_paladin_windrun:OnCreated(kv)
	-- references
	self.radius = self:GetAbility():GetSpecialValueFor("radius")
	self.evasion = self:GetAbility():GetSpecialValueFor("evasion_pct_tooltip")
	self.ms_bonus = self:GetAbility():GetSpecialValueFor("movespeed_bonus_pct")

	self.aura_duration = 2.5
end

function modifier_paladin_windrun:OnRefresh(kv)
	-- same as oncreated
	self:OnCreated(kv)
end

function modifier_paladin_windrun:OnRemoved()
end

function modifier_paladin_windrun:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_paladin_windrun:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_EVASION_CONSTANT,
	}

	return funcs
end

--
function modifier_paladin_windrun:GetModifierMoveSpeedBonus_Percentage()
	return self.ms_bonus
end

--
function modifier_paladin_windrun:GetModifierEvasion_Constant()
	return self.evasion
end

--
function modifier_paladin_windrun:CheckState()
	local state = {
		[MODIFIER_STATE_LOW_ATTACK_PRIORITY] = true,
	}
	return state
end

--------------------------------------------------------------------------------
-- Aura Effects
function modifier_paladin_windrun:IsAura()
	return true
end

function modifier_paladin_windrun:GetModifierAura()
	return "modifier_paladin_windrun_debuff"
end

function modifier_paladin_windrun:GetAuraRadius()
	return self.radius
end

function modifier_paladin_windrun:GetAuraDuration()
	return self.aura_duration
end

function modifier_paladin_windrun:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_paladin_windrun:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_paladin_windrun:GetEffectName()
	return "particles/units/heroes/hero_windrunner/windrunner_windrun.vpcf"
end

function modifier_paladin_windrun:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

modifier_paladin_windrun_debuff = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_paladin_windrun_debuff:IsHidden()
	return true
end

function modifier_paladin_windrun_debuff:IsDebuff()
	return true
end

function modifier_paladin_windrun_debuff:IsStunDebuff()
	return false
end

function modifier_paladin_windrun_debuff:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_paladin_windrun_debuff:OnCreated(kv)
	-- references
	self.slow = self:GetAbility():GetSpecialValueFor("enemy_movespeed_bonus_pct")
end

function modifier_paladin_windrun_debuff:OnRefresh(kv)
	-- references
	self.slow = self:GetAbility():GetSpecialValueFor("enemy_movespeed_bonus_pct")
end

function modifier_paladin_windrun_debuff:OnRemoved()
end

function modifier_paladin_windrun_debuff:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_paladin_windrun_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}

	return funcs
end

function modifier_paladin_windrun_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_paladin_windrun_debuff:GetEffectName()
	return "particles/units/heroes/hero_windrunner/windrunner_windrun_slow.vpcf"
end

function modifier_paladin_windrun_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

-------------------------------------------------------------------------------------------------------
modifier_paladin_windrun_autocast = class({
	IsHidden = function(self)
		return true
	end,
	IsPurgable = function(self)
		return false
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
function modifier_paladin_windrun_autocast:AllowIllusionDuplicate()
	return false
end

function modifier_paladin_windrun_autocast:OnCreated(params)
	if not self:GetAbility() then return end
	local ability = self:GetAbility()
	if not IsServer() then return end
end

function modifier_paladin_windrun_autocast:OnRefresh(params)
	self:OnCreated(params)
end

function modifier_paladin_windrun_autocast:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}
end

function modifier_paladin_windrun_autocast:OnTakeDamage(params)
	if not IsServer() then return end
	-- filter
	if params.unit ~= self:GetParent() then return end
	if params.attacker:GetTeamNumber() == self:GetParent():GetTeamNumber() then return end
	local parent = self:GetParent()
	if params.damage_category~=DOTA_DAMAGE_CATEGORY_ATTACK  then
		return
	end

	local ability=self:GetAbility()

	if params.damage > 5 and ability then
		if ability:IsFullyCastable() then
			parent:CastAbilityNoTarget(ability, -1)
		end
	end
end


