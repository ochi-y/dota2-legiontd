LinkLuaModifier("modifier_ability_uproar", "ability/ability_uproar.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_uproar_buff", "ability/ability_uproar.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_uproar_debuff", "ability/ability_uproar.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
ability_uproar = class({})

wave_28_champion_uproar = ability_uproar

goblin_uproar = ability_uproar

function ability_uproar:GetIntrinsicModifierName()
	return "modifier_ability_uproar"
end

function ability_uproar:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	local mod = caster:FindModifierByName("modifier_ability_uproar")
	if mod and mod:GetStackCount() > 0 then
		return true
	end


	return false
end

function ability_uproar:OnSpellStart()
	local caster = self:GetCaster()

	caster:StartGesture(ACT_DOTA_CAST_ABILITY_3)
	local mod = caster:FindModifierByName("modifier_ability_uproar")
	local slow_duration = self:GetSpecialValueFor("slow_duration")
	local roar_duration = self:GetSpecialValueFor("roar_duration")
	local radius = self:GetSpecialValueFor("radius")

	local s = mod:GetStackCount()
	local mod1 = caster:AddNewModifier(caster, self, "modifier_ability_uproar_buff", { duration = roar_duration })
	mod1:SetStackCount(s)
	mod:SetStackCount(0)


	-- find enemies
	local enemies = FindUnitsInRadius(
		caster:GetTeamNumber(),	-- int, your team number
		caster:GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		0,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	for _,enemy in pairs(enemies) do
		local duration = slow_duration * (1 - CalUnitStatusResistance(enemy))
		enemy:AddNewModifier(
			caster, -- player source
			self, -- ability source
			"modifier_ability_uproar_debuff", -- modifier name
			{
				duration = duration,
				stack = s,
			} -- kv
		)
	end

	EmitSoundOn("Hero_PrimalBeast.Uproar.Cast", caster)

	-- PlayEffOnUnit("particles/units/heroes/hero_primal_beast/primal_beast_roar.vpcf",caster,{
	-- 	bind = PATTACH_POINT_FOLLOW,
	-- 	attach="attach_mouth"
	-- })

	local effect = ParticleManager:CreateParticle("particles/units/heroes/hero_primal_beast/primal_beast_roar.vpcf",
		PATTACH_POINT_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(effect, 0, caster, PATTACH_POINT_FOLLOW, "attach_mouth",
		Vector(0, 0, 0), true)
	ParticleManager:ReleaseParticleIndex(effect)

	PlayEffOnLocation("particles/units/heroes/hero_primal_beast/primal_beast_roar_aoe.vpcf", caster:GetAbsOrigin(), {
		cpKv = { [1] = Vector(radius, radius, radius) }
	})
end

-------------------------------------------------------------------------------------------------------
modifier_ability_uproar = class({
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
function modifier_ability_uproar:AllowIllusionDuplicate()
	return false
end

function modifier_ability_uproar:OnCreated(params)
	-- self.damage = params.damage
	-- self:SetHasCustomTransmitterData(true)
	local ability = self:GetAbility()
	self.stack_limit = ability:GetSpecialValueFor("stack_limit")
	self.minimum_damage = ability:GetSpecialValueFor("minimum_damage")
end

function modifier_ability_uproar:OnRefresh(params)
	self:OnCreated(params)
end

function modifier_ability_uproar:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}
end

function modifier_ability_uproar:CheckState()
	local state = {
	}
	return state
end

function modifier_ability_uproar:OnTakeDamage(k)
	if not IsServer() then return end
	local target = k.unit
	local caster = self:GetParent()
	local original_damage = k.original_damage
	local damage_type = k.damage_type

	if target == caster and k.damage > self.minimum_damage and self:GetStackCount() < self.stack_limit then
		if not caster:HasModifier("modifier_ability_uproar_buff") then
			self:IncrementStackCount()
		end
	end
end

-------------------------------------------------------------------------------------------------------
modifier_ability_uproar_buff = class({
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
function modifier_ability_uproar_buff:AllowIllusionDuplicate()
	return false
end

function modifier_ability_uproar_buff:OnCreated(params)
	local ability = self:GetAbility()
	self.bonus_damage_per_stack = ability:GetSpecialValueFor("bonus_damage_per_stack")
	self.roared_bonus_armor = ability:GetSpecialValueFor("roared_bonus_armor")

	if not IsServer() then return end

	local parent = self:GetParent()

	PlayEffOnUnit("particles/units/heroes/hero_primal_beast/primal_beast_uproar_magic_resist.vpcf", parent, {
		mod = self,
		bind = PATTACH_ABSORIGIN_FOLLOW,
		cpKv = {
			[2] = Vector(0, 0, 500)
		},
	})
end

function modifier_ability_uproar_buff:OnRefresh(params)
	self:OnCreated(params)
end

function modifier_ability_uproar_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
	}
end

function modifier_ability_uproar_buff:CheckState()
	local state = {
	}
	return state
end

function modifier_ability_uproar_buff:GetModifierPhysicalArmorBonus()
	return self:GetStackCount() * self.roared_bonus_armor
end

function modifier_ability_uproar_buff:GetModifierPreAttack_BonusDamage()
	return self:GetStackCount() * self.bonus_damage_per_stack
end

modifier_ability_uproar_debuff = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_ability_uproar_debuff:IsHidden()
	return false
end

function modifier_ability_uproar_debuff:IsDebuff()
	return true
end

function modifier_ability_uproar_debuff:IsPurgable()
	return true
end

function modifier_ability_uproar_debuff:GetTexture()
	return "primal_beast_uproar"
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_ability_uproar_debuff:OnCreated(kv)
	-- references
	self.slow = -self:GetAbility():GetSpecialValueFor("move_slow_per_stack")

	if not IsServer() then return end
	self.stack = kv.stack
	self:SetStackCount(self.stack)

	-- send init data from server to client
	self:SetHasCustomTransmitterData(true)
end

function modifier_ability_uproar_debuff:OnRefresh(kv)
	-- references
	self.slow = -self:GetAbility():GetSpecialValueFor("move_slow_per_stack")

	if not IsServer() then return end
	self.stack = kv.stack
end

function modifier_ability_uproar_debuff:OnRemoved()
end

function modifier_ability_uproar_debuff:OnDestroy()
end

--------------------------------------------------------------------------------
-- Transmitter data
function modifier_ability_uproar_debuff:AddCustomTransmitterData()
	-- on server
	local data = {
		stack = self.stack
	}

	return data
end

function modifier_ability_uproar_debuff:HandleCustomTransmitterData(data)
	-- on client
	self.stack = data.stack
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_ability_uproar_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}

	return funcs
end

function modifier_ability_uproar_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self.slow * self.stack
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_ability_uproar_debuff:GetStatusEffectName()
	return "particles/units/heroes/hero_primal_beast/primal_beast_status_effect_slow.vpcf"
end

function modifier_ability_uproar_debuff:StatusEffectPriority()
	return MODIFIER_PRIORITY_NORMAL
end
