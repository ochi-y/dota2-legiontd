LinkLuaModifier("modifier_undead_burning_oil", "ability/undead_burning_oil", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_undead_burning_oil_think", "ability/undead_burning_oil", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_undead_burning_oil_think_burn", "ability/undead_burning_oil", LUA_MODIFIER_MOTION_NONE)
-- Abilities
if undead_burning_oil == nil then
	undead_burning_oil = class({})
end

function undead_burning_oil:GetIntrinsicModifierName()
	return "modifier_undead_burning_oil"
end

-- function undead_burning_oil:OnSpellStart()
-- 	local point = self:GetCursorPosition()
-- 	local caster = self:GetCaster()
-- 	self.thinker = CreateModifierThinker(caster, -- player source
-- 		self,                                    -- ability source
-- 		"modifier_undead_burning_oil",             -- modifier name
-- 		{
-- 			duration = 20
-- 		}, -- kv
-- 		point, caster:GetTeamNumber(), false)
-- 	local eff = "particles/econ/events/ti9/rock_golem_tower/dire_tower_attack.vpcf"
-- 	SimpleTrackingProjectile(self, self:GetCaster(), self.thinker, eff, 1600)
-- 	EmitSoundOn("Hero_AbyssalUnderlord.Firestorm.Cast", caster)
-- end

-- function undead_burning_oil:OnProjectileHit(hTarget, vLocation)
-- 	if hTarget ~= nil and IsActiveUnit(self.thinker) then
-- 		EmitSoundOn("Hero_Phoenix.FireSpirits.Target", hTarget)
-- 		local duration = self:GetSpecialValueFor("duration")
-- 		local caster = self:GetCaster()
-- 		hTarget:AddNewModifier(self.thinker, self, "modifier_undead_burning_oil_think", {
-- 			duration = duration
-- 		})
-- 		local radius = self:GetSpecialValueFor("radius")
-- 		local damage = self:GetSpecialValueFor("damage")

-- 		local units = SimpleFindEnemy(caster:GetTeamNumber(), vLocation, radius, FIND_CLOSEST)
-- 		for _, enemy in ipairs(units) do
-- 			SimpleApplyDamage(self, caster, enemy, damage)
-- 		end
-- 	end
-- 	return true
-- end

-- function undead_burning_oil:GetAOERadius()
--     return self:GetSpecialValueFor("radius")
-- end

modifier_undead_burning_oil = class({
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
function modifier_undead_burning_oil:AllowIllusionDuplicate()
	return false
end

function modifier_undead_burning_oil:OnCreated(params)
	if not self:GetAbility() then return end
	local ability = self:GetAbility()
	self.duration = ability:GetSpecialValueFor("duration")
	if not IsServer() then return end
	-- self.damage = params.damage
	-- self:SetHasCustomTransmitterData(true)
end

function modifier_undead_burning_oil:OnRefresh(params)
	self:OnCreated(params)
end

function modifier_undead_burning_oil:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_PROJECTILE_NAME 
	}
end

function modifier_undead_burning_oil:GetModifierProjectileName()
	return "particles/econ/items/dragon_knight/dk_2022_immortal/dk_2022_immortal_dragon_tail_dragon_projectile.vpcf"
end

function modifier_undead_burning_oil:OnAttackLanded(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	local target = params.target

	local caster = self:GetCaster()

	EmitSoundOn("Hero_Phoenix.FireSpirits.Target", target)

	self.thinker = CreateModifierThinker(caster, -- player source
		self:GetAbility(),                                 -- ability source
		"modifier_undead_burning_oil_think",    -- modifier name
		{
			duration = self.duration
		}, -- kv
		target:GetAbsOrigin(), caster:GetTeamNumber(), false)
end

-------------------------------------------------------------------------------------------------------
modifier_undead_burning_oil_think = class({
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

function modifier_undead_burning_oil_think:AllowIllusionDuplicate()
	return false
end

function modifier_undead_burning_oil_think:GetEffectName()
	return "particles/war3/war3_burning_oilphoenix/phoenix_ti10_immortal/phoenix_ti10_fire_spirit_ground.vpcf"
end

function modifier_undead_burning_oil_think:GetEffectAttachType()
	return PATTACH_POINT_FOLLOW
end

function modifier_undead_burning_oil_think:OnCreated(params)
	if not self:GetAbility() then return end
	local ability = self:GetAbility()
	self.radius = ability:GetSpecialValueFor("radius")
	self.debuff_duration = ability:GetSpecialValueFor("debuff_duration")
end

function modifier_undead_burning_oil_think:OnRefresh(params)
end

function modifier_undead_burning_oil_think:IsAura()
	return true
end

function modifier_undead_burning_oil_think:GetAuraRadius()
	return self.radius
end

function modifier_undead_burning_oil_think:GetAuraEntityReject(unit)
	if unit:HasFlyMovementCapability() then
		return true
	end
	return false
end

function modifier_undead_burning_oil_think:GetAuraDuration()
	return self.debuff_duration
end

function modifier_undead_burning_oil_think:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_undead_burning_oil_think:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING
end

function modifier_undead_burning_oil_think:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_undead_burning_oil_think:GetModifierAura()
	return "modifier_undead_burning_oil_think_burn"
end

modifier_undead_burning_oil_think_burn = class({
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
function modifier_undead_burning_oil_think_burn:OnCreated()
	local ability = self:GetAbility()
	self.burn_dps = ability:GetSpecialValueFor("burn_dps")
	local internal = 0.5
	self.damage = self.burn_dps * internal
	if not IsServer() then return end
	self:StartIntervalThink(internal)
end

function modifier_undead_burning_oil_think_burn:GetEffectName()
	return "particles/units/heroes/hero_invoker/invoker_chaos_meteor_burn_debuff.vpcf"
end

function modifier_undead_burning_oil_think_burn:GetEffectAttachType()
	return PATTACH_POINT_FOLLOW
end

function modifier_undead_burning_oil_think_burn:OnIntervalThink()
	if not IsServer() then return end
	local parent = self:GetParent()
	local caster = self:GetCaster()
	SimpleApplyDamage(self:GetAbility(), caster, parent, self.damage)
end
