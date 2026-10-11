LinkLuaModifier("modifier_legiontd_howl_debuff", "ability/legiontd_howl", LUA_MODIFIER_MOTION_NONE)

-- Howl - a terrifying cry that slows nearby enemies
if legiontd_howl == nil then
    legiontd_howl = class({})
end

function legiontd_howl:OnSpellStart()
    local caster = self:GetCaster()
    local radius = self:GetSpecialValueFor("radius")
    local duration = self:GetSpecialValueFor("duration")

    -- Primal beast howl sound
    EmitSoundOn("Hero_PrimalBeast.Uproar.Cast", caster)

    -- Play the roar animation
    caster:StartGesture(ACT_DOTA_CAST_ABILITY_3)

    -- Roar effect coming from the mouth
    local roar_fx = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_primal_beast/primal_beast_roar.vpcf",
        PATTACH_POINT_FOLLOW,
        caster
    )
    ParticleManager:SetParticleControlEnt(
        roar_fx,
        0,
        caster,
        PATTACH_POINT_FOLLOW,
        "attach_mouth",
        Vector(0, 0, 0),
        true
    )
    ParticleManager:ReleaseParticleIndex(roar_fx)

    -- Ground AOE roar ripple effect
    PlayEffOnLocation("particles/units/heroes/hero_primal_beast/primal_beast_roar_aoe.vpcf", caster:GetAbsOrigin(), {
        cpKv = { [1] = Vector(radius, radius, radius) }
    })

    -- Every enemy in range
    local enemies = FindUnitsInRadius(
        caster:GetTeamNumber(),
        caster:GetAbsOrigin(),
        nil,
        radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )

    -- Apply the slow debuff to every enemy
    for _, enemy in ipairs(enemies) do
        local adjusted_duration = duration * (1 - CalUnitStatusResistance(enemy))
        enemy:AddNewModifier(caster, self, "modifier_legiontd_howl_debuff", {
            duration = adjusted_duration
        })
    end
end

function legiontd_howl:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

---------------------------------------------------------------------
-- Howl slow debuff
modifier_legiontd_howl_debuff = class({
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

function modifier_legiontd_howl_debuff:OnCreated(params)
    if not self:GetAbility() then return end

    local ability = self:GetAbility()
    self.move_speed_slow = ability:GetSpecialValueFor("move_speed_slow")
    self.attack_speed_slow = ability:GetSpecialValueFor("attack_speed_slow")
end

function modifier_legiontd_howl_debuff:OnRefresh(params)
    self:OnCreated(params)
end

function modifier_legiontd_howl_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
    }
end

function modifier_legiontd_howl_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self.move_speed_slow
end

function modifier_legiontd_howl_debuff:GetModifierAttackSpeedBonus_Constant()
    return self.attack_speed_slow
end

function modifier_legiontd_howl_debuff:GetTexture()
    return "primal_beast_uproar"
end

function modifier_legiontd_howl_debuff:GetStatusEffectName()
    return "particles/units/heroes/hero_primal_beast/primal_beast_status_effect_slow.vpcf"
end

function modifier_legiontd_howl_debuff:StatusEffectPriority()
    return MODIFIER_PRIORITY_NORMAL
end

