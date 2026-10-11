LinkLuaModifier("modifier_radiant_kez_talon_toss", "ability/radiant_kez_talon_toss.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_radiant_kez_talon_toss_debuff", "ability/radiant_kez_talon_toss.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if radiant_kez_talon_toss == nil then
	radiant_kez_talon_toss = class({})
end
function radiant_kez_talon_toss:GetIntrinsicModifierName()
	return "modifier_radiant_kez_talon_toss"
end

-------------------------------------------------------------------------------------------------------
-- modifier   ---------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
modifier_radiant_kez_talon_toss = class({
	IsHidden = function(self)
		return false
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
function modifier_radiant_kez_talon_toss:AllowIllusionDuplicate()
	return false
end

function modifier_radiant_kez_talon_toss:OnCreated(params)
	if not self:GetAbility() then return end
	local ability = self:GetAbility()
	self.chance = ability:GetSpecialValueFor("chance")
	self.duration = ability:GetSpecialValueFor("duration")
	self.radius = ability:GetSpecialValueFor("radius")
	self.damage = ability:GetSpecialValueFor("damage")
	if not IsServer() then return end
	-- self.damage = params.damage
	-- self:SetHasCustomTransmitterData(true)
end

function modifier_radiant_kez_talon_toss:OnRefresh(params)
	self:OnCreated(params)
end

function modifier_radiant_kez_talon_toss:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND,
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
		MODIFIER_EVENT_ON_ATTACK_LANDED,


	}
end

function modifier_radiant_kez_talon_toss:OnAttackLanded(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end

	local target = params.target


	local caster = self:GetCaster()
	if RandomInt(1, 100) <= self.chance then
		EmitSoundOn("Hero_Kez.TalonToss.Target", target)
		local effect = ParticleManager:CreateParticle("particles/units/heroes/hero_kez/kez_sai_toss_impact.vpcf",
			PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:SetParticleControlEnt(effect, 0, target, PATTACH_ABSORIGIN, nil,
			target:GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(effect, 1, Vector(self.radius, 0, 0))
		ParticleManager:ReleaseParticleIndex(effect)

		local units = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, self.radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
			DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)

		for index, unit in ipairs(units) do
			unit:AddNewModifier(caster, self:GetAbility(), "modifier_radiant_kez_talon_toss_debuff", {
				duration = self.duration
			})
			SimpleApplyDamage(self:GetAbility(), caster, unit, self.damage)
		end
	end
end

function modifier_radiant_kez_talon_toss:GetActivityTranslationModifiers(params)
	return "kunai"
end

function modifier_radiant_kez_talon_toss:GetAttackSound()
	return "Hero_Kez.TalonToss.Cast"
end

function modifier_radiant_kez_talon_toss:CheckState()
	local state = {
	}

	return state
end

-------------------------------------------------------------------------------------------------------
-- modifier   ---------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
modifier_radiant_kez_talon_toss_debuff = class({
	IsHidden = function(self)
		return false
	end,
	IsPurgable = function(self)
		return true
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
function modifier_radiant_kez_talon_toss_debuff:AllowIllusionDuplicate()
	return false
end

function modifier_radiant_kez_talon_toss_debuff:OnCreated(params)
	if not self:GetAbility() then return end
	local ability = self:GetAbility()
	self.goldCost = ability:GetSpecialValueFor("goldCost")
	if not IsServer() then return end
	-- self.damage = params.damage
	-- self:SetHasCustomTransmitterData(true)
end

function modifier_radiant_kez_talon_toss_debuff:OnRefresh(params)
	self:OnCreated(params)
end

function modifier_radiant_kez_talon_toss_debuff:DeclareFunctions()
	return {

	}
end

function modifier_radiant_kez_talon_toss_debuff:CheckState()
	local state = {
		[MODIFIER_STATE_SILENCED] = true,

	}
	return state
end
function modifier_radiant_kez_talon_toss_debuff:GetEffectName()
	return "particles/units/heroes/hero_kez/kez_silenced.vpcf"
end
function modifier_radiant_kez_talon_toss_debuff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end
