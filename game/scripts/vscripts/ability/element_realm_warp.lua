
element_realm_warp = class({})
LinkLuaModifier("modifier_element_realm_warp", "ability/element_realm_warp", LUA_MODIFIER_MOTION_NONE)

-- function element_realm_warp:GetCastAnimation()
-- 	return ACT_DOTA_CAST_ABILITY_4
-- end
function element_realm_warp:OnSpellStart()
	local caster = self:GetCaster()
	local origin = caster:GetAbsOrigin()
	local target = self:GetCursorPosition()
	local duration = self:GetSpecialValueFor("channel_duration")
	local radius = self:GetSpecialValueFor("radius")
	
	caster:AddNewModifier(caster, self, "modifier_element_realm_warp", {duration = duration})
	AddFOWViewer(caster:GetTeamNumber(), target, radius, duration, false)
end

modifier_element_realm_warp = class({})
function modifier_element_realm_warp:IsDebuff() return false end
function modifier_element_realm_warp:IsHidden() return true end
function modifier_element_realm_warp:IsPurgable() return false end
function modifier_element_realm_warp:IsPurgeException() return false end
function modifier_element_realm_warp:OnCreated()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local origin = caster:GetAbsOrigin()
	self.origin = origin
	local target = self:GetAbility():GetCursorPosition()
	self.target = target
	
	self:PlayEffects1( origin, false )
	self:PlayEffects1( target, true )
	
	self.direction = target - origin
end
function modifier_element_realm_warp:OnDestroy()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local radius = ability:GetSpecialValueFor("radius")
	local allies = FindUnitsInRadius(caster:GetTeamNumber(),
		self.origin,
		nil,
		radius,
		DOTA_UNIT_TARGET_TEAM_FRIENDLY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER,
		false
	)
	
	for _,ally in pairs(allies) do
		local allyorigin = ally:GetAbsOrigin()
		FindClearSpaceForUnit( ally, allyorigin + self.direction, true )
		self:PlayEffects2( allyorigin, self.direction, ally )
		ally:AddNewModifier( caster, ability, "modifier_invulnerable", {duration = ability:GetSpecialValueFor("phase_duration")})
		
		if caster:HasScepter() then
			caster:GetAbilityByIndex(2):Flux(nil, self.target)
		end
	end
end

function modifier_element_realm_warp:PlayEffects1( point, main )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_zeus/zeus_cloud.vpcf"
	local sound_cast = "Hero_VoidSpirit.Dissimilate.Portals"

	-- adjustments
	local radius = self:GetAbility():GetSpecialValueFor("radius")

	-- Create Particle for this team
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast, 0, point )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( radius, 0, 1 ) )
	if main then
		ParticleManager:SetParticleControl( effect_cast, 2, Vector( 1, 0, 0 ) )
	end

	-- buff particle
	self:AddParticle(
		effect_cast,
		false, -- bDestroyImmediately
		false, -- bStatusEffect
		-1, -- iPriority
		false, -- bHeroEffect
		false -- bOverheadEffect
	)

	-- Play Sound
	EmitSoundOnLocationWithCaster( point, sound_cast, self:GetCaster() )

	return effect_cast
end
function modifier_element_realm_warp:PlayEffects2( origin, direction, unit )
	-- Get Resources
	local particle_cast_a = "particles/econ/events/fall_2021/blink_dagger_fall_2021_start.vpcf"
	local sound_cast_a = "Hero_Antimage.Blink_out"

	local particle_cast_b = "particles/econ/events/fall_2021/blink_dagger_fall_2021_end_lvl2.vpcf"
	local sound_cast_b = "Hero_Antimage.Blink_in"

	-- At original position
	local effect_cast_a = ParticleManager:CreateParticle( particle_cast_a, PATTACH_ABSORIGIN, unit )
	ParticleManager:SetParticleControl( effect_cast_a, 0, origin )
	ParticleManager:SetParticleControlForward( effect_cast_a, 0, direction:Normalized() )
	ParticleManager:ReleaseParticleIndex( effect_cast_a )
	EmitSoundOnLocationWithCaster( origin, sound_cast_a, unit )

	-- At original position
	local effect_cast_b = ParticleManager:CreateParticle( particle_cast_b, PATTACH_ABSORIGIN_FOLLOW, unit )
	ParticleManager:SetParticleControl( effect_cast_b, 0, unit:GetOrigin() )
	ParticleManager:SetParticleControlForward( effect_cast_b, 0, direction:Normalized() )
	ParticleManager:ReleaseParticleIndex( effect_cast_b )
	EmitSoundOnLocationWithCaster( unit:GetOrigin(), sound_cast_b, unit )
end