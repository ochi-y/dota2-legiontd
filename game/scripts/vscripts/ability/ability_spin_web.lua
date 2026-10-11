LinkLuaModifier("modifier_ability_spin_web_think", "ability/ability_spin_web.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_spin_web", "ability/ability_spin_web.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
ability_spin_web = class({})

wave_19_champion_spin_web = ability_spin_web

function ability_spin_web:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function ability_spin_web:OnSpellStart()
	local caster = self:GetCaster()
	EmitSoundOn("Hero_Broodmother.SpinWebCast", caster)
	local duration = self:GetSpecialValueFor("duration")
	local radius = self:GetSpecialValueFor("radius")


	local mod = CreateModifierThinker(self:GetCaster(), self, "modifier_ability_spin_web_think", { duration = duration },
		self:GetCastPosition(), self:GetCaster():GetTeamNumber(), false)


	local effect = ParticleManager:CreateParticle(
		"particles/econ/items/broodmother/broodmother_2022_immortal/broodmother_2022_immortal_web_spin_cast.vpcf",
		PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(effect, 0, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_attack1",
		caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(effect, 1, self:GetCastPosition())
	ParticleManager:SetParticleControl(effect, 2, Vector(radius, radius, radius))
	ParticleManager:ReleaseParticleIndex(effect)


	-- PlayEffOnUnit("particles/econ/items/broodmother/broodmother_2022_immortal/broodmother_2022_immortal_web_test.vpcf",caster,{
	-- 	bind=PATTACH_ABSORIGIN_FOLLOW,
	-- 	cps={0,1},
	-- 	--mod=self,
	-- 	cpKv={ [2]=Vector(self.radius,self.radius,self.radius)}
	-- })
end

---------------------------------------------------------------------
--Modifiers
-------------------------------------------------------------------------------------------------------
modifier_ability_spin_web_think = class({
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
function modifier_ability_spin_web_think:AllowIllusionDuplicate()
	return false
end

function modifier_ability_spin_web_think:OnCreated(params)
	local ability = self:GetAbility()
	self.radius = ability:GetSpecialValueFor("radius")

	local parent = self:GetParent()

	if not IsServer() then return end

	PlayEffOnUnit("particles/units/heroes/hero_broodmother/broodmother_web.vpcf",
		parent, {
			bind = PATTACH_ABSORIGIN_FOLLOW,
			cps = { 0 },
			mod = self,
			cpKv = {
				[1] = Vector(self.radius, self.radius, self.radius),
			}
		})
	-- PlayEffOnUnit("particles/econ/items/broodmother/broodmother_2022_immortal/broodmother_2022_immortal_web_test.vpcf",
	-- 	parent, {
	-- 	bind = PATTACH_ABSORIGIN_FOLLOW,
	-- 	cps = { 0 },
	-- 	mod = self,
	-- 	cpKv = {
	-- 		[2] = Vector(self.radius, self.radius, self.radius),
	-- 	}
	-- })

	-- PlayEffOnUnit("particles/econ/items/broodmother/broodmother_2022_immortal/broodmother_2022_immortal_web_core.vpcf",parent,{
	-- 	bind=PATTACH_ABSORIGIN_FOLLOW,
	-- 	cps={0,1},
	-- 	mod=self,
	-- 	cpKv={ [2]=Vector(self.radius,self.radius,self.radius)}
	-- })
end

function modifier_ability_spin_web_think:OnRefresh(params)
	self:OnCreated(params)
end

function modifier_ability_spin_web_think:DeclareFunctions()
	return {

	}
end

function modifier_ability_spin_web_think:CheckState()
	local state = {
	}
	return state
end

function modifier_ability_spin_web_think:IsAura()
	return true
end

function modifier_ability_spin_web_think:GetAuraRadius()
	return self.radius
end

function modifier_ability_spin_web_think:GetAuraEntityReject(unit)
	return false
end

function modifier_ability_spin_web_think:GetAuraDuration()
	return 0.3
end

function modifier_ability_spin_web_think:GetAuraSearchTeam()
	return self:GetAbility():GetAbilityTargetTeam()
end

function modifier_ability_spin_web_think:GetAuraSearchType()
	return self:GetAbility():GetAbilityTargetType()
end

function modifier_ability_spin_web_think:GetAuraSearchFlags()
	return self:GetAbility():GetAbilityTargetFlags()
end

function modifier_ability_spin_web_think:GetModifierAura()
	return "modifier_ability_spin_web"
end

-------------------------------------------------------------------------------------------------------
modifier_ability_spin_web = class({
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
function modifier_ability_spin_web:AllowIllusionDuplicate()
	return false
end

function modifier_ability_spin_web:OnCreated(params)
	local ability = self:GetAbility()
	self.heath_regen = ability:GetSpecialValueFor("heath_regen")
	self.bonus_movespeed = ability:GetSpecialValueFor("bonus_movespeed")
end

function modifier_ability_spin_web:OnRefresh(params)
	self:OnCreated(params)
end

function modifier_ability_spin_web:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
end

function modifier_ability_spin_web:GetModifierConstantHealthRegen()
	return self.heath_regen
end

function modifier_ability_spin_web:CheckState()
	local state = {
	}
	return state
end

function modifier_ability_spin_web:GetModifierMoveSpeedBonus_Percentage()
	return self.bonus_movespeed
end
