alistar_pulverize = class({})

function alistar_pulverize:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_1
end
function alistar_pulverize:GetPlaybackRateOverride()
    return 1.4
end

function alistar_pulverize:OnSpellStart()
    if not IsServer() then
        return
    end
    -- unit identifier
    local caster = self:GetCaster()

    local duration = self:GetSpecialValueFor("knockup_duration")
    local radius = self:GetSpecialValueFor("radius")
    local height = self:GetSpecialValueFor("knockup_height")
    local damage = self:GetSpecialValueFor("damage")

    local damageTable = {
        -- victim = target,
        attacker = caster,
        damage = damage,
        damage_type = self:GetAbilityDamageType(),
        ability = self -- Optional.
    }

    -- find enemies
    local enemies = FindUnitsInRadius(caster:GetTeamNumber(), -- int, your team number
    caster:GetOrigin(), -- point, center point
    nil, -- handle, cacheUnit. (not known)
    radius, -- float, radius. or use FIND_UNITS_EVERYWHERE
    DOTA_UNIT_TARGET_TEAM_ENEMY, -- int, team filter
    DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, -- int, type filter
    0, -- int, flag filter
    0, -- int, order filter
    false -- bool, can grow cache
    )

    local passiveproc = false

    for _, enemy in pairs(enemies) do
        if enemy:HasGroundMovementCapability() then
            local realDuration=duration
            realDuration = realDuration * (1 - CalUnitStatusResistance(enemy))

            -- knockup
            local knockbackProperties = {
                center_x = caster.x,
                center_y = caster.y,
                center_z = caster.z,
                duration = realDuration,
                knockback_duration = realDuration,
                knockback_distance = 0,
                knockback_height = height
            }
            enemy:RemoveModifierByName("modifier_knockback")
            enemy:AddNewModifier(caster, self, "modifier_knockback", knockbackProperties)
            -- proc triumphant roar if a hero is hit
            if enemy:IsRealHero() and passiveproc == false then
                if caster:HasAbility("alistar_triumphant_roar") then
                    caster:FindAbilityByName("alistar_triumphant_roar"):Trigger()
                end
                passiveproc = true
            end

            damageTable.victim = enemy
            ApplyDamage(damageTable)
        end
    end

    -- play effects
    self:PlayEffects()
end

function alistar_pulverize:PlayEffects()
    -- Get Resources
    local particle_cast = "particles/units/heroes/hero_snapfire/hero_snapfire_cookie_landing.vpcf"
    local sound_cast = "Hero_Leshrac.Split_Earth"

    local radius = self:GetSpecialValueFor("radius")
    radius=radius

    -- -- Create Particle
    local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, self:GetCaster())
    ParticleManager:SetParticleControl(effect_cast, 0, self:GetCaster():GetOrigin())
    ParticleManager:SetParticleControl(effect_cast, 1, Vector(radius, radius, radius))
    ParticleManager:ReleaseParticleIndex(effect_cast)

    -- Create Sound
    EmitSoundOnLocationWithCaster(self:GetCaster():GetOrigin(), sound_cast, self:GetCaster())
end
