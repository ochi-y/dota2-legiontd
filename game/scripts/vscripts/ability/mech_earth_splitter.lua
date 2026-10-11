mech_earth_splitter = class({})
LinkLuaModifier("modifier_imba_earth_splitter", "ability/mech_earth_splitter", LUA_MODIFIER_MOTION_NONE)

function mech_earth_splitter:GetAbilityTextureName()
	return "elder_titan_earth_splitter"
end

function mech_earth_splitter:IsHiddenWhenStolen()
	return false
end

function mech_earth_splitter:IsNetherWardStealable()
	return false
end

function mech_earth_splitter:GetCastRange(location, target)
	return self.BaseClass.GetCastRange(self, location, target)
end

function mech_earth_splitter:GetCooldown(level)
	return self.BaseClass.GetCooldown(self, level)
end

local function FindNearestPointFromLine(caster, dir, affected)
	local castertoaffected = affected - caster
	local len = castertoaffected:Dot(dir)
	local ntgt = Vector(dir.x * len, dir.y * len, caster.z)
	return caster + ntgt
end


function mech_earth_splitter:OnSpellStart()
	if not IsServer() then return end

	-- Ability properties
	local caster = self:GetCaster()
	local caster_position = caster:GetAbsOrigin()
	local target_point = self:GetCursorPosition()
	-- local playerID = caster:GetPlayerID()

	-- Ability specials
	local radius = self:GetSpecialValueFor("radius")
	local duration = self:GetSpecialValueFor("duration")
	local slow_duration = self:GetSpecialValueFor("slow_duration")

	local bonus_hp_per_str = self:GetSpecialValueFor("bonus_hp_per_str")
	local effect_delay = self:GetSpecialValueFor("crack_time")
	local crack_width = self:GetSpecialValueFor("crack_width")
	local crack_distance = self:GetSpecialValueFor("crack_distance")
	local crack_damage = self:GetSpecialValueFor("damage_pct") / 2

	local boss_crack_damage = self:GetSpecialValueFor("boss_damage_pct") / 2
	-- local caster_fw = caster:GetForwardVector()
	local caster_fw = (target_point - caster_position):Normalized()

	local crack_ending = caster_position + caster_fw * crack_distance

	local unit_count = self:GetSpecialValueFor("unit_count")

	-- Play cast sound
	EmitSoundOn("Hero_ElderTitan.EarthSplitter.Cast", caster)

	-- Add start particle effect
	local particle_start_fx = ParticleManager:CreateParticle(
		"particles/units/heroes/hero_elder_titan/elder_titan_earth_splitter.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle_start_fx, 1, crack_ending)
	ParticleManager:SetParticleControl(particle_start_fx, 3, Vector(0, effect_delay, 0))

	-- Destroy trees in the radius
	GridNav:DestroyTreesAroundPoint(target_point, radius, false)

	-- Wait for the effect delay
	Timers:CreateTimer(effect_delay, function()
		if not IsActiveUnit(caster) then
			return
		end
		EmitSoundOn("Hero_ElderTitan.EarthSplitter.Destroy", caster)

		local enemies = FindUnitsInLine(caster:GetTeamNumber(), caster_position, crack_ending, nil, crack_width,
			self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags())

		enemies = subrange(enemies, 1, unit_count)

		for _, enemy in pairs(enemies) do
			enemy:Interrupt()
			enemy:AddNewModifier(caster, self, "modifier_imba_earth_splitter", { duration = slow_duration })

			local cdamage = 0
			if enemy:IsAncient() then
				cdamage = boss_crack_damage
			else
				cdamage = crack_damage
			end

			if not enemy:IsMagicImmune() then
				ApplyDamage({
					victim = enemy,
					attacker = caster,
					damage = enemy:GetMaxHealth() * cdamage * 0.01,
					damage_type = DAMAGE_TYPE_PHYSICAL,
					ability = self
				})
				ApplyDamage({
					victim = enemy,
					attacker = caster,
					damage = enemy:GetMaxHealth() * cdamage * 0.01,
					damage_type = DAMAGE_TYPE_MAGICAL,
					ability = self
				})
			end
			local closest_point = FindNearestPointFromLine(caster_position, caster_fw, enemy:GetAbsOrigin())
			FindClearSpaceForUnit(enemy, closest_point, false)
		end

		ParticleManager:ReleaseParticleIndex(particle_start_fx)
	end)
end

-- Earth Splitter modifier
modifier_imba_earth_splitter = class({})

function modifier_imba_earth_splitter:IsHidden() return false end

function modifier_imba_earth_splitter:IsPurgable() return true end

function modifier_imba_earth_splitter:DeclareFunctions()
	local decFuncs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}

	return decFuncs
end

function modifier_imba_earth_splitter:CheckState()
	local state = {
		-- [MODIFIER_STATE_PASSIVES_DISABLED] = true
	}
	return state
end

function modifier_imba_earth_splitter:GetModifierMoveSpeedBonus_Percentage()
	return -self:GetAbility():GetSpecialValueFor("slow_pct")
end
