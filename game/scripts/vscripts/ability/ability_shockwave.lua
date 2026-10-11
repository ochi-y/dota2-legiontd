
ability_shockwave = {}


wave_7_champion_shockwave=ability_shockwave


function ability_shockwave:OnAbilityPhaseStart()
	if not IsServer() then return end
	--self:PlayEffects1()
	--EmitSoundOn("Hero_Magnataur.ShockWave.Cast.Anvil", self:GetCaster())
	return true
end

function ability_shockwave:OnAbilityPhaseInterrupted()
	if not IsServer() then return end
	self:StopEffects1( true )
end

function ability_shockwave:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	self:StopEffects1( false )

	local radius_start = self:GetSpecialValueFor( "radius_start" )
	local radius_end = self:GetSpecialValueFor( "radius_end" )
	local speed = self:GetSpecialValueFor( "speed" )
	local distance = self:GetSpecialValueFor( "distance" )


	local direction = point - caster:GetAbsOrigin()
	direction.z = 0
	direction = direction:Normalized()

	local info = {
		Source = caster,
		Ability = self,
		vSpawnOrigin = caster:GetAbsOrigin(),
		bDeleteOnHit = true,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		EffectName = "particles/neutral_fx/satyr_hellcaller.vpcf",
		fDistance = distance,
		fStartRadius = radius_start,
		fEndRadius = radius_end,
		vVelocity = direction * speed,
	}
	ProjectileManager:CreateLinearProjectile(info)

	EmitSoundOn( "n_creep_SatyrHellcaller.Shockwave", caster )
end

function ability_shockwave:OnProjectileHit( target, location )
	if not target then return end

	local caster = self:GetCaster()
	local damage = self:GetSpecialValueFor( "damage" )

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self
	}
	ApplyDamage(damageTable)
	self:PlayEffects2( target )
	return false
end

function ability_shockwave:PlayEffects2( target )
	-- local effect_cast = ParticleManager:CreateParticle( 
	-- 	"particles/econ/items/magnataur/shock_of_the_anvil/magnataur_shockanvil_hit.vpcf",
	-- 	PATTACH_ABSORIGIN_FOLLOW,
	-- 	target
	-- )
	-- ParticleManager:ReleaseParticleIndex( effect_cast )
	EmitSoundOn( "n_creep_SatyrHellcaller.Shockwave.Damage", target )
end

function ability_shockwave:PlayEffects1()
	local caster = self:GetCaster()

	local effect_cast = ParticleManager:CreateParticle(
		"particles/econ/items/magnataur/shock_of_the_anvil/magnataur_shockanvil_cast.vpcf",
		PATTACH_ABSORIGIN_FOLLOW,
		caster
	)
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		1,
		caster,
		PATTACH_POINT_FOLLOW,
		"attach_attack1",
		Vector(),
		true
	)
	self.effect_cast = effect_cast

	--EmitSoundOn( "Hero_Magnataur.ShockWave.Cast", caster )
end

function ability_shockwave:StopEffects1( interrupted )
	-- ParticleManager:DestroyParticle( self.effect_cast, interrupted )
	-- ParticleManager:ReleaseParticleIndex( self.effect_cast )

	--StopSoundOn( "Hero_Magnataur.ShockWave.Cast", self:GetCaster() )
end
