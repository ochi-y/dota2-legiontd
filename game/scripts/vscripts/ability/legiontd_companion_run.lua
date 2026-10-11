LinkLuaModifier("modifier_generic_unit_targeted_dash", "lua_abilities/generic/modifier_generic_unit_targeted_dash", LUA_MODIFIER_MOTION_BOTH)

local COMPANION_RUN_MOVE_SPEED = 1500
local COMPANION_RUN_VERTICAL_SPEED = 1000
local COMPANION_RUN_ACCEL_DURATION = 0.15
local COMPANION_RUN_DECEL_DISTANCE = 220
local COMPANION_RUN_MIN_SPEED_PCT = 0.35
local COMPANION_RUN_LANDING_OFFSET = 96

if legiontd_companion_run == nil then
    legiontd_companion_run = class({})
end

function legiontd_companion_run:GetAOERadius()
    return self:GetSpecialValueFor("landing_radius")
end

function legiontd_companion_run:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    if not target or target:IsNull() then
        return
    end

    if target:TriggerSpellAbsorb(self) then
        return
    end

    local start_pos = caster:GetAbsOrigin()
    local landing_offset = COMPANION_RUN_LANDING_OFFSET
    local direction = target:GetAbsOrigin() - start_pos
    direction.z = 0
    if direction:Length2D() > 0 then
        caster:SetForwardVector(direction:Normalized())
    end

    caster:StartGesture(ACT_DOTA_OVERRIDE_ABILITY_2)
    EmitSoundOn("Hero_Marci.Rebound.Cast", caster)

    local dash = caster:AddNewModifier(caster, self, "modifier_generic_unit_targeted_dash", {
        targetIndex = target:entindex(),
        speed = COMPANION_RUN_MOVE_SPEED,
        vSpeed = COMPANION_RUN_VERTICAL_SPEED,
        accel_duration = COMPANION_RUN_ACCEL_DURATION,
        decel_distance = COMPANION_RUN_DECEL_DISTANCE,
        min_speed_pct = COMPANION_RUN_MIN_SPEED_PCT,
        close_distance = landing_offset
    })

    if not dash then
        caster:RemoveGesture(ACT_DOTA_OVERRIDE_ABILITY_2)
        return
    end

    self:PlayLeapEffects(caster, dash)

    dash:SetEndCallback(function(interrupted)
        caster:RemoveGesture(ACT_DOTA_OVERRIDE_ABILITY_2)

        if interrupted or not dash.success or not target or target:IsNull() or not target:IsAlive() then
            FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
            return
        end

        local landing_pos = self:GetLandingPosition(caster, target, start_pos, landing_offset)
        caster:SetAbsOrigin(landing_pos)
        FindClearSpaceForUnit(caster, landing_pos, true)
        caster:AddNewModifier(caster, self, "modifier_phased", {
            duration = 0.1
        })

        self:Impact(start_pos)
    end)
end

function legiontd_companion_run:GetLandingPosition(caster, target, start_pos, landing_offset)
    local target_pos = target:GetAbsOrigin()
    local direction = target_pos - start_pos
    direction.z = 0

    if direction:Length2D() <= 0 then
        direction = caster:GetForwardVector()
    else
        direction = direction:Normalized()
    end

    return GetGroundPosition(target_pos - direction * landing_offset, caster)
end

function legiontd_companion_run:PlayLeapEffects(caster, dash)
    local leap_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_marci/marci_rebound_bounce.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControlEnt(
        leap_fx,
        1,
        caster,
        PATTACH_POINT_FOLLOW,
        "attach_attack1",
        Vector(0, 0, 0),
        true
    )
    ParticleManager:SetParticleControlEnt(
        leap_fx,
        3,
        caster,
        PATTACH_POINT_FOLLOW,
        "attach_hitloc",
        Vector(0, 0, 0),
        true
    )

    dash:AddParticle(leap_fx, false, false, -1, false, false)
end

function legiontd_companion_run:Impact(origin)
    local caster = self:GetCaster()
    local impact_pos = caster:GetAbsOrigin()
    local radius = self:GetSpecialValueFor("landing_radius")
    local damage = self:GetSpecialValueFor("impact_damage")
    local stun_duration = self:GetSpecialValueFor("debuff_duration")

    local enemies = FindUnitsInRadius(
        caster:GetTeamNumber(),
        impact_pos,
        nil,
        radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )

    for _, enemy in pairs(enemies) do
        ApplyDamage({
            victim = enemy,
            attacker = caster,
            ability = self,
            damage = damage,
            damage_type = self:GetAbilityDamageType()
        })

        enemy:AddNewModifier(caster, self, "modifier_stunned", {
            duration = stun_duration * (1 - CalUnitStatusResistance(enemy))
        })
    end

    local impact_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_marci/marci_rebound_bounce_impact.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(impact_fx, 0, impact_pos)
    ParticleManager:SetParticleControl(impact_fx, 1, origin or impact_pos)
    ParticleManager:SetParticleControl(impact_fx, 9, Vector(radius, radius, radius))
    ParticleManager:SetParticleControl(impact_fx, 10, impact_pos)
    ParticleManager:ReleaseParticleIndex(impact_fx)

    EmitSoundOnLocationWithCaster(impact_pos, "Hero_Marci.Rebound.Impact", caster)
end
