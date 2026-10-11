LinkLuaModifier("modifier_demi_huamn_frozen_domain", "ability/demi_huamn_frozen_domain.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_demi_huamn_frozen_domain_debuff", "ability/demi_huamn_frozen_domain.lua",
	LUA_MODIFIER_MOTION_NONE)


--Abilities
if demi_huamn_frozen_domain == nil then
	demi_huamn_frozen_domain = class({})
end

function demi_huamn_frozen_domain:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function demi_huamn_frozen_domain:OnSpellStart()
	local caster = self:GetCaster()
	local pos = self:GetCursorPosition()
	local duration = self:GetSpecialValueFor("duration")
	EmitSoundOnLocationWithCaster(pos, "Hero_Lich.IceSpire", caster)

	CreateModifierThinker(caster, self, "modifier_demi_huamn_frozen_domain", {
		duration = duration
	}, pos, caster:GetTeamNumber(), false)
end

---------------------------------------------------------------------
--Modifiers
-------------------------------------------------------------------------------------------------------
modifier_demi_huamn_frozen_domain = class({
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
function modifier_demi_huamn_frozen_domain:AllowIllusionDuplicate()
	return false
end

function modifier_demi_huamn_frozen_domain:OnCreated(params)
	if not self:GetAbility() then return end
	local ability = self:GetAbility()
	self.radius = ability:GetSpecialValueFor("radius")
	if not IsServer() then return end
	local parent = self:GetParent()
	local pos = parent:GetAbsOrigin()
	PlayEffOnUnit(
		"particles/units/heroes/hero_lich/lich_ice_spire.vpcf",
		parent,
		{
			mod = self,
			cpKv = {
				[1] = Vector(pos.x, pos.y, pos.z + 142),
				[2] = Vector(pos.x, pos.y, pos.z + 213),
				[3] = Vector(pos.x, pos.y, pos.z + 1),
				[4] = Vector(pos.x, pos.y, pos.z + 1),
				[5] = Vector(self.radius, self.radius, self.radius)
			},
		}
	)
end

function modifier_demi_huamn_frozen_domain:OnRefresh(params)
	if not self:GetAbility() then return end
	local ability = self:GetAbility()
	self.radius = ability:GetSpecialValueFor("radius")
end

function modifier_demi_huamn_frozen_domain:DeclareFunctions()
	return {
	}
end

function modifier_demi_huamn_frozen_domain:IsAura()
	return true
end

function modifier_demi_huamn_frozen_domain:GetAuraRadius()
	return self.radius
end

function modifier_demi_huamn_frozen_domain:GetAuraEntityReject(unit)
	return false
end

function modifier_demi_huamn_frozen_domain:GetAuraDuration()
	return 0
end

function modifier_demi_huamn_frozen_domain:GetAuraSearchTeam()
	return self:GetAbility():GetAbilityTargetTeam()
end

function modifier_demi_huamn_frozen_domain:GetAuraSearchType()
	return self:GetAbility():GetAbilityTargetType()
end

function modifier_demi_huamn_frozen_domain:GetAuraSearchFlags()
	return self:GetAbility():GetAbilityTargetFlags()
end

function modifier_demi_huamn_frozen_domain:GetModifierAura()
	return "modifier_demi_huamn_frozen_domain_debuff"
end

-------------------------------------------------------------------------------------------------------
modifier_demi_huamn_frozen_domain_debuff = class({
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
function modifier_demi_huamn_frozen_domain_debuff:AllowIllusionDuplicate()
	return false
end

function modifier_demi_huamn_frozen_domain_debuff:OnCreated(params)
	if not self:GetAbility() then return end
	local ability = self:GetAbility()
	self.move_slow = ability:GetSpecialValueFor("move_slow")
	self.attack_slow = ability:GetSpecialValueFor("attack_slow")
	self.regen_reduction = ability:GetSpecialValueFor("regen_reduction")
	if not IsServer() then return end
end

function modifier_demi_huamn_frozen_domain_debuff:OnRefresh(params)
	self:OnCreated(params)
end

function modifier_demi_huamn_frozen_domain_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE,
		MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
		MODIFIER_PROPERTY_SPELL_LIFESTEAL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_LIFESTEAL_AMPLIFY_PERCENTAGE
	}
end

function modifier_demi_huamn_frozen_domain_debuff:GetModifierMoveSpeedBonus_Percentage()
	return -self.move_slow
end

function modifier_demi_huamn_frozen_domain_debuff:GetModifierAttackSpeedPercentage(params)
	if self:GetParent():IsAncient() then
		return -self.attack_slow * (100 - BOSS_ATTACK_SPEED_REDUCTION_RESISTANCE) / 100
	end
	return -self.attack_slow
end

function modifier_demi_huamn_frozen_domain_debuff:GetModifierHealAmplify_PercentageTarget(params)
	return -1 * self.regen_reduction
end

function modifier_demi_huamn_frozen_domain_debuff:GetModifierSpellLifestealRegenAmplify_Percentage(params)
	return -1 * self.regen_reduction
end

function modifier_demi_huamn_frozen_domain_debuff:GetModifierHPRegenAmplify_Percentage(params)
	return -1 * self.regen_reduction
end

function modifier_demi_huamn_frozen_domain_debuff:GetModifierLifestealRegenAmplify_Percentage(params)
	return -1 * self.regen_reduction
end
