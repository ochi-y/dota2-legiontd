-- Vampiric Spirit
-- Wraith Kings undying power: on lethal damage the unit turns into a spirit, briefly invulnerable, and heals

ghost_vampiric_spirit = class({})

LinkLuaModifier("modifier_ghost_vampiric_spirit", "ability/ghost_vampiric_spirit", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ghost_vampiric_spirit_wraith", "ability/ghost_vampiric_spirit", LUA_MODIFIER_MOTION_NONE)

-- Grab the built-in modifier
function ghost_vampiric_spirit:GetIntrinsicModifierName()
    return "modifier_ghost_vampiric_spirit"
end

--------------------------------------------------------------------------------
-- Passive listener modifier
modifier_ghost_vampiric_spirit = class({})

function modifier_ghost_vampiric_spirit:IsHidden()
    return true
end

function modifier_ghost_vampiric_spirit:IsPurgable()
    return false
end

function modifier_ghost_vampiric_spirit:RemoveOnDeath()
    return false
end

function modifier_ghost_vampiric_spirit:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
    }
end

-- Watch damage and trigger when health drops to 0
function modifier_ghost_vampiric_spirit:GetModifierIncomingDamage_Percentage(params)
    if not IsServer() then
        return 0
    end

    local parent = self:GetParent()
    local ability = self:GetAbility()

    -- Is the unit already a spirit?
    if parent:HasModifier("modifier_ghost_vampiric_spirit_wraith") then
        return 0
    end

    -- Is the ability on cooldown?
    if not ability:IsFullyCastable() then
        return 0
    end

    -- Would this damage kill the unit?
    local health = parent:GetHealth()
    if (health - params.damage <= 0) then
        -- Ability parameters
        local wraith_duration = ability:GetSpecialValueFor("wraith_duration")
        local enable_reincarnate_effect = ability:GetSpecialValueFor("enable_reincarnate_effect")

        -- Wraith King resurrection sound
        EmitSoundOn("Hero_SkeletonKing.Reincarnate", parent)

        -- Resurrection effect, controlled by a toggle
        if enable_reincarnate_effect == 1 then
            local particle = ParticleManager:CreateParticle(
                "particles/units/heroes/hero_skeletonking/wraith_king_reincarnate.vpcf",
                PATTACH_ABSORIGIN_FOLLOW,
                parent
            )
            ParticleManager:SetParticleControl(particle, 0, parent:GetAbsOrigin())
            ParticleManager:SetParticleControl(particle, 1, Vector(wraith_duration, 0, 0))
            ParticleManager:ReleaseParticleIndex(particle)
        end

        -- Restore the unit to full health
        parent:SetHealth(parent:GetMaxHealth())

        -- Add the spirit form modifier for 4 seconds, health comes back when it ends
        parent:AddNewModifier(
            parent,
            ability,
            "modifier_ghost_vampiric_spirit_wraith",
            { duration = wraith_duration }
        )

        -- Purge every negative effect
        parent:Purge(false, true, false, true, false)

        -- Start the 240 second cooldown
        ability:StartCooldown(ability:GetCooldown(ability:GetLevel()))

        -- Block the lethal damage
        return -100
    end

    return 0
end

--------------------------------------------------------------------------------
-- Spirit form modifier
modifier_ghost_vampiric_spirit_wraith = class({})

function modifier_ghost_vampiric_spirit_wraith:IsHidden()
    return false
end

function modifier_ghost_vampiric_spirit_wraith:IsPurgable()
    return false
end

function modifier_ghost_vampiric_spirit_wraith:RemoveOnDeath()
    return false
end

function modifier_ghost_vampiric_spirit_wraith:GetEffectName()
    return "particles/units/heroes/hero_skeletonking/wraith_king_ghosts_ambient.vpcf"
end

function modifier_ghost_vampiric_spirit_wraith:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_ghost_vampiric_spirit_wraith:GetStatusEffectName()
    return "particles/status_fx/status_effect_wraithking_ghosts.vpcf"
end

function modifier_ghost_vampiric_spirit_wraith:StatusEffectPriority()
    return 1000
end

function modifier_ghost_vampiric_spirit_wraith:CheckState()
    return {
        [MODIFIER_STATE_INVULNERABLE] = true,          -- invulnerable
        [MODIFIER_STATE_NO_HEALTH_BAR] = false,        -- show the health bar
    }
end

function modifier_ghost_vampiric_spirit_wraith:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MIN_HEALTH,
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
    }
end

-- Keep health at 1 so the unit cannot die in spirit form
function modifier_ghost_vampiric_spirit_wraith:GetMinHealth()
    return 1
end

-- Immune to all damage
function modifier_ghost_vampiric_spirit_wraith:GetModifierIncomingDamage_Percentage()
    return -100
end

function modifier_ghost_vampiric_spirit_wraith:OnCreated()
    if not IsServer() then return end

    local parent = self:GetParent()

    -- Spirit form sound
    EmitSoundOn("Hero_SkeletonKing.Reincarnate.Ghost", parent)
end

-- Restore health when the spirit form ends
function modifier_ghost_vampiric_spirit_wraith:OnDestroy()
    if not IsServer() then return end

    local parent = self:GetParent()
    local ability = self:GetAbility()

    -- Stop the spirit sound
    StopSoundOn("Hero_SkeletonKing.Reincarnate.Ghost", parent)

    -- Restore health
    if parent:IsAlive() then
        local heal_pct = ability:GetSpecialValueFor("heal_pct")
        local heal_amount = parent:GetMaxHealth() * heal_pct * 0.01
        parent:SetHealth(heal_amount)
    end
end
