goblin_cluster_rockets = class({})
LinkLuaModifier('modifier_goblin_cluster_rockets_dummy', 'ability/goblin_cluster_rockets', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_goblin_cluster_rockets_tag', 'ability/goblin_cluster_rockets', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_goblin_cluster_rockets_debuff', 'ability/goblin_cluster_rockets', LUA_MODIFIER_MOTION_NONE)

function goblin_cluster_rockets:GetAOERadius() return self:GetSpecialValueFor("radius") end

function goblin_cluster_rockets:OnSpellStart()
    local caster = self:GetCaster()
    if not caster then
        return
    end

    local targetPos = self:GetCursorPosition()

    local dummy = CreateUnitByName('npc_dota_custom_dummy_unit', targetPos, false, nil, nil, caster:GetTeam())
    if not dummy then
        return
    end

    dummy:AddNewModifier(caster, self, 'modifier_goblin_cluster_rockets_dummy', {})

    local speed = self:GetSpecialValueFor("speed")
    local visionRadius = self:GetSpecialValueFor("vision_radius")

    local projectile = {
        Target = dummy,
        Source = self:GetCaster(),
        Ability = self,
        EffectName = "particles/units/heroes/hero_rattletrap/rattletrap_rocket_flare.vpcf",
        bDodgable = false,
        bProvidesVision = true,
        iVisionRadius = visionRadius,
        iVisionTeamNumber = caster:GetTeamNumber(),
        iMoveSpeed = speed,
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
    }

    ProjectileManager:CreateTrackingProjectile(projectile)

    EmitSoundOn("Hero_Rattletrap.Rocket_Flare.Fire", caster)
end

function goblin_cluster_rockets:OnProjectileHit(target, position)
    if not target then
        return
    end

    local caster = self:GetCaster()
    if not caster then
        UTIL_Remove(target)
        return
    end

    local radius = self:GetSpecialValueFor("radius")
    local duration = self:GetSpecialValueFor("duration")
    local stun = self:GetSpecialValueFor("stun")
    local damage = self:GetSpecialValueFor("damage")

    local targetOrigin = target:GetAbsOrigin()

    local enemies = FindUnitsInRadius(caster:GetTeamNumber(), targetOrigin, nil, radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)

    EmitSoundOn("Hero_Rattletrap.Rocket_Flare.Explode", caster)

    for i, enemy in pairs(enemies) do
        if enemy and not enemy:IsNull() then
            ApplyDamage({ victim = enemy, attacker = caster, damage = damage,
                damage_type = self:GetAbilityDamageType(), ability = self })

            local actualStun = stun * (1 - CalUnitStatusResistance(enemy))

            enemy:AddNewModifier(caster, self, "modifier_stunned", { duration = actualStun })
        end
    end

    duration = 3

    if target:IsAlive() then
        SimplePlayEffAtlocation("particles/units/heroes/hero_rattletrap/rattletrap_rocket_flare_illumination.vpcf",
            targetOrigin, { 0 }, {
                [1] = Vector(duration, 0, 0)
            })
    end

    UTIL_Remove(target)
end

modifier_goblin_cluster_rockets_dummy = class({
    IsHidden               = function(self) return true end,
    IsPurgable             = function(self) return false end,
    IsDebuff               = function(self) return true end,
    IsBuff                 = function(self) return false end,
    RemoveOnDeath          = function(self) return true end,
    AllowIllusionDuplicate = function(self) return false end,
    CheckState             = function(self)
        return {
            [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
            [MODIFIER_STATE_NOT_ON_MINIMAP] = true,
            [MODIFIER_STATE_INVULNERABLE] = true,
            [MODIFIER_STATE_UNSELECTABLE] = true,
            [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        }
    end,
})

modifier_goblin_cluster_rockets_tag = class({
    IsHidden               = function(self) return true end,
    IsPurgable             = function(self) return false end,
    IsDebuff               = function(self) return false end,
    IsBuff                 = function(self) return true end,
    RemoveOnDeath          = function(self) return true end,
    AllowIllusionDuplicate = function(self) return false end,
    GetAttributes          = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})


modifier_goblin_cluster_rockets_debuff = class({
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return false
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
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_NONE
    end
})
function modifier_goblin_cluster_rockets_debuff:AllowIllusionDuplicate()
    return false
end

function modifier_goblin_cluster_rockets_debuff:OnCreated(params)
    if not self:GetAbility() then return end
    local ability = self:GetAbility()
    self.goldCost = ability:GetSpecialValueFor("goldCost")
    if not IsServer() then return end
end

function modifier_goblin_cluster_rockets_debuff:OnRefresh(params)
    self:OnCreated(params)
end

function modifier_goblin_cluster_rockets_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE
    }
end

function modifier_goblin_cluster_rockets_debuff:GetModifierMoveSpeedBonus_Percentage()
    return -100
end

function modifier_goblin_cluster_rockets_debuff:GetModifierAttackSpeedPercentage(params)
    return -50
end
