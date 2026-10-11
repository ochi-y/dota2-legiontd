LinkLuaModifier("modifier_legiontd_fireball_thinker", "ability/legiontd_fireball", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_legiontd_fireball_burn", "ability/legiontd_fireball", LUA_MODIFIER_MOTION_NONE)

-- Fireball - hurls a fireball that damages one enemy and burns the ground
if legiontd_fireball == nil then
    legiontd_fireball = class({})
end

function legiontd_fireball:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    -- Cast sound
    EmitSoundOn("Hero_DragonKnight.Fireball.Cast", caster)

    -- Launch the fireball projectile
    local projectile_particle = "particles/econ/items/dragon_knight/dk_2022_immortal/dk_2022_immortal_dragon_tail_dragon_projectile.vpcf"
    local missile_speed = 1000

    SimpleTrackingProjectile(self, caster, target, projectile_particle, missile_speed)
end

function legiontd_fireball:OnProjectileHit(hTarget, vLocation)
    if not hTarget then return end

    local caster = self:GetCaster()
    local burn_radius = self:GetSpecialValueFor("burn_radius")
    local burn_duration = self:GetSpecialValueFor("burn_duration")

    local target_pos = hTarget:GetAbsOrigin()

    -- Impact sound
    EmitSoundOnLocationWithCaster(target_pos, "Ability.LightStrikeArray", caster)

    -- 150 damage to the enemy hit
    ApplyDamage({
        victim = hTarget,
        attacker = caster,
        damage = 150,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self
    })

    -- Create the burning ground area
    CreateModifierThinker(
        caster,
        self,
        "modifier_legiontd_fireball_thinker",
        { duration = burn_duration },
        target_pos,
        caster:GetTeamNumber(),
        false
    )

    return true
end

---------------------------------------------------------------------
-- Burning ground thinker
modifier_legiontd_fireball_thinker = class({
    IsHidden = function(self)
        return true
    end,
    IsPurgable = function(self)
        return false
    end,
    IsAura = function(self)
        return true
    end
})

function modifier_legiontd_fireball_thinker:OnCreated(params)
    if not IsServer() then return end

    local ability = self:GetAbility()
    self.burn_radius = ability:GetSpecialValueFor("burn_radius")

    -- Create the burning ground effect
    local burn_fx = ParticleManager:CreateParticle(
        "particles/neutral_fx/black_dragon_fireball.vpcf",
        PATTACH_ABSORIGIN,
        self:GetParent()
    )
    ParticleManager:SetParticleControl(burn_fx, 0, self:GetParent():GetOrigin())
    ParticleManager:SetParticleControl(burn_fx, 1, self:GetParent():GetOrigin())
    ParticleManager:SetParticleControl(burn_fx, 2, Vector(self.burn_radius, self.burn_radius, self.burn_radius))

    self:AddParticle(burn_fx, false, false, -1, false, false)

    -- Burning sound
    EmitSoundOn("Hero_AbyssalUnderlord.Firestorm.Target", self:GetParent())
end

function modifier_legiontd_fireball_thinker:OnDestroy()
    if not IsServer() then return end
    StopSoundOn("Hero_AbyssalUnderlord.Firestorm.Target", self:GetParent())
end

function modifier_legiontd_fireball_thinker:GetAuraRadius()
    return self.burn_radius
end

function modifier_legiontd_fireball_thinker:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_legiontd_fireball_thinker:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_legiontd_fireball_thinker:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_legiontd_fireball_thinker:GetModifierAura()
    return "modifier_legiontd_fireball_burn"
end

function modifier_legiontd_fireball_thinker:GetAuraDuration()
    return 0.5
end

-- function modifier_legiontd_fireball_thinker:GetAuraEntityReject(target)
--     if IsServer() then
--         -- If the target already burns, do not apply another aura
--         if target:FindModifierByName("modifier_legiontd_fireball_burn") then
--             return true
--         end
--     end
--     return false
-- end

---------------------------------------------------------------------
-- Burn debuff
modifier_legiontd_fireball_burn = class({
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return true
    end,
    IsDebuff = function(self)
        return true
    end
})

function modifier_legiontd_fireball_burn:OnCreated(params)
    if not self:GetAbility() then return end

    local ability = self:GetAbility()
    self.burn_damage = ability:GetSpecialValueFor("burn_damage")

    if IsServer() then
        -- Burn damage every 0.5 seconds
        self:StartIntervalThink(0.5)
    end
end

function modifier_legiontd_fireball_burn:OnRefresh(params)
    self:OnCreated(params)
end

function modifier_legiontd_fireball_burn:OnIntervalThink()
    if not IsServer() then return end

    local caster = self:GetCaster()
    local parent = self:GetParent()

    -- Deal the burn damage
    ApplyDamage({
        victim = parent,
        attacker = caster,
        damage = self.burn_damage * 0.5,  -- once every 0.5s, so half of the total damage
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self:GetAbility()
    })
end

-- function modifier_legiontd_fireball_burn:GetEffectName()
--     return "particles/units/heroes/hero_phoenix/phoenix_icarus_dive_burn.vpcf"
-- end

-- function modifier_legiontd_fireball_burn:GetEffectAttachType()
--     return PATTACH_ABSORIGIN_FOLLOW
-- end
