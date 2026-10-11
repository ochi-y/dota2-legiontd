king_war_stomp = class({})

----------------------------------------------------------------------------------------

function king_war_stomp:Precache( context )
	PrecacheResource( "particle", "particles/units/heroes/hero_centaur/centaur_warstomp.vpcf", context )
end

--------------------------------------------------------------------------------
function king_war_stomp:OnAbilityPhaseStart()
	if IsServer() then
		self.radius = self:GetSpecialValueFor( "radius" )
		self.duration = self:GetSpecialValueFor( "stun_duration" )
		self.damage = self:GetSpecialValueFor( "stomp_damage" )
		self.speed = self:GetSpecialValueFor( "speed" )
		EmitSoundOn( "Hero_Centaur.PreAttack", self:GetCaster() )


		local caster=self:GetCaster()
		caster:AddNewModifier(caster, self, "modifier_casting", {duration=0.4})

	end
	return true
end

--------------------------------------------------------------------------------

function king_war_stomp:OnAbilityPhaseInterrupted()
	if IsServer() then
	end 
end

--------------------------------------------------------------------------------

function king_war_stomp:GetPlaybackRateOverride()
	return 1
end

--------------------------------------------------------------------------------

function king_war_stomp:OnSpellStart()
	if IsServer() then

		local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_centaur/centaur_warstomp.vpcf", PATTACH_ABSORIGIN, self:GetCaster() )
		ParticleManager:SetParticleControl( nFXIndex, 1, Vector( self.radius, self.radius, self.radius ) )
		ParticleManager:SetParticleControlEnt( nFXIndex, 2, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetOrigin(), true )
		ParticleManager:ReleaseParticleIndex( nFXIndex )

		EmitSoundOn( "Hero_Centaur.HoofStomp", self:GetCaster() )

		local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetCaster():GetOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false )
		for _,enemy in pairs( enemies ) do
			if enemy ~= nil and enemy:IsInvulnerable() == false then
				local damageInfo = 
				{
					victim = enemy,
					attacker = self:GetCaster(),
					damage = self.damage,
					damage_type = DAMAGE_TYPE_MAGICAL,
					ability = self,
				}
				ApplyDamage( damageInfo )
				enemy:AddNewModifier( self:GetCaster(), self, "modifier_stunned", { duration = self.duration } )
			end
		end
	
	end
end

--------------------------------------------------------------------------------