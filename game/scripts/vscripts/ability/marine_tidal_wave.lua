marine_tidal_wave = class({})
LinkLuaModifier("modifier_marine_tidal_wave_slow", "ability/marine_tidal_wave", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_marine_tidal_wave_hidden", "ability/marine_tidal_wave", LUA_MODIFIER_MOTION_NONE)
function marine_tidal_wave:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_4
end

function marine_tidal_wave:GetCooldown(level)
    -- Get caster's cast point
    local caster = self:GetCaster()
    local cooldown = self.BaseClass.GetCooldown(self, level)
    return cooldown
end

function marine_tidal_wave:OnSpellStart()
    -- Ability properties
    local caster = self:GetCaster()
    local ability = self
    local target_point = self:GetCursorPosition()
    local sound_cast = "Hero_Kunkka.TidalWave"
    local width = ability:GetSpecialValueFor("proj_width")
    local speed = ability:GetSpecialValueFor("proj_speed")
    local range = ability:GetSpecialValueFor("range")
    local unit_count = ability:GetSpecialValueFor("unit_count")

    EmitSoundOn(sound_cast, caster)
    local direction = (target_point - caster:GetAbsOrigin()):Normalized()
    local spawn_point = caster:GetAbsOrigin()

    -- local count = 1
    -- for i = 1, count, 1 do
    --     local startPoint = spawn_point + (2 * i - (count + 1)) * perpendicular(direction) * (width / (2 * count))
    --     local wave_projectile = {
    --         Ability = ability,
    --         EffectName = "",
    --         vSpawnOrigin = startPoint,
    --         fDistance = range + caster:GetCastRangeBonus(),
    --         fStartRadius = 100,
    --         fEndRadius = 100,
    --         Source = caster,
    --         bHasFrontalCone = false,
    --         bReplaceExisting = false,
    --         iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_BOTH,
    --         iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
    --         bDeleteOnHit = false,
    --         vVelocity = direction * speed * Vector(1, 1, 0),
    --         bDrawsOnMinimap = false,
    --         bProvidesVision = true,
    --         iVisionRadius = width,
    --         iVisionTeamNumber = caster:GetTeamNumber(),
    --         ExtraData = {
    --             cast_loc_x = tostring(caster:GetAbsOrigin().x),
    --             cast_loc_y = tostring(caster:GetAbsOrigin().y),
    --             cast_loc_z = tostring(caster:GetAbsOrigin().z),
    --             dir_x = tostring(direction.x),
    --             dir_y = tostring(direction.y),
    --             dir_z = tostring(direction.z)

    --         }
    --     }
    --     ProjectileManager:CreateLinearProjectile(wave_projectile)
    -- end
    --



    local effCount = 3
    local effWidth = width - 400

    local linearData = {
        unit_count = unit_count,
        cast_loc_x = tostring(caster:GetAbsOrigin().x),
        cast_loc_y = tostring(caster:GetAbsOrigin().y),
        cast_loc_z = tostring(caster:GetAbsOrigin().z),
        dir_x = tostring(direction.x),
        dir_y = tostring(direction.y),
        dir_z = tostring(direction.z)
    }

    for i = 1, effCount, 1 do
        local startPoint = spawn_point + (2 * i - (effCount + 1)) * perpendicular(direction) *
            (effWidth / (2 * effCount))
        local wave_projectile = {
            Ability = ability,
            EffectName = "particles/units/heroes/hero_kunkka/kunkka_shard_tidal_wave.vpcf",
            vSpawnOrigin = startPoint,
            fDistance = range + caster:GetCastRangeBonus(),
            fStartRadius = width / effCount,
            fEndRadius = width / effCount,
            Source = caster,
            bHasFrontalCone = false,
            bReplaceExisting = false,
            iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
            iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            bDeleteOnHit = false,
            vVelocity = direction * speed * Vector(1, 1, 0),
            bDrawsOnMinimap = false,
            bProvidesVision = false,
            iVisionRadius = width,
            iVisionTeamNumber = caster:GetTeamNumber(),
            ExtraData = {
                cast_loc_x = tostring(caster:GetAbsOrigin().x),
                cast_loc_y = tostring(caster:GetAbsOrigin().y),
                cast_loc_z = tostring(caster:GetAbsOrigin().z),
                dir_x = tostring(direction.x),
                dir_y = tostring(direction.y),
                dir_z = tostring(direction.z)
            }
        }
        local id = ProjectileManager:CreateLinearProjectile(wave_projectile)
        if not self.projectiles then
            self.projectiles = {}
        end
        self.projectiles[id] = linearData
    end
end

function marine_tidal_wave:OnProjectileHitHandle(target, location, id)
    if not IsServer() then
        return
    end


    -- If no target was hit, do nothing
    if not target then
        return nil
    end
    local data = self.projectiles[id]
    if data.unit_count <= 0 then
        return false
    end
    data.unit_count = data.unit_count - 1

    local caster = self:GetCaster()
    local ability = self

    if target:HasModifier("modifier_marine_tidal_wave_hidden") then
        return
    end
    target:AddNewModifier(caster, ability, "modifier_marine_tidal_wave_hidden", {
        duration = 0.5
    })

    -- Ability properties

    local sound_impact = "Hero_Kunkka.TidalWave.Target"
    local modifier_slow = "modifier_marine_tidal_wave_slow"
    local origin = caster:GetAbsOrigin()
    local passive = caster:GetAbilityByIndex(3)

    -- Ability specials
    local base_damage = ability:GetSpecialValueFor("damage")

    local distance_tick = ability:GetSpecialValueFor("range") / 16
    local slow_increase_per_tick = (ability:GetSpecialValueFor("max_slow") - ability:GetSpecialValueFor("min_slow")) /
        16
    local max_slow_duration = ability:GetSpecialValueFor("max_slow")
    local base_slow = ability:GetSpecialValueFor("min_slow")
    local knockup = ability:GetSpecialValueFor("knockback_duration")
    local knockup_distance = ability:GetSpecialValueFor("knockback")

    -- Recombine cast location vector
    local cast_location = Vector(tonumber(data.cast_loc_x), tonumber(data.cast_loc_y),
        tonumber(data.cast_loc_z))

    local dir = Vector(tonumber(data.dir_x), tonumber(data.dir_y), tonumber(data.dir_z))

    -- Calculate distance traveled
    local distance = (target:GetAbsOrigin() - cast_location):Length2D()

    if target:GetTeamNumber() ~= caster:GetTeamNumber() then
        -- Apply damage
        local damageTable = {
            victim = target,
            damage = base_damage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            attacker = caster,
            ability = ability
        }

        EmitSoundOn(sound_impact, target)

        -- Calculate stun duration
        local slow_duration = base_slow + (distance / distance_tick * slow_increase_per_tick)

        -- Cannot exceed max stun
        if slow_duration > max_slow_duration then
            slow_duration = max_slow_duration
        end
        -- Apply stun
        target:AddNewModifier(caster, ability, modifier_slow, {
            duration = slow_duration
        })
        local center = target:GetAbsOrigin() - dir * knockup_distance
        -- target:AddNewModifier(caster, ability, "modifier_knockback", {
        --     center_x = center.x,
        --     center_y = center.y,
        --     center_z = center.z,
        --     duration = knockup * (1 - target:GetStatusResistance()),
        --     knockback_duration = knockup * (1 - target:GetStatusResistance()),
        --     knockback_distance = knockup_distance,
        --     knockback_height = 100
        -- })


        local knockup_distance_Real = knockup_distance * (1 - CalUnitStatusResistance(target))


        local knockback = target:AddNewModifier(
		self:GetCaster(),           -- player source
		self,                       -- ability source
		"modifier_generic_knockback_lua", -- modifier name
		{
			distance = knockup_distance_Real,
			height = 0,
			duration = knockup * (1 - CalUnitStatusResistance(target)),
			direction_x = dir.x,
			direction_y = dir.y,
			IsStun = true,
			stuckByTerrain = true
		} -- kv
	)

        ApplyDamage(damageTable)
    else
        if target:IsHero() then
            target:AddNewModifier(caster, passive, "modifier_nami_surging_tides", {
                duration = passive:GetSpecialValueFor("duration")
            })
            target:AddNewModifier(caster, passive, "modifier_nami_surging_tides_tidal", {
                duration = passive:GetSpecialValueFor("duration")
            })
        end
    end

    return false
end

modifier_marine_tidal_wave_slow = class({})
function modifier_marine_tidal_wave_slow:IsDebuff()
    return true
end

function modifier_marine_tidal_wave_slow:IsHidden()
    return false
end

function modifier_marine_tidal_wave_slow:IsPurgable()
    return true
end

function modifier_marine_tidal_wave_slow:DeclareFunctions()
    local funcs = { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
    return funcs
end

function modifier_marine_tidal_wave_slow:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("slow") * (-1)
end

-------------------------------------------

modifier_marine_tidal_wave_hidden = class({
    IsHidden = function(self)
        return true
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
