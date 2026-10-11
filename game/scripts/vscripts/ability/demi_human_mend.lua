LinkLuaModifier( "modifier_demi_human_motar_tag", "ability/demi_human_mend.lua", LUA_MODIFIER_MOTION_NONE )


demi_human_mend = class({})



--------------------------------------------------------------------------------
-- Ability Start
function demi_human_mend:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	-- references
	self.radius = self:GetSpecialValueFor( "damage_radius" )
	self.damage_reduction = self:GetSpecialValueFor( "damage_reduction" )

	self.bounce_radius = self:GetSpecialValueFor( "bounce_radius" )

	self.max_targets=self:GetSpecialValueFor( "max_targets" )
	local jumps = self:GetSpecialValueFor( "max_targets" )
	self.damage = self:GetSpecialValueFor( "damage" )

	-- precache damage
	self.damageTable = {
		-- victim = target,
		attacker = caster,
		damage = self.damage,
		damage_type = DAMAGE_TYPE_PHYSICAL,
		ability = self, --Optional.
	}

	-- unit groups
	self.healedUnits = {}
	-- table.insert( self.healedUnits, caster )

	-- Jump
	self:Jump( jumps, caster, target )
	
	-- Play effects
	local sound_cast = "Hero_Dazzle.Shadow_Wave"
	EmitSoundOn( sound_cast, caster )
end

function demi_human_mend:Jump( jumps, source, target )
	-- Heal
	--if jumps~=4 then
	local healValue=self.damage*math.pow((100-self.damage_reduction)/100,self.max_targets-jumps)

	-- 
	if target then
		-- target:Heal( healValue, self )
		target:HealWithParams(healValue, self, false, true,self:GetCaster() , false)

		PopupHealing(target, math.floor(healValue))
		self:PlayEffects1( source, target )
		table.insert( self.healedUnits, target )
	else
		return
	end
	--end
	
	
	-- counter
	local jump = jumps-1
	if jump <0 then
		return
	end
	-- next target
	local nextTarget = nil
	-- if target and target~=source then
	-- 	nextTarget = target
	-- else
		-- Find ally nearby
	local allies = FindUnitsInRadius(
		target:GetTeamNumber(),	-- int, your team number
		target:GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		self.bounce_radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_FRIENDLY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		0,	-- int, flag filter
		FIND_CLOSEST,	-- int, order filter
		false	-- bool, can grow cache
	)

	stableSort(allies,function (a, b)
		return a:GetHealthPercent()<b:GetHealthPercent()
	end)
	
	for _,ally in pairs(allies) do
		local pass = false
		for _,unit in pairs(self.healedUnits) do
			if ally==unit then
				pass = true
			end
		end
		-- if ally:GetHealth()==ally:GetMaxHealth() then
		-- 	pass = true
		-- end
		if not pass then
			nextTarget = ally
			break
		end
	end
	--end

	if nextTarget then
		
		self:Jump( jump, target, nextTarget )
	else
		return
	end

	-- Play effects
	

end

--------------------------------------------------------------------------------
function demi_human_mend:PlayEffects1( source, target )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_dazzle/dazzle_shadow_wave.vpcf"

	if not target then
		target = source
	end

	-- Create Particle
	 local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, source )
	
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		source,
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		source:GetOrigin(), -- unknown
		true -- unknown, true
	)
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		1,
		target,
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		target:GetOrigin(), -- unknown
		true -- unknown, true
	)
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

function demi_human_mend:PlayEffects2( target )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_dazzle/dazzle_shadow_wave_impact_damage.vpcf"

	-- Create Particle
	 local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		target,
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		target:GetOrigin(), -- unknown
		true -- unknown, true
	)
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

modifier_demi_human_motar_tag = class({
IsHidden                = function(self) return true end,
IsPurgable              = function(self) return false end,
IsDebuff                = function(self) return false end,
IsBuff                  = function(self) return true end,
RemoveOnDeath           = function(self) return true end,
AllowIllusionDuplicate           = function(self) return false end,
GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})