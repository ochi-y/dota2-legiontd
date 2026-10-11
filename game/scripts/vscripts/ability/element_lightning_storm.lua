element_lightning_storm = {

	GetIntrinsicModifierName = function() 
		return "modifier_element_lightning_storm_self" 
	end

}

LinkLuaModifier("modifier_element_lightning_storm", "ability/element_lightning_storm", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_element_lightning_storm_thinker", "ability/element_lightning_storm", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_element_lightning_storm_self", "ability/element_lightning_storm", LUA_MODIFIER_MOTION_NONE)


-------------------------------------------------------------------------------------------------------
modifier_element_lightning_storm_self = class({
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
function modifier_element_lightning_storm_self:AllowIllusionDuplicate()
	return true
end

function modifier_element_lightning_storm_self:OnCreated(params)
	if not self:GetAbility() then return end
	local ability = self:GetAbility()
	self.cooldown = ability:GetSpecialValueFor("cooldown")
	if not IsServer() then return end

end

function modifier_element_lightning_storm_self:OnRefresh(params)
	if not self:GetAbility() then return end
	local ability = self:GetAbility()
	self.cooldown = ability:GetSpecialValueFor("cooldown")

	if not IsServer() then return end
	
end

function modifier_element_lightning_storm_self:OnIntervalThink(params)
	local caster = self:GetCaster()

	local ability = self:GetAbility()

	local distance = ability:GetCastRange(Vector(0, 0, 0), nil)

	local units = FindAbilityTarget(ability, caster:GetAbsOrigin(), distance, {
		findOrder = FIND_ANY_ORDER
	})

	local target = units[1]

	if target then
		if target:TriggerSpellAbsorb(self) then return end

		local thinker = CreateModifierThinker(
			caster,
			ability,
			"modifier_element_lightning_storm_thinker",
			{},
			caster:GetOrigin(),
			caster:GetTeamNumber(),
			false
		)
		thinker:FindModifierByName("modifier_element_lightning_storm_thinker"):Cast(target)
	end
end

-- function element_lightning_storm:OnSpellStart()
-- 	local caster = self:GetCaster()
-- 	local target = self:GetCursorTarget()

-- 	if target:TriggerSpellAbsorb( self ) then return end

-- 	local thinker = CreateModifierThinker(
-- 		caster,
-- 		self,
-- 		"modifier_element_lightning_storm_thinker",
-- 		{},
-- 		caster:GetOrigin(),
-- 		caster:GetTeamNumber(),
-- 		false
-- 	)
-- 	thinker:FindModifierByName( "modifier_element_lightning_storm_thinker" ):Cast( target )
-- end





modifier_element_lightning_storm = {}

function modifier_element_lightning_storm:IsHidden()
	return false
end

function modifier_element_lightning_storm:IsDebuff()
	return true
end

function modifier_element_lightning_storm:IsStunDebuff()
	return false
end

function modifier_element_lightning_storm:IsPurgable()
	return true
end

function modifier_element_lightning_storm:OnCreated(kv)
	if IsServer() then
		self.slow = kv.slow
	end
end

function modifier_element_lightning_storm:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
	return funcs
end

function modifier_element_lightning_storm:GetModifierMoveSpeedBonus_Percentage()
	return -self.slow
end

modifier_element_lightning_storm_thinker = {}

function modifier_element_lightning_storm_thinker:IsHidden()
	return true
end

function modifier_element_lightning_storm_thinker:IsPurgable()
	return false
end

function modifier_element_lightning_storm_thinker:OnCreated(kv)
	if not IsServer() then return end

	self.delay = self:GetAbility():GetSpecialValueFor("jump_delay")
	self.count = self:GetAbility():GetSpecialValueFor("jump_count")
	self.radius = self:GetAbility():GetSpecialValueFor("radius")
	self.duration = self:GetAbility():GetSpecialValueFor("slow_duration")
	self.slow = self:GetAbility():GetSpecialValueFor("slow_movement_speed")

	self.targets = {}
	self.damageTable = {
		attacker = self:GetCaster(),
		damage = self:GetAbility():GetAbilityDamage(),
		damage_type = self:GetAbility():GetAbilityDamageType(),
		ability = self:GetAbility(),
	}
end

function modifier_element_lightning_storm_thinker:Cast(target)
	self.current_target = target
	self.started = false
	self:StartIntervalThink(self.delay)
end

function modifier_element_lightning_storm_thinker:OnDestroy()
	if not IsServer() then return end

	UTIL_Remove(self:GetParent())
end

function modifier_element_lightning_storm_thinker:OnIntervalThink()
	if not self.started then
		self.started = true

		self:Struck(self.current_target)
		return
	end

	local enemies = FindUnitsInRadius(
		self:GetCaster():GetTeamNumber(),
		self.current_target:GetOrigin(),
		nil,
		self.radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS,
		FIND_CLOSEST,
		false
	)

	local found = false
	for _, enemy in pairs(enemies) do
		if not self.targets[enemy] then
			found = true
			self.current_target = enemy

			if IsActiveUnit(enemy) then
				self:Struck(enemy)
			end

			break
		end
	end

	if not found then
		self:Destroy()
	end
end

function modifier_element_lightning_storm_thinker:Struck(target)
	if not target:IsMagicImmune() then
		self.damageTable.victim = target
		ApplyDamage(self.damageTable)

		target:AddNewModifier(
			self:GetCaster(),
			self:GetAbility(),
			"modifier_element_lightning_storm",
			{
				duration = self.duration,
				slow = self.slow,
			}
		)

		self.targets[target] = true
	end

	local effect_cast = ParticleManager:CreateParticle("particles/units/heroes/hero_leshrac/leshrac_lightning_bolt.vpcf",
		PATTACH_CUSTOMORIGIN, target)
	ParticleManager:SetParticleControl(effect_cast, 0, target:GetAbsOrigin() + Vector(0, 0, 800))
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		1,
		target,
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0, 0, 0),
		true
	)
	ParticleManager:ReleaseParticleIndex(effect_cast)

	EmitSoundOn("Hero_Leshrac.Lightning_Storm", target)

	self.count = self.count - 1

	if self.count <= 0 then
		self:Destroy()
	end
end

function modifier_element_lightning_storm_thinker:PlayEffects(target)
	local effect_cast = ParticleManager:CreateParticle("particles/units/heroes/hero_leshrac/leshrac_lightning_bolt.vpcf",
		PATTACH_CUSTOMORIGIN, target)
	ParticleManager:SetParticleControl(effect_cast, 0, target:GetAbsOrigin() + Vector(0, 0, 800))
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		1,
		target,
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0, 0, 0),
		true
	)
	ParticleManager:ReleaseParticleIndex(effect_cast)

	EmitSoundOn("Hero_Leshrac.Lightning_Storm", target)
end
