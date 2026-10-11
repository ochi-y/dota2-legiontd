ability_sun_strike = class({})
LinkLuaModifier( "modifier_ability_sun_strike_thinker", "ability/ability_sun_strike", LUA_MODIFIER_MOTION_NONE )

wave_8_champion_sun_strike=ability_sun_strike

element_sun_strike=ability_sun_strike
--------------------------------------------------------------------------------
-- Custom KV
-- AOE Radius
function ability_sun_strike:GetAOERadius()
	return self:GetSpecialValueFor( "area_of_effect" )
end

function ability_sun_strike:GetBehavior()
	 local nDefaultBehavior = DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING 
     if self:GetCaster():HasModifier("modifier_item_aeon_disk_lua") then
        return nDefaultBehavior+DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
     else
        return nDefaultBehavior
     end
end

--  function ability_sun_strike:CastFilterResultTarget( hTarget )
-- 	if not self:GetCaster():HasModifier("modifier_item_aeon_disk_lua") then
--  		return UF_FAIL_CUSTOM
--  	end
--  	if self:GetCaster() ~= hTarget then
--  		return UF_FAIL_CUSTOM
--  	end
-- end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Ability Start
function ability_sun_strike:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	-- get values
	local delay = self:GetSpecialValueFor("delay")
	local vision_distance = self:GetSpecialValueFor("vision_distance")
	local vision_duration = self:GetSpecialValueFor("vision_duration")

	-- create modifier thinker
	CreateModifierThinker(
		caster,
		self,
		"modifier_ability_sun_strike_thinker",
		{ duration = delay },
		point,
		caster:GetTeamNumber(),
		false
	)

	-- create vision
	-- AddFOWViewer( caster:GetTeamNumber(), point, vision_distance, vision_duration, false )
end

modifier_ability_sun_strike_thinker = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_ability_sun_strike_thinker:IsHidden()
	return true
end

function modifier_ability_sun_strike_thinker:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_ability_sun_strike_thinker:OnCreated( kv )
	if IsServer() then
		-- references
		self.damage = self:GetAbility():GetSpecialValueFor("damage")


		self.radius = self:GetAbility():GetSpecialValueFor("area_of_effect")

		-- Play effects
		self:PlayEffects1()
	end
end

function modifier_ability_sun_strike_thinker:OnDestroy( kv )
	if IsServer() then

		if not IsActiveUnit(self:GetCaster()) then
			return
		end

		-- Damage enemies
		local damageTable = {
			-- victim = target,
			attacker = self:GetCaster(),
			-- damage = self.damage,
			damage_type = DAMAGE_TYPE_PURE,
			ability = self:GetAbility(), --Optional.
		}

		local enemies = FindUnitsInRadius(
			self:GetCaster():GetTeamNumber(),
			self:GetParent():GetOrigin(),	
			nil,	
			self.radius,	
			DOTA_UNIT_TARGET_TEAM_ENEMY,	
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,	
			0,
			false
		)

		enemies=subrange(enemies,1,15)


		for _,enemy in pairs(enemies) do
			damageTable.victim = enemy
			damageTable.damage = self.damage/#enemies
			ApplyDamage(damageTable)
		end

		self:PlayEffects2()

		UTIL_Remove( self:GetParent() )
	end
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_ability_sun_strike_thinker:PlayEffects1()
	-- Get Resources
	local particle_cast = "particles/econ/items/invoker/invoker_apex/invoker_sun_strike_team_immortal1.vpcf"
	local sound_cast = "Hero_Invoker.SunStrike.Charge"

	-- Create Particle
	-- local effect_cast = ParticleManager:CreateParticleForTeam( particle_cast, PATTACH_WORLDORIGIN, self:GetCaster(), self:GetCaster():GetTeamNumber() )

	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, self:GetCaster())

	ParticleManager:SetParticleControl( effect_cast, 0, self:GetParent():GetOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( self.radius, 0, 0 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	--EmitSoundOnLocationForAllies( self:GetParent():GetOrigin(), sound_cast, self:GetCaster() )

	EmitSoundOnLocationWithCaster( self:GetParent():GetOrigin(), sound_cast, self:GetCaster() )
end

function modifier_ability_sun_strike_thinker:PlayEffects2()
	-- Get Resources
	local particle_cast = "particles/econ/items/invoker/invoker_apex/invoker_sun_strike_immortal1.vpcf"
	local sound_cast = "Hero_Invoker.SunStrike.Ignite"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast, 0, self:GetParent():GetOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( self.radius, 0, 0 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOnLocationWithCaster( self:GetParent():GetOrigin(), sound_cast, self:GetCaster() )
end