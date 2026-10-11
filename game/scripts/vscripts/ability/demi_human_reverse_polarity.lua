demi_human_reverse_polarity = {}

function demi_human_reverse_polarity:OnAbilityPhaseStart()
	local radius = self:GetSpecialValueFor( "pull_radius" )

	
	local castpoint = self:GetCastPoint()
	local caster = self:GetCaster()
	local effect_cast = ParticleManager:CreateParticle(
		"particles/units/heroes/hero_magnataur/magnataur_reverse_polarity.vpcf",
		PATTACH_ABSORIGIN_FOLLOW,
		self:GetCaster()
	)
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( radius, radius, radius ) )
	ParticleManager:SetParticleControl( effect_cast, 2, Vector( castpoint, 0, 0 ) )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		3,
		self:GetCaster(),
		PATTACH_ABSORIGIN_FOLLOW,
		"attach_hitloc",
		Vector(),
		true
	)
	ParticleManager:SetParticleControlForward( effect_cast, 3, self:GetCaster():GetForwardVector() )

	self.effect_cast = effect_cast

	EmitSoundOn( "Hero_Magnataur.ReversePolarity.Anim", self:GetCaster() )

	local enemies = FindUnitsInRadius(
		caster:GetTeamNumber(),
		caster:GetOrigin(),
		nil,
		radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		0,
		false
	)

	return true
end

function demi_human_reverse_polarity:OnAbilityPhaseInterrupted()
	self:StopEffects( true )
end


function demi_human_reverse_polarity:OnSpellStart()
	self:StopEffects( false )

	local caster = self:GetCaster()
	local radius = self:GetSpecialValueFor( "pull_radius" )
	local damage = self:GetSpecialValueFor( "polarity_damage" )
	local duration = self:GetSpecialValueFor( "hero_stun_duration" )
	local range = radius/2

	
	local damageTable = {
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self,
	}

	local enemies = FindUnitsInRadius(
		caster:GetTeamNumber(),
		caster:GetOrigin(),
		nil,
		radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		0,
		false
	)

	for _,enemy in pairs(enemies) do
		local origin = enemy:GetOrigin()
		local pos = caster:GetOrigin() + caster:GetForwardVector() * range

		pos=RandomPointInRadius(pos,radius/4)

		FindClearSpaceForUnit( enemy, pos, true )

		duration = duration * (1 - CalUnitStatusResistance(enemy))
		
		enemy:AddNewModifier(
			caster,
			self,
			"modifier_stunned",
			{ duration = duration }
		)

		enemy:AddNewModifier(
			caster,
			self,
			"modifier_phased",
			{ duration = 0.1 }
		)

		damageTable.victim = enemy
		ApplyDamage( damageTable )


		local effect_cast = ParticleManager:CreateParticle(
			"particles/units/heroes/hero_magnataur/magnataur_reverse_polarity_pull.vpcf",
			PATTACH_ABSORIGIN_FOLLOW,
			enemy
		)
		ParticleManager:SetParticleControl( effect_cast, 1, origin )
		ParticleManager:ReleaseParticleIndex( effect_cast )

		EmitSoundOn( "Hero_Magnataur.ReversePolarity.Stun", enemy )
	end

	EmitSoundOn( "Hero_Magnataur.ReversePolarity.Cast", caster )
end

function demi_human_reverse_polarity:StopEffects( interrupted )
	ParticleManager:DestroyParticle( self.effect_cast, interrupted )
	ParticleManager:ReleaseParticleIndex( self.effect_cast )

	StopSoundOn( "Hero_Magnataur.ReversePolarity.Anim", self:GetCaster() )
end