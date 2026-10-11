element_ice_wall = class({})
element_ice_wall.ice_wall_effect = "particles/units/heroes/hero_invoker/invoker_ice_wall.vpcf"
LinkLuaModifier("modifier_element_ice_wall", "ability/element_ice_wall",
	LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_element_ice_wall_slow", "ability/element_ice_wall",
	LUA_MODIFIER_MOTION_NONE)
-- function element_ice_wall:GetCastAnimation()
-- 	return ACT_DOTA_CAST_ICE_WALL
-- end

function element_ice_wall:OnSpellStart()
	if IsServer() then
		local caster                          = self:GetCaster()
		local caster_point                    = caster:GetAbsOrigin()

		local caster_direction                = ((self:GetCursorPosition()) - caster:GetAbsOrigin()):Normalized()

		local ability                         = caster:FindAbilityByName("element_ice_wall")
		local cast_direction                  = Vector(-caster_direction.y, caster_direction.x, caster_direction.z)
		-- Get the Skills stats
		local ice_wall_placement_distance     = ability:GetSpecialValueFor("wall_placement_distance")
		local ice_wall_length                 = ability:GetSpecialValueFor("wall_length")
		local ice_wall_slow_duration          = ability:GetSpecialValueFor("slow_duration")
		local ice_wall_damage_interval        = ability:GetSpecialValueFor("damage_interval")
		local ice_wall_area_of_effect         = ability:GetSpecialValueFor("wall_element_radius")
		local ice_wall_duration               = ability:GetSpecialValueFor("duration")
		local ice_wall_slow                   = ability:GetSpecialValueFor("slow")
		local ice_wall_damage_per_second      = ability:GetSpecialValueFor("damage_per_second")

		local ice_wall_effects                = ""
		local ice_wall_spike_effects          = ""

		--local target_point 						= caster_point + (caster_direction * ice_wall_placement_distance)
		ability.endpoint_distance_from_center = (cast_direction * ice_wall_length) / 2
		--local ice_wall_end_point 			= target_point - endpoint_distance_from_center

		self:GetCaster():StartGesture(ACT_DOTA_CAST_ICE_WALL)

		-- Play Ice Wall sound
		EmitSoundOn("Hero_Invoker.IceWall.Cast", caster)

		local ice_wall_offset = 0
		local z_offset        = 0



		--local target_point = caster_point + (caster_direction * ice_wall_placement_distance + (ice_wall_offset * i))
		local target_point = self:GetCursorPosition()
		target_point = GetGroundPosition(target_point, caster)

		local ice_wall_point = target_point
		ice_wall_point.z = ice_wall_point.z - z_offset


		--Display the Ice Wall particles in a line.
		local ice_wall_particle_effect = ParticleManager:CreateParticle(element_ice_wall.ice_wall_effect,
			PATTACH_CUSTOMORIGIN, nil)

		local posStart = ice_wall_point - ability.endpoint_distance_from_center
		local posEnd = ice_wall_point + ability.endpoint_distance_from_center

		-- print(ice_wall_point)
		-- print(ability.endpoint_distance_from_center)
		-- print(posStart)
		-- print(posEnd)

		ParticleManager:SetParticleControl(ice_wall_particle_effect, 0,
			posStart)
		ParticleManager:SetParticleControl(ice_wall_particle_effect, 1,
			Vector(posEnd.x, posEnd.y, 200))

		local ice_wall_particle_effect_spikes = ParticleManager:CreateParticle(
			"particles/units/heroes/hero_invoker/invoker_ice_wall_b.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(ice_wall_particle_effect_spikes, 0,
			posStart)
		ParticleManager:SetParticleControl(ice_wall_particle_effect_spikes, 1,
			posEnd)

		-- if ice_wall_effects == "" then
		-- 	ice_wall_effects = string.format("%d", ice_wall_particle_effect)
		-- else
		-- 	ice_wall_effects = string.format("%s %d", ice_wall_effects, ice_wall_particle_effect)
		-- end

		-- if ice_wall_effects == "" then
		-- 	ice_wall_spike_effects = string.format("%d", ice_wall_particle_effect_spikes)
		-- else
		-- 	ice_wall_spike_effects = string.format("%s %d", ice_wall_spike_effects, ice_wall_particle_effect_spikes)
		-- end
		ice_wall_effects = ice_wall_particle_effect
		ice_wall_spike_effects = ice_wall_particle_effect_spikes

		-- local thinker_point = caster_point
		-- local thinger_area  = ice_wall_area_of_effect
		-- if ice_walls - 1 == 0 then
		-- 	thinker_point = thinker_point + (caster_direction * ice_wall_placement_distance)
		-- else
		-- 	thinker_point = thinker_point +
		-- 		(caster_direction * ice_wall_placement_distance + (ice_wall_offset * ((ice_walls - 1) / 2)))
		-- 	ice_wall_area_of_effect = ice_wall_area_of_effect + (100 * ((ice_walls - 1) / 2))
		-- end

		CreateModifierThinker(
			caster,
			ability,
			"modifier_element_ice_wall",
			{
				duration                        = ice_wall_duration,
				ice_wall_damage_interval        = ice_wall_damage_interval,
				ice_wall_slow_duration          = ice_wall_slow_duration,
				ice_wall_slow                   = ice_wall_slow,
				ice_wall_damage_per_second      = ice_wall_damage_per_second,
				ice_wall_area_of_effect         = ice_wall_area_of_effect,
				ice_wall_length                 = ice_wall_length,
				ice_wall_particle_effect        = ice_wall_effects,
				ice_wall_particle_effect_spikes = ice_wall_spike_effects
			}, target_point, caster:GetTeamNumber(), false)
	end
end

--------------------------------------------------------------------------------------------------------------------
--	Invoker's: Ice Wall modifier
--------------------------------------------------------------------------------------------------------------------
modifier_element_ice_wall = class({})
modifier_element_ice_wall.npc_radius_constant = 65
function modifier_element_ice_wall:OnCreated(kv)
	if IsServer() then
		local ice_wall_damage_interval       = kv.ice_wall_damage_interval
		self.slow_duration                   = kv.ice_wall_slow_duration
		self.ice_wall_slow                   = kv.ice_wall_slow
		self.attack_slow                     = kv.attack_slow
		-- damage per second... i.e multiply with the time and we get the correct value
		self.ice_wall_damage_per_second      = kv.ice_wall_damage_per_second * kv.ice_wall_damage_interval
		self.ice_wall_area_of_effect         = kv.ice_wall_area_of_effect
		self.ice_wall_length                 = kv.ice_wall_length
		self.search_area                     = kv.ice_wall_length + (kv.ice_wall_area_of_effect * 2)
		self.GetTeam                         = self:GetParent():GetTeam()
		self.origin                          = self:GetParent():GetAbsOrigin()
		self.ability                         = self:GetAbility()
		self.endpoint_distance_from_center   = self:GetAbility().endpoint_distance_from_center
		self.ice_wall_start_point            = self.origin - self.endpoint_distance_from_center
		self.ice_wall_end_point              = self.origin + self.endpoint_distance_from_center
		self.ice_wall_particle_effect        = kv.ice_wall_particle_effect
		self.ice_wall_particle_effect_spikes = kv.ice_wall_particle_effect_spikes


		self:StartIntervalThink(ice_wall_damage_interval)
	end
end

function modifier_element_ice_wall:OnIntervalThink()
	if IsServer() then
		local nearby_enemy_units = FindUnitsInRadius(
			self.GetTeam,
			self.origin,
			nil,
			self.search_area,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			DOTA_UNIT_TARGET_FLAG_NONE,
			FIND_ANY_ORDER,
			false)


		for _, enemy in pairs(nearby_enemy_units) do
			if enemy ~= nil and enemy:IsAlive() then
				local target_position = enemy:GetAbsOrigin()
				if self:IsUnitInProximity(self.ice_wall_start_point, self.ice_wall_end_point, target_position, self.ice_wall_area_of_effect) then

					local duration = self.slow_duration * (1 - CalUnitStatusResistance(enemy))

					enemy:AddNewModifier(self:GetCaster(), self.ability, "modifier_element_ice_wall_slow",
						{
							duration = duration,
							enemy_slow = self.ice_wall_slow
						})

					
				end
			end
		end
	end
end

function modifier_element_ice_wall:OnRemoved()
	if self.ice_wall_particle_effect ~= nil then
		-- for effect in string.gmatch(self.ice_wall_particle_effect, "([^ ]+)") do
		-- 	ParticleManager:DestroyParticle(tonumber(effect), false)
		-- end
		ParticleManager:DestroyParticle(self.ice_wall_particle_effect, false)
	end
	if self.ice_wall_particle_effect_spikes ~= nil then
		-- for effect in string.gmatch(self.ice_wall_particle_effect_spikes, "([^ ]+)") do
		-- 	ParticleManager:DestroyParticle(tonumber(effect), false)
		-- end
		ParticleManager:DestroyParticle(self.ice_wall_particle_effect_spikes, false)
	end
end

--------------------------------------------------------------------------------------------------------------------
--	Help function - check proximity of target vs ice_wall - beware contains maths... ._.
--------------------------------------------------------------------------------------------------------------------
function modifier_element_ice_wall:IsUnitInProximity(start_point, end_point, target_position, ice_wall_radius)
	-- craete vector which makes up the ice wall
	local ice_wall = end_point - start_point
	-- create vector for target relative to start_point of the ice wall
	local target_vector = target_position - start_point

	local ice_wall_normalized = ice_wall:Normalized()
	-- create a dot vector of the normalized ice_wall vector
	local ice_wall_dot_vector = target_vector:Dot(ice_wall_normalized)
	-- here we will store the targeted enemies closest position
	local search_point
	-- if all the datapoints in the dot vector is below 0 then the target is outside our search hence closest point is start_point.
	if ice_wall_dot_vector <= 0 then
		search_point = start_point

		-- if all th datapoinst in the dot vector is above the max length of our search then there closest point is the end_point
	elseif ice_wall_dot_vector >= ice_wall:Length2D() then
		search_point = end_point

		-- if a datapoinst in the dot vector within range then the closest position is...
	else
		search_point = start_point + (ice_wall_normalized * ice_wall_dot_vector)
	end
	-- with all that setup we can now get the distance from our ice_wall! :D
	local distance = target_position - search_point
	-- Is the distance less then our "area of effect" radius? true/false
	return distance:Length2D() <= ice_wall_radius + modifier_element_ice_wall.npc_radius_constant
end

--------------------------------------------------------------------------------------------------------------------
--	Invoker's: Ice Wall slow aura
--------------------------------------------------------------------------------------------------------------------
modifier_element_ice_wall_slow = class({})
function modifier_element_ice_wall_slow:IsPassive() return false end

function modifier_element_ice_wall_slow:IsBuff() return false end

function modifier_element_ice_wall_slow:IsDebuff() return true end

function modifier_element_ice_wall_slow:IsPurgable() return false end

function modifier_element_ice_wall_slow:IsHidden() return false end

function modifier_element_ice_wall_slow:GetEffectName()
	return
	"particles/units/heroes/hero_invoker/invoker_ice_wall_debuff.vpcf"
end

function modifier_element_ice_wall_slow:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
	return funcs
end

function modifier_element_ice_wall_slow:GetTexture()
	return "invoker_ice_wall"
end

function modifier_element_ice_wall_slow:OnCreated(kv)
	if IsServer() then

		local ability=self:GetAbility()
		self.damage_per_second=ability:GetSpecialValueFor("damage_per_second")
		
		self.caster = self:GetCaster()
		self.parent = self:GetParent()
		self:SetStackCount(kv.enemy_slow)
		self:StartIntervalThink(0.5)
		self:OnIntervalThink()
		
		-- Apply Ice wall slow effect
		-- self.ice_wall_effect_aura = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_ice_wall_debuff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
	end
end

function modifier_element_ice_wall_slow:OnRefresh(kv)
	if IsServer() then
		self:SetStackCount(kv.enemy_slow)
	end
end

function modifier_element_ice_wall_slow:OnIntervalThink(kv)
	if not IsServer() then return end

	local ability=self:GetAbility()
	-- Apply damage
	local damage_table       = {}
	damage_table.attacker    = self:GetCaster()
	damage_table.victim      = self:GetParent()
	damage_table.ability     = ability
	damage_table.damage_type = ability:GetAbilityDamageType()
	damage_table.damage      = self.damage_per_second*0.5
	ApplyDamage(damage_table)
end


function modifier_element_ice_wall_slow:OnRemoved()
	if IsServer() then
		if self.ice_wall_effect_aura ~= nil then
			--ParticleManager:DestroyParticle(self.ice_wall_effect_aura, false)
		end
	end
end

function modifier_element_ice_wall_slow:GetModifierMoveSpeedBonus_Percentage()
	return self:GetStackCount()
end
