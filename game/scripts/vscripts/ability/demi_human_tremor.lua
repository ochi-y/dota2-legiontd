demi_human_tremor = class({})
LinkLuaModifier('modifier_demi_human_tremor_debuff', 'ability/demi_human_tremor', LUA_MODIFIER_MOTION_NONE)

function demi_human_tremor:OnSpellStart()
    local caster = self:GetCaster()
    local radius = self:GetSpecialValueFor("radius")
    local duration = self:GetSpecialValueFor("duration")
    local damage = self:GetSpecialValueFor("damage")

    local clap_particle = ParticleManager:CreateParticle(
        "particles/econ/items/brewmaster/brewmaster_offhand_elixir/brewmaster_thunder_clap_elixir.vpcf",
        PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControl(clap_particle, 1, Vector(radius, radius, radius))
    ParticleManager:ReleaseParticleIndex(clap_particle)

    local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)

    self:GetCaster():EmitSound("Hero_Brewmaster.ThunderClap")
    for k, v in pairs(units) do
        if not v:HasFlyMovementCapability() then
            ApplyDamage({
                victim = v,
                attacker = caster,
                damage = damage,
                damage_type = self:GetAbilityDamageType(),
                ability = self
            })
            v:EmitSound("Hero_Brewmaster.ThunderClap.Target")
            local realDUration=duration
            realDUration = realDUration * (1 - CalUnitStatusResistance(v))
            v:AddNewModifier(caster, self, 'modifier_demi_human_tremor_debuff', {
                duration = duration
            })
        end
    end
end

modifier_demi_human_tremor_debuff = class({
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return true
    end,
    IsDebuff = function(self)
        return true
    end,
    IsBuff = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return true
    end,
    AllowIllusionDuplicate = function(self)
        return true
    end,
    DeclareFunctions = function(self)
        return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE}
    end,
    GetModifierMoveSpeedBonus_Percentage = function(self)
        return - self.movement_slow
    end,
    GetModifierAttackSpeedPercentage = function(self)
        if self:GetParent():IsAncient() then
            return -self.attack_speed_slow*(100-BOSS_ATTACK_SPEED_REDUCTION_RESISTANCE)/100
        end
        return -self.attack_speed_slow
    end
})

function modifier_demi_human_tremor_debuff:OnCreated(data)

    if not self:GetAbility() then return end
    local ability=self:GetAbility()
    self.movement_slow=ability:GetSpecialValueFor("movement_slow")
    self.attack_speed_slow=ability:GetSpecialValueFor("attack_speed_slow")



end

function modifier_demi_human_tremor_debuff:GetEffectName()
    return "particles/units/heroes/hero_brewmaster/brewmaster_thunder_clap_debuff.vpcf"
end
function modifier_demi_human_tremor_debuff:GetEffectAttachType()
    return PATTACH_POINT_FOLLOW
end
