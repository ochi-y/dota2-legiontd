
--------------------------------------------------------------------------------
ghost_eye_of_the_storm = class({})
LinkLuaModifier( "modifier_ghost_eye_of_the_storm", "ability/ghost_eye_of_the_storm", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ghost_eye_of_the_storm_debuff", "ability/ghost_eye_of_the_storm", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Init Abilities
function ghost_eye_of_the_storm:Precache( context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_razor.vsndevts", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_razor/razor_eye_of_the_storm.vpcf", context )
end

function ghost_eye_of_the_storm:Spawn()
	if not IsServer() then return end
end

-- Ability Start
function ghost_eye_of_the_storm:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()

	-- load data
	local duration = self:GetSpecialValueFor( "duration" )

	-- add modifier
	caster:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_ghost_eye_of_the_storm", -- modifier name
		{ duration = duration } -- kv
	)
	caster:StartGesture(ACT_DOTA_OVERRIDE_ABILITY_4)
end


--------------------------------------------------------------------------------
modifier_ghost_eye_of_the_storm = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_ghost_eye_of_the_storm:IsHidden()
	return false
end

function modifier_ghost_eye_of_the_storm:IsDebuff()
	return false
end

function modifier_ghost_eye_of_the_storm:IsPurgable()
	return true
end

-- Optional Classifications
function modifier_ghost_eye_of_the_storm:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_ghost_eye_of_the_storm:OnCreated( kv )
	self.parent = self:GetParent()

	-- references
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
	self.damage = self:GetAbility():GetSpecialValueFor( "damage" )
	self.interval = self:GetAbility():GetSpecialValueFor( "strike_interval" )
	self.armor = self:GetAbility():GetSpecialValueFor( "armor_reduction" )

	if not IsServer() then return end
	
	self.strikes = 1
	if self.parent:HasScepter() then
		self.strikes = self.strikes + 1
		self.building = true
	end
	self.targets = {}

	-- ability properties
	self.abilityDamageType = self:GetAbility():GetAbilityDamageType()


	

	-- precache damage
	self.damageTable = {
		-- victim = target,
		attacker = self.parent,
		damage = 0,
		damage_type = self.abilityDamageType,
		ability = self:GetAbility(), --Optional.
	}
	-- ApplyDamage(damageTable)

	-- Start interval
	self:StartIntervalThink( self.interval )
	self:OnIntervalThink()

	-- play effects
	self:PlayEffects1()
end

function modifier_ghost_eye_of_the_storm:OnRefresh( kv )
end

function modifier_ghost_eye_of_the_storm:OnRemoved()
end

function modifier_ghost_eye_of_the_storm:OnDestroy()
	if not IsServer() then return end
	-- stop sound
	local sound_loop = "Hero_Razor.Storm.Loop"
	local sound_end = "Hero_Razor.StormEnd"
	StopSoundOn( sound_loop, self.parent )
	EmitSoundOn( sound_end, self.parent )
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_ghost_eye_of_the_storm:OnIntervalThink()
	local targets = {}

	local type_filter = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
	if self.building then
		type_filter = type_filter + DOTA_UNIT_TARGET_BUILDING
	end

	-- find enemies
	local enemies = FindUnitsInRadius(
		self.parent:GetTeamNumber(),	-- int, your team number
		self.parent:GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		type_filter,	-- int, type filter
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)
	if #enemies<1 then return end

	-- sort based on health
	table.sort( enemies, function( left, right )
		return left:GetHealth() < right:GetHealth()
	end)

	-- find static-linked enemies (modifier name subject to change)
	local linked = {}
	for i,enemy in ipairs(enemies) do
		if enemy:HasModifier( "modifier_static_link_lua" ) then
			table.insert( linked, enemy )
		end
	end

	-- find enemies based on number of strikes per interval
	for i=1,self.strikes do
		local target
		-- find enemies in linked
		for _,enemy in pairs(linked) do
			if not targets[enemy] then
				targets[enemy] = true
				target = enemy
				break
			end
		end
		if target then break end
		-- find target in lowest
		for _,enemy in pairs(enemies) do
			if not targets[enemy] then
				-- check building
				if not enemy:IsBuilding() then
					targets[enemy] = true
					target = enemy
					break
				elseif (enemy:IsAncient() or enemy:IsTower() or enemy:IsBarracks()) then
					targets[enemy] = true
					target = enemy
					break
				end
			end
		end
	end

	-- strike targets
	for enemy,_ in pairs(targets) do
		-- damage
		self.damageTable.victim = enemy
		self.damageTable.damage=self.damage* SimpleGetAttackFactor(self.parent,enemy)

		ApplyDamage( self.damageTable )
		local duration = self:GetRemainingTime() * (1 - CalUnitStatusResistance(enemy))
		-- add modifier
		enemy:AddNewModifier(
			self.parent, -- player source
			self, -- ability source
			"modifier_ghost_eye_of_the_storm_debuff", -- modifier name
			{
				duration = duration,
				armor = self.armor,
			} -- kv
		)

		-- play effects
		self:PlayEffects2( enemy )
	end
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_ghost_eye_of_the_storm:PlayEffects1()
	local particle_cast = "particles/abilities/razor_rain_storm.vpcf"
	local sound_cast = "Hero_Razor.Storm.Cast"
	local sound_loop = "Hero_Razor.Storm.Loop"
	sound_loop=""

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent )

	-- buff particle
	self:AddParticle(
		effect_cast,
		false, -- bDestroyImmediately
		false, -- bStatusEffect
		-1, -- iPriority
		false, -- bHeroEffect
		false -- bOverheadEffect
	)

	-- Create Sound
	EmitSoundOn( sound_cast, self.parent )
	EmitSoundOn( sound_loop, self.parent )
end

function modifier_ghost_eye_of_the_storm:PlayEffects2( enemy )
	-- Get Resources
	local particle_cast = "particles/abilities/razor_storm_lightning_strike.vpcf"
	local sound_cast = "Hero_razor.lightning"

	-- Create Particle
	-- NOTE: Don't know what is the proper effect
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_CUSTOMORIGIN, self.parent )
	ParticleManager:SetParticleControl( effect_cast, 0, self.parent:GetOrigin() + Vector(0,0,400) )
	-- ParticleManager:SetParticleControlEnt(
	-- 	effect_cast,
	-- 	0,
	-- 	self.parent,
	-- 	PATTACH_OVERHEAD_FOLLOW,
	-- 	"attach_head",
	-- 	self.parent:GetOrigin() + Vector(0,0,300), -- unknown
	-- 	false -- unknown, true
	-- )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		1,
		enemy,
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOn( sound_cast, enemy )
end

--------------------------------------------------------------------------------
modifier_ghost_eye_of_the_storm_debuff = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_ghost_eye_of_the_storm_debuff:IsHidden()
	return false
end

function modifier_ghost_eye_of_the_storm_debuff:IsDebuff()
	return true
end

function modifier_ghost_eye_of_the_storm_debuff:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_ghost_eye_of_the_storm_debuff:OnCreated( kv )
	if not IsServer() then return end
	-- send init data from server to client
	self:SetHasCustomTransmitterData( true )

	self.armor = kv.armor
	self:SetStackCount( self.armor )
end

function modifier_ghost_eye_of_the_storm_debuff:OnRefresh( kv )
	if not IsServer() then return end
	self.armor = self.armor + kv.armor
	self:SetStackCount( self.armor )
end

function modifier_ghost_eye_of_the_storm_debuff:OnRemoved()
end

function modifier_ghost_eye_of_the_storm_debuff:OnDestroy()
end

--------------------------------------------------------------------------------
-- Transmitter data
function modifier_ghost_eye_of_the_storm_debuff:AddCustomTransmitterData()
	-- on server
	local data = {
		armor = self.armor
	}

	return data
end

function modifier_ghost_eye_of_the_storm_debuff:HandleCustomTransmitterData( data )
	-- on client
	self.armor = data.armor
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_ghost_eye_of_the_storm_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}

	return funcs
end

function modifier_ghost_eye_of_the_storm_debuff:GetModifierPhysicalArmorBonus()
	return -self.armor
end