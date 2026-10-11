LinkLuaModifier( "modifier_arctic_breath_of_frost", "ability/arctic_breath_of_frost", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_arctic_breath_of_frost_fire", "ability/arctic_breath_of_frost", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_arctic_breath_of_frost_ice", "ability/arctic_breath_of_frost", LUA_MODIFIER_MOTION_NONE )

arctic_breath_of_frost = {}

function arctic_breath_of_frost:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local point = self:GetCursorPosition()

	local delay = self:GetSpecialValueFor( "fire_delay" )
	if target then
		point = target:GetAbsOrigin()
	end



	caster:AddNewModifier(
		caster,
		self,
		"modifier_arctic_breath_of_frost",
		{
			duration = delay,
			x = point.x,
			y = point.y,
		}
	)
end

function arctic_breath_of_frost:OnProjectileHit_ExtraData( target, location, data )
	if not target then return end

	local caster = self:GetCaster()
	local delay = self:GetSpecialValueFor( "fire_delay" )
	local duration = self:GetSpecialValueFor("duration")
	local damage = self:GetSpecialValueFor("damage")


	local modifier = "modifier_arctic_breath_of_frost_ice"
	if data.fire == 1 then
		modifier = "modifier_arctic_breath_of_frost_fire"
	end

	SimpleApplyDamage(self, caster, target, damage)


	duration = duration * (1 - CalUnitStatusResistance(target))

	target:AddNewModifier(
		caster,
		self,
		modifier,
		{ duration = duration }
	)
end

modifier_arctic_breath_of_frost = {}

function modifier_arctic_breath_of_frost:IsHidden()
	return true
end

function modifier_arctic_breath_of_frost:IsDebuff()
	return false
end

function modifier_arctic_breath_of_frost:IsStunDebuff()
	return false
end

function modifier_arctic_breath_of_frost:IsPurgable()
	return false
end

function modifier_arctic_breath_of_frost:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE 
end

function modifier_arctic_breath_of_frost:RemoveOnDeath()
	return false
end

function modifier_arctic_breath_of_frost:OnCreated( kv )
	if not self:GetAbility() then return end
	local distance = self:GetAbility():GetSpecialValueFor( "range" )
	local start_radius = self:GetAbility():GetSpecialValueFor( "start_radius" )
	local end_radius = self:GetAbility():GetSpecialValueFor( "end_radius" )
	self.speed_ice = self:GetAbility():GetSpecialValueFor( "speed" )
	self.speed_fire = self:GetAbility():GetSpecialValueFor( "speed_fire" )
	--
	self.damage = self:GetAbility():GetSpecialValueFor( "damage" )
	--
	if not IsServer() then return end
	local caster = self:GetCaster()

	self.direction = Vector( kv.x, kv.y, 0 ) - caster:GetAbsOrigin()

	if self.direction.x==0 and self.direction.y==0 then
		self.direction=caster:GetForwardVector()
	end
	self.direction.z = 0
	self.direction = self.direction:Normalized()

	
	self.info = {
		Source = caster,
		Ability = self:GetAbility(),
		vSpawnOrigin = caster:GetAbsOrigin(),
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		fDistance = distance,
		fStartRadius = start_radius,
		fEndRadius = end_radius,
	}

	self.info.EffectName = "particles/units/heroes/hero_jakiro/jakiro_dual_breath_ice.vpcf"
	self.info.vVelocity = self.direction * self.speed_ice
	self.info.ExtraData = {
		fire = 0
	}
	ProjectileManager:CreateLinearProjectile( self.info )

	EmitSoundOn( "Hero_Jakiro.DualBreath.Cast", self:GetCaster() )
end

function modifier_arctic_breath_of_frost:OnRemoved()
	if not IsServer() then return end

	self.info.EffectName = "particles/units/heroes/hero_jakiro/jakiro_dual_breath_fire.vpcf"
	self.info.vVelocity = self.direction * self.speed_fire
	self.info.ExtraData = {
		fire = 1
	}
	ProjectileManager:CreateLinearProjectile( self.info )

	local caster = self:GetCaster()

	local effect_cast = ParticleManager:CreateParticle(
		"particles/units/heroes/hero_jakiro/jakiro_dual_breath_fire_launch_2.vpcf",
		PATTACH_ABSORIGIN_FOLLOW,
		caster
	)
	ParticleManager:SetParticleControl( effect_cast, 0, caster:GetAbsOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 1, self.info.vVelocity )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		9,
		caster,
		PATTACH_ABSORIGIN_FOLLOW,
		"attach_attack1",
		Vector(),
		true
	)
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

modifier_arctic_breath_of_frost_fire = {}

function modifier_arctic_breath_of_frost_fire:IsHidden()
	return false
end

function modifier_arctic_breath_of_frost_fire:IsDebuff()
	return true
end

function modifier_arctic_breath_of_frost_fire:IsStunDebuff()
	return false
end

function modifier_arctic_breath_of_frost_fire:IsPurgable()
	return true
end

function modifier_arctic_breath_of_frost_fire:OnCreated( kv )
	if not self:GetAbility() then return end
	local damage = self:GetAbility():GetSpecialValueFor( "burn_damage" )

	if not IsServer() then return end

	self.damageTable = {
		victim = self:GetParent(),
		attacker = self:GetCaster(),
		damage = damage,
		damage_type = self:GetAbility():GetAbilityDamageType(),
		ability = self:GetAbility(),
	}

	self:StartIntervalThink( 0.5 )
	self:OnIntervalThink()
end

function modifier_arctic_breath_of_frost_fire:OnRefresh( kv )
	if not self:GetAbility() then return end
	local damage = self:GetAbility():GetSpecialValueFor( "burn_damage" )
	if not IsServer() then return end
	
	self.damageTable.damage = damage
end

function modifier_arctic_breath_of_frost_fire:OnIntervalThink()
	ApplyDamage( self.damageTable )
end

function modifier_arctic_breath_of_frost_fire:GetEffectName()
	return "particles/units/heroes/hero_jakiro/jakiro_liquid_fire_debuff.vpcf"
end

function modifier_arctic_breath_of_frost_fire:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

modifier_arctic_breath_of_frost_ice = {}

function modifier_arctic_breath_of_frost_ice:IsHidden()
	return false
end

function modifier_arctic_breath_of_frost_ice:IsDebuff()
	return true
end

function modifier_arctic_breath_of_frost_ice:IsStunDebuff()
	return false
end

function modifier_arctic_breath_of_frost_ice:IsPurgable()
	return true
end

function modifier_arctic_breath_of_frost_ice:OnCreated( kv )
	if not self:GetAbility() then return end
	self.as_slow = self:GetAbility():GetSpecialValueFor( "slow_attack_speed_pct" )
	self.ms_slow = self:GetAbility():GetSpecialValueFor( "slow_movement_speed_pct" )
end

modifier_arctic_breath_of_frost_ice.OnRefresh = modifier_arctic_breath_of_frost_ice.OnCreated

function modifier_arctic_breath_of_frost_ice:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end

function modifier_arctic_breath_of_frost_ice:GetModifierMoveSpeedBonus_Percentage()
	return self.ms_slow
end

function modifier_arctic_breath_of_frost_ice:GetModifierAttackSpeedBonus_Constant()
	return self.as_slow
end

function modifier_arctic_breath_of_frost_ice:GetEffectName()
	return "particles/generic_gameplay/generic_slowed_cold.vpcf"
end

function modifier_arctic_breath_of_frost_ice:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end