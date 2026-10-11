king_firestorm = {}


undead_firestorm=king_firestorm


LinkLuaModifier( "modifier_king_firestorm", "ability/king_firestorm", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_king_firestorm_thinker", "ability/king_firestorm", LUA_MODIFIER_MOTION_NONE )


function king_firestorm:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )
end


function king_firestorm:OnAbilityPhaseStart()
	local point = self:GetCursorPosition()
	local caster = self:GetCaster()

	local radius = self:GetSpecialValueFor( "radius" )

	self.effect_cast = ParticleManager:CreateParticleForTeam( "particles/units/heroes/heroes_underlord/underlord_firestorm_pre.vpcf", PATTACH_WORLDORIGIN, caster, caster:GetTeamNumber() )
	ParticleManager:SetParticleControl( self.effect_cast, 0, point )
	ParticleManager:SetParticleControl( self.effect_cast, 1, Vector( 2, 2, 2 ) )

	EmitSoundOnLocationWithCaster( point, "Hero_AbyssalUnderlord.Firestorm.Start", self:GetCaster() )

	caster:AddNewModifier(caster, self, "modifier_casting", {duration=0.4})

	return true
end

function king_firestorm:OnAbilityPhaseInterrupted()
	ParticleManager:DestroyParticle( self.effect_cast, true )
	ParticleManager:ReleaseParticleIndex( self.effect_cast )
end

function king_firestorm:OnSpellStart()
	local caster = self:GetCaster()

	CreateModifierThinker(
		caster,
		self,
		"modifier_king_firestorm_thinker",
		{
			duration =
				self:GetSpecialValueFor( "wave_interval" ) *
				self:GetSpecialValueFor( "wave_count" ) +
				self:GetSpecialValueFor( "first_wave_delay" )
		},
		self:GetCursorPosition(),
		caster:GetTeamNumber(),
		false
	)

	ParticleManager:DestroyParticle( self.effect_cast, true )
	ParticleManager:ReleaseParticleIndex( self.effect_cast )
end

modifier_king_firestorm_thinker = {}

function modifier_king_firestorm_thinker:IsHidden()
	return true
end

function modifier_king_firestorm_thinker:IsPurgable()
	return false
end

function modifier_king_firestorm_thinker:OnCreated( kv )
	if IsClient() then
		return
	end

	self.caster = self:GetCaster()
	self.pos = self:GetParent():GetAbsOrigin()
	self.ability = self:GetAbility()

	self.radius = self.ability:GetSpecialValueFor( "radius" )
	self.interval = self.ability:GetSpecialValueFor( "wave_interval" )
	self.burn_duration = self.ability:GetSpecialValueFor( "burn_duration" )
	self.burn_interval = self.ability:GetSpecialValueFor( "burn_interval" )
	self.burn_damage = self.ability:GetSpecialValueFor( "burn_damage" )

	self.damageTable = {
		attacker = self.caster,
		damage = self.ability:GetSpecialValueFor( "wave_damage" ),
		damage_type = self.ability:GetAbilityDamageType(),
		ability = self.ability,
	}

	self:StartIntervalThink( self.ability:GetSpecialValueFor( "first_wave_delay" ) )
end

function modifier_king_firestorm_thinker:OnIntervalThink()
	self:StartIntervalThink( self.interval )

	local enemies = FindUnitsInRadius(
		self.caster:GetTeamNumber(),
		self.pos,
		nil,
		self.radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		0,
		0,
		false
	)

	for _, enemy in pairs( enemies ) do
		self.damageTable.victim = enemy
		ApplyDamage( self.damageTable )

		enemy:AddNewModifier(
			self.caster,
			self.ability,
			"modifier_king_firestorm",
			{
				duration = self.burn_duration,
				interval = self.burn_interval,
				damage = self.burn_damage
			}
		)
	end

	local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/heroes_underlord/abyssal_underlord_firestorm_wave.vpcf", PATTACH_WORLDORIGIN, nil )
	ParticleManager:SetParticleControl( effect_cast, 0, self.pos )
	ParticleManager:SetParticleControl( effect_cast, 4, Vector( self.radius, 0, 0 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	EmitSoundOn( "Hero_AbyssalUnderlord.Firestorm", self:GetParent())
end

modifier_king_firestorm = {}

function modifier_king_firestorm:IsHidden()
	return false
end

function modifier_king_firestorm:IsDebuff()
	return true
end

function modifier_king_firestorm:IsStunDebuff()
	return false
end

function modifier_king_firestorm:IsPurgable()
	return true
end

function modifier_king_firestorm:OnCreated( kv )
	if not IsServer() then return end
	local interval = kv.interval
	self.damage_pct = kv.damage/100

	self.damageTable = {
		victim = self:GetParent(),
		attacker = self:GetCaster(),
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self:GetAbility(),
	}

	self:StartIntervalThink( interval )
end

function modifier_king_firestorm:OnRefresh( kv )
	if not IsServer() then return end
	self.damage_pct = kv.damage/100
end

function modifier_king_firestorm:OnIntervalThink()
	local damage = self:GetParent():GetMaxHealth() * self.damage_pct

	self.damageTable.damage = damage
	ApplyDamage( self.damageTable )
end

function modifier_king_firestorm:GetEffectName()
	return "particles/units/heroes/heroes_underlord/abyssal_underlord_firestorm_wave_burn.vpcf"
end

function modifier_king_firestorm:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end