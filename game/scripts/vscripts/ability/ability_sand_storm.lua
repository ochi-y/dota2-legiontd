LinkLuaModifier( "modifier_ability_sand_storm", "ability/ability_sand_storm", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ability_sand_storm_invis", "ability/ability_sand_storm", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ability_sand_storm_invis_delay", "ability/ability_sand_storm", LUA_MODIFIER_MOTION_NONE )

ability_sand_storm = {}

wave_3_champion_sand_storm=ability_sand_storm

function ability_sand_storm:OnSpellStart()
	local caster = self:GetCaster()



	-- CreateModifierThinker(
	-- 	self:GetParent(),
	-- 	self:GetAbility(),
	-- 	"modifier_element_water_splash_thinker",
	-- 	{},
	-- 	params.target:GetAbsOrigin(),
	-- 	self:GetParent():GetTeamNumber(),
	-- 	false
	-- )


	caster:AddNewModifier( caster, self, "modifier_ability_sand_storm", {
		duration = self:GetDuration()
	} )
	caster:AddNewModifier( caster, self, "modifier_ability_sand_storm_invis", {
		duration = self:GetDuration()
	} )

	EmitSoundOn( "Ability.SandKing_SandStorm.start", caster )
end

modifier_ability_sand_storm = {}

function modifier_ability_sand_storm:IsHidden()
	return true
end

function modifier_ability_sand_storm:OnCreated()
	if IsClient() then
		return
	end

	local ability = self:GetAbility()
	local parent = self:GetParent()

	self.damageCenterPos=parent:GetAbsOrigin()

	self.radius = ability:GetSpecialValueFor( "sand_storm_radius" )
	self.damage_interval = ability:GetSpecialValueFor( "damage_tick_rate" )
	self.next_damage_time = GameRules:GetGameTime() + self.damage_interval
	self.start_pos = parent:GetAbsOrigin()
	self.damageTable = {
		attacker = parent,
		damage = ability:GetSpecialValueFor( "sand_storm_damage" ) * self.damage_interval,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = ability
	}
	self.effect = ParticleManager:CreateParticle(
		"particles/units/heroes/hero_sandking/sandking_sandstorm.vpcf",
		PATTACH_WORLDORIGIN,
		nil
	)
	ParticleManager:SetParticleControl( self.effect, 0, parent:GetAbsOrigin() +Vector( 0, 0, 10 ))
	ParticleManager:SetParticleControl( self.effect, 1, Vector( self.radius, self.radius, self.radius ) )

	EmitSoundOn( "Ability.SandKing_SandStorm.start", parent )

	self:StartIntervalThink( self.damage_interval )
end

function modifier_ability_sand_storm:OnDestroy()
	if not IsServer() then return end
	ParticleManager:DestroyParticle( self.effect, false )
	self:GetParent():RemoveModifierByName( "modifier_ability_sand_storm_invis" )
end

function modifier_ability_sand_storm:OnIntervalThink()
	if ( self.start_pos - self:GetParent():GetAbsOrigin() ):Length2D() > self.radius then
		self:Destroy()

		return
	end

	self:Damage()

	-- if GameRules:GetGameTime() >= self.next_damage_time then
	-- 	self:Damage()
	-- end
end

function modifier_ability_sand_storm:Damage()
	local parent = self:GetParent()
	local enemies = FindUnitsInRadius(
		parent:GetTeamNumber(),
		self.damageCenterPos,
		nil,
		self.radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		0,
		0,
		false
	)

	for _,enemy in pairs(enemies) do
		self.damageTable.victim = enemy
		ApplyDamage( self.damageTable )
	end
end

function modifier_ability_sand_storm:DeclareFunctions()
	return { MODIFIER_EVENT_ON_ATTACK_LANDED }
end

function modifier_ability_sand_storm:OnAttackLanded( params )
	if IsClient() then
		return
	end
	local caster = self:GetCaster()
	local ability = self:GetAbility()

	local target = params.unit if target == nil then target = params.target end
	local attacker = params.attacker


	local parent = self:GetParent()

	if attacker == caster then 
		parent:RemoveModifierByName( "modifier_ability_sand_storm_invis" )
		parent:AddNewModifier(
			parent,
			self,
			"modifier_ability_sand_storm_invis_delay",
			{ duration = self:GetAbility():GetSpecialValueFor( "fade_delay" ) }
		)
		-- parent:CalculateGenericBonuses()
	end

	
end

modifier_ability_sand_storm_invis = {}

function modifier_ability_sand_storm_invis:IsHidden()
	return false
end
function modifier_ability_sand_storm_invis:DeclareFunctions()
	return { MODIFIER_PROPERTY_INVISIBILITY_LEVEL }
end

function modifier_ability_sand_storm_invis:GetModifierInvisibilityLevel()
	return 1
end

function modifier_ability_sand_storm_invis:CheckState()
	return { [MODIFIER_STATE_INVISIBLE] = true }
end

modifier_ability_sand_storm_invis_delay = {}

function modifier_ability_sand_storm_invis_delay:IsHidden()
	return true
end

function modifier_ability_sand_storm_invis_delay:OnDestroy()
	if not IsServer() then return end
	local parent = self:GetParent()
	local modifier = parent:FindModifierByName( "modifier_ability_sand_storm" )

	if modifier then
		parent:AddNewModifier( parent,self:GetAbility() , "modifier_ability_sand_storm_invis", {
			duration = modifier:GetRemainingTime()
		} )
	end
end

