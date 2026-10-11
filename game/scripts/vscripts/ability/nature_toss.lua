-- Created by Elfansoer
--[[
Ability checklist (erase if done/checked):
- Scepter Upgrade
- Break behavior
- Linken/Reflect behavior
- Spell Immune/Invulnerable/Invisible behavior
- Illusion behavior
- Stolen behavior
]]
--------------------------------------------------------------------------------
nature_toss = class({})
LinkLuaModifier("modifier_nature_toss", "ability/nature_toss", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_generic_arc_lua", "lua_abilities/generic/modifier_generic_arc_lua", LUA_MODIFIER_MOTION_BOTH)

--------------------------------------------------------------------------------
-- Custom KV
-- AOE Radius
function nature_toss:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

--------------------------------------------------------------------------------
-- Ability Cast Filter
function nature_toss:CastFilterResultTarget(hTarget)
	if self:GetCaster() == hTarget then
		return UF_FAIL_CUSTOM
	end

	local b = self:FindEnemies()
	if b == nil then
		return UF_FAIL_CUSTOM
	end
	return UF_SUCCESS
end

function nature_toss:GetCustomCastErrorTarget(hTarget)
	if self:GetCaster() == hTarget then
		return "#dota_hud_error_cant_cast_on_self"
	end

	return "#dota_hud_error_nothing_to_toss"
end

--------------------------------------------------------------------------------
-- Helper
function nature_toss:FindEnemies()
	local caster = self:GetCaster()
	local radius = self:GetSpecialValueFor("grab_radius")

	-- find unit around tiny
	local units = FindUnitsInRadius(
		caster:GetTeamNumber(),                   -- int, your team number
		caster:GetOrigin(),                       -- point, center point
		nil,                                      -- handle, cacheUnit. (not known)
		radius,                                   -- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_BOTH,               -- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, -- int, type filter
		0,                                        -- int, flag filter
		FIND_CLOSEST,                             -- int, order filter
		false                                     -- bool, can grow cache
	)
	-- print(#units)
	local target
	for _, unit in pairs(units) do
		local filter1 = (unit ~= caster) and
			(not unit:FindModifierByName('modifier_nature_toss'))
		-- local filter2 = (unit:GetTeamNumber() == caster:GetTeamNumber()) or (not unit:IsInvisible())
		if filter1 then
			--if filter2 then
			target = unit
			break
			--end
		end
	end

	return target
end

--------------------------------------------------------------------------------
-- Ability Phase Start
function nature_toss:OnAbilityPhaseInterrupted()

end

function nature_toss:OnAbilityPhaseStart()
	local b = self:FindEnemies()

	self:GetCaster():StartGesture(ACT_TINY_TOSS)
	return b ~= nil
	-- return true -- if success
end

--------------------------------------------------------------------------------
-- Ability Start
function nature_toss:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	-- local point = self:GetCursorPosition()

	-- get victim
	local victim = self:FindEnemies()

	-- add modifier
	victim:AddNewModifier(
		caster,           -- player source
		self,             -- ability source
		"modifier_nature_toss", -- modifier name
		{
			target = target:entindex(),
		} -- kv
	)
end

--------------------------------------------------------------------------------
modifier_nature_toss = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_nature_toss:IsHidden()
	return true
end

function modifier_nature_toss:IsDebuff()
	return self:GetCaster():GetTeamNumber() ~= self:GetParent():GetTeamNumber()
end

function modifier_nature_toss:IsStunDebuff()
	return true
end

function modifier_nature_toss:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_nature_toss:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()

	-- references
	self.damage = self:GetAbility():GetSpecialValueFor("toss_damage")
	self.radius = self:GetAbility():GetSpecialValueFor("radius")

	local unit_count = self:GetAbility():GetSpecialValueFor("unit_count")

	if not IsServer() then return end
	local duration = self:GetAbility():GetSpecialValueFor("duration")
	self.target = EntIndexToHScript(kv.target)
	local height = 850

	-- add arc modifier for vertical only
	self.arc = self.parent:AddNewModifier(
		self.caster,          -- player source
		self:GetAbility(),    -- ability source
		"modifier_generic_arc_lua", -- modifier name
		{
			duration = duration,
			distance = 0,
			height = height,
			-- fix_end = true,
			fix_duration = false,
			isStun = true,
			activity = ACT_DOTA_FLAIL,
		} -- kv
	)
	self.arc:SetEndCallback(function(interrupted)
		-- destroy this modifier
		self:Destroy()

		-- not damage if interrupted
		if interrupted then return end

		-- find units
		local enemies = FindUnitsInRadius(
			self.caster:GetTeamNumber(),           -- int, your team number
			self.parent:GetOrigin(),               -- point, center point
			nil,                                   -- handle, cacheUnit. (not known)
			self.radius,                           -- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_ENEMY,           -- int, team filter
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, -- int, type filter
			0,                                     -- int, flag filter
			0,                                     -- int, order filter
			false                                  -- bool, can grow cache
		)

		enemies = subrange(enemies, 1, unit_count)

		-- precache damage
		local damageTable = {
			-- victim = target,
			attacker = self.caster,
			damage = self.damage,
			damage_type = self:GetAbility():GetAbilityDamageType(),
			ability = self:GetAbility(), --Optional.
		}

		-- damage
		for _, enemy in pairs(enemies) do
			-- damage
			damageTable.victim = enemy
			if enemy == self.parent then
				damageTable.damage = 2 * self.damage
			else
				damageTable.damage = self.damage
			end
			ApplyDamage(damageTable)
		end

		-- destroy trees
		GridNav:DestroyTreesAroundPoint(self.parent:GetOrigin(), self.radius, false)


		-- play effects
		local sound_cast = "Ability.TossImpact"
		EmitSoundOn(sound_cast, self.parent)
	end)

	-- prepare horizontal motion
	local origin = self.target:GetOrigin()
	local direction = origin - self.parent:GetOrigin()
	local distance = direction:Length2D()
	direction.z = 0
	direction = direction:Normalized()

	-- init speed
	self.distance = distance
	if self.distance == 0 then self.distance = 1 end
	self.duration = duration
	self.speed = distance / duration
	self.accel = 100
	self.max_speed = 3000

	-- apply motion
	if not self:ApplyHorizontalMotionController() then
		self:Destroy()
	end

	-- emit sound
	local sound_cast = "Ability.TossThrow"
	local sound_target = "Hero_Tiny.Toss.Target"
	EmitSoundOn(sound_cast, self.caster)
	EmitSoundOn(sound_target, self.parent)
end

function modifier_nature_toss:OnRefresh(kv)

end

function modifier_nature_toss:OnRemoved()
end

function modifier_nature_toss:OnDestroy()
	if not IsServer() then return end
	self:GetParent():RemoveHorizontalMotionController(self)
end

--------------------------------------------------------------------------------
-- Status Effects
function modifier_nature_toss:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
	}

	return state
end

--------------------------------------------------------------------------------
-- Motion Effects
function modifier_nature_toss:UpdateHorizontalMotion(me, dt)
	local target = self.target:GetOrigin()
	local parent = self.parent:GetOrigin()

	-- get current states
	local duration = self:GetElapsedTime()
	local direction = target - parent
	local distance = direction:Length2D()
	direction.z = 0
	direction = direction:Normalized()

	-- change speed if target farther/closer
	local original_distance = duration / self.duration * self.distance
	local expected_speed
	if self:GetElapsedTime() >= self.duration then
		expected_speed = self.speed
	else
		expected_speed = distance / (self.duration - self:GetElapsedTime())
	end

	-- accel/deccel speed
	if self.speed < expected_speed then
		self.speed = math.min(self.speed + self.accel, self.max_speed)
	elseif self.speed > expected_speed then
		self.speed = math.max(self.speed - self.accel, 0)
	end

	-- set relative position
	local pos = parent + direction * self.speed * dt
	me:SetOrigin(pos)
end

function modifier_nature_toss:OnHorizontalMotionInterrupted()
	self:Destroy()
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_nature_toss:GetEffectName()
	return "particles/units/heroes/hero_tiny/tiny_toss_blur.vpcf"
end

function modifier_nature_toss:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
