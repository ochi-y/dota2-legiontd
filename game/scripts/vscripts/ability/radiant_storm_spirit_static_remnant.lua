LinkLuaModifier("modifier_radiant_storm_spirit_static_remnant", "ability/radiant_storm_spirit_static_remnant.lua",
	LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_radiant_storm_spirit_static_remnant_thinker", "ability/radiant_storm_spirit_static_remnant.lua",
	LUA_MODIFIER_MOTION_NONE)

--Abilities
if radiant_storm_spirit_static_remnant == nil then
	radiant_storm_spirit_static_remnant = class({})
end

-- Hero_StormSpirit.StaticRemnantExplode
function radiant_storm_spirit_static_remnant:OnSpellStart()
	local caster = self:GetCaster()
	--EmitSoundOn("Hero_StormSpirit.StaticRemnantPlant", caster)
	local pos = self:GetCursorPosition()
	local dir = (pos - caster:GetAbsOrigin()):Normalized()
	local spawnPos = caster:GetAbsOrigin() + 10 * (pos - caster:GetAbsOrigin()):Normalized()
	local duration = self:GetSpecialValueFor("duration")
	local thinker = CreateModifierThinker(
		caster,                                           -- player source
		self,                                             -- ability source
		"modifier_radiant_storm_spirit_static_remnant_thinker", -- modifier name
		{ duration = duration, x = dir.x, y = dir.y },    -- kv
		spawnPos,
		caster:GetTeamNumber(),
		false
	)
	thinker:SetForwardVector(dir)
end

-------------------------------------------------------------------------------------------------------
-- modifier   ---------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
modifier_radiant_storm_spirit_static_remnant_thinker = class({
	IsHidden = function(self)
		return false
	end,
	IsPurgable = function(self)
		return false
	end,
	IsDebuff = function(self)
		return false
	end,
	IsBuff = function(self)
		return true
	end,
	RemoveOnDeath = function(self)
		return true
	end,
	GetAttributes = function(self)
		return MODIFIER_ATTRIBUTE_NONE
	end
})
function modifier_radiant_storm_spirit_static_remnant_thinker:AllowIllusionDuplicate()
	return false
end

function modifier_radiant_storm_spirit_static_remnant_thinker:OnCreated(params)
	if not self:GetAbility() then return end

	local ability = self:GetAbility()
	self.static_remnant_radius = ability:GetSpecialValueFor("static_remnant_radius")
	self.static_remnant_damage_radius = ability:GetSpecialValueFor("static_remnant_damage_radius")
	self.static_remnant_delay = ability:GetSpecialValueFor("static_remnant_delay")
	self.static_remnant_damage = ability:GetSpecialValueFor("static_remnant_damage")
	self.move_distance = ability:GetSpecialValueFor("move_distance")
	self.air_pct = ability:GetSpecialValueFor("air_pct")
	self.speed = 200
	self.x = params.x
	self.y = params.y
	if not IsServer() then return end
	-- self.damage = params.damage
	-- self:SetHasCustomTransmitterData(true)
	self.startPos = self:GetParent():GetAbsOrigin()
	self:StartIntervalThink(0.03)
	self:PlayEffects()

	self.caster = self:GetCaster()
	self.parent = self:GetParent()
end

function modifier_radiant_storm_spirit_static_remnant_thinker:OnRefresh(params)

end

function modifier_radiant_storm_spirit_static_remnant_thinker:OnDestroy(params)
	if not IsServer() then return end
	local parent = self.parent
	local caster = self.caster

	local enemies = FindUnitsInRadius(
		caster:GetTeamNumber(),                   -- int, your team number
		parent:GetOrigin(),                       -- point, center point
		nil,                                      -- handle, cacheUnit. (not known)
		self.static_remnant_damage_radius,        -- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,              -- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, -- int, type filter
		0,                                        -- int, flag filter
		0,                                        -- int, order filter
		false                                     -- bool, can grow cache
	)
	for _, enemy in pairs(enemies) do
		-- apply damage
		local damage = self.static_remnant_damage
		if enemy:HasFlyMovementCapability() then
			damage = damage * self.air_pct / 100
		end
		SimpleApplyDamage(self:GetAbility(), caster, enemy, damage)
	end
	-- play effects
	local sound_cast = "Hero_StormSpirit.StaticRemnantExplode"
	EmitSoundOn(sound_cast, parent)
	-- delete
	UTIL_Remove(parent)
end

function modifier_radiant_storm_spirit_static_remnant_thinker:DeclareFunctions()
	return {
	}
end

function modifier_radiant_storm_spirit_static_remnant_thinker:OnIntervalThink()
	local parent = self:GetParent()
	local caster = self:GetCaster()

	if self:GetElapsedTime() > self.static_remnant_delay then
		local enemies = FindUnitsInRadius(
			caster:GetTeamNumber(),                -- int, your team number
			parent:GetOrigin(),                    -- point, center point
			nil,                                   -- handle, cacheUnit. (not known)
			self.static_remnant_radius,            -- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_ENEMY,           -- int, team filter
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, -- int, type filter
			0,                                     -- int, flag filter
			0,                                     -- int, order filter
			false                                  -- bool, can grow cache
		)
		if #enemies > 0 then
			self:Destroy()
			return
		end
	end



	local dis = (parent:GetAbsOrigin() - self.startPos):Length2D()
	if dis < self.move_distance then
		local newPos = parent:GetAbsOrigin() + 0.03 * self.speed * Vector(self.x, self.y, 0)
		-- print(newPos)
		parent:SetAbsOrigin(newPos)
	end

	AddFOWViewer(parent:GetTeamNumber(), parent:GetAbsOrigin(), 100, 1, true)
end

function modifier_radiant_storm_spirit_static_remnant_thinker:CheckState()
	local state = {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
	}

	return state
end

function modifier_radiant_storm_spirit_static_remnant_thinker:PlayEffects()
	-- Get Resources
	local particle_cast = "particles/legiontd/stormspirit_static_remnant.vpcf"
	local sound_cast = "Hero_StormSpirit.StaticRemnantPlant"

	local parent = self:GetParent()
	local caster = self:GetCaster()
	-- Create Particle


	-- local effect=ParticleManager:CreateParticle("_.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	-- ParticleManager:SetParticleControlEnt(effect, 0, caster, PATTACH_ABSORIGIN_FOLLOW, nil,
	-- caster:GetAbsOrigin(), true)
	-- ParticleManager:SetParticleControl(effect, 1, Vector(500,500,500))
	-- -- ParticleManager:ReleaseParticleIndex(effect)
	-- self:AddParticle(effect, false, false, -1, false, false)

	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, parent)
	ParticleManager:SetParticleControlEnt(effect_cast, 0, parent, PATTACH_ABSORIGIN_FOLLOW, nil,
		parent:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlForward(effect_cast, 0, caster:GetForwardVector())
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		1,
		caster,
		PATTACH_POINT,
		"attach_hitloc",
		Vector(0, 0, 0), -- unknown
		true       -- unknown, true
	)
	ParticleManager:SetParticleControl(effect_cast, 2, Vector(ACT_DOTA_CAST_ABILITY_1, 1, 0))

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
	EmitSoundOn(sound_cast, caster)
end
