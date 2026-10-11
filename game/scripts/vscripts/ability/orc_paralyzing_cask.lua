LinkLuaModifier("modifier_orc_paralyzing_cask", "ability/orc_paralyzing_cask", LUA_MODIFIER_MOTION_NONE)

orc_paralyzing_cask = class({})

-- function orc_paralyzing_cask:OnAbilityPhaseStart()
--     self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_2)
--     return true
-- end
function orc_paralyzing_cask:OnSpellStart()
    -- unit identifier
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    if target:TriggerSpellAbsorb(self) then
        return
    end

    -- load data
    local jumps = self:GetSpecialValueFor("bounces") + 1
    local radius = self:GetSpecialValueFor("bounce_range")
    local base_damage = self:GetSpecialValueFor("damage")
    local damage_mult = 1
    local projectile_name = "particles/units/heroes/hero_witchdoctor/witchdoctor_cask.vpcf"
    local projectile_speed = 1200

    -- get unique identifier
    local index = self:GetUniqueInt()

    -- create projectile
    local info = {
        Target = target,
        Source = caster,
        Ability = self,

        EffectName = projectile_name,
        iMoveSpeed = projectile_speed,
        bDodgeable = false, -- Optional
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,

        bDrawsOnMinimap = false, -- Optional
        bVisibleToEnemies = true, -- Optional
        bProvidesVision = true, -- Optional

        ExtraData = {
            index = index
        }
    }
    ProjectileManager:CreateTrackingProjectile(info)


    
    -- register projectile
    local data = {}
    data.jump = 0
    data.hit_units = {}

    data.jumps = jumps
    data.radius = radius
    data.base_damage = base_damage
    data.projectile_info = info
    data.damage_mult = damage_mult

    self.projectiles[index] = data

    -- play effects
    local sound_cast = "Hero_WitchDoctor.Paralyzing_Cask_Cast"
    EmitSoundOn(sound_cast, caster)
end

-- Projectile
orc_paralyzing_cask.projectiles = {}
function orc_paralyzing_cask:OnProjectileHit_ExtraData(target, location, ExtraData)

    if not target then
        return 
    end

    -- load data
    local data = self.projectiles[ExtraData.index]
    local caster = self:GetCaster()

    local creep_duration = self:GetSpecialValueFor("creep_duration")
    local bounce_delay = self:GetSpecialValueFor("bounce_delay")
    local base_damage = self:GetSpecialValueFor("base_damage")
    local bounce_bonus_damage = self:GetSpecialValueFor("bounce_bonus_damage")


    creep_duration = creep_duration * (1 - CalUnitStatusResistance(target))

    target:AddNewModifier(caster, self, "modifier_stunned", {
        duration = creep_duration
    })

    EmitSoundOn("Hero_WitchDoctor.Paralyzing_Cask_Bounce", target)

    -- mark as hit
    data.hit_units[target] = true

    if target:GetTeamNumber() ~= caster:GetTeamNumber() then
        if target and (not target:IsMagicImmune()) and (not target:IsInvulnerable()) then
            -- damage
            local damage_type = self:GetAbilityDamageType()

            local damage =base_damage +data.jump*bounce_bonus_damage -- data.base_damage * (data.damage_mult ^ (data.jump))
            local damageTable = {
                victim = target,
                attacker = self:GetCaster(),
                damage = damage,
                damage_type = damage_type,
                ability = self -- Optional.
            }
            ApplyDamage(damageTable)
        end

        data.jump = data.jump + 1
        if data.jump >= data.jumps then
            -- return projectile with target
            self:Returning(data, target)
            return
        end
    end

    -- jump to nearby target

    Timers:CreateTimer(bounce_delay, function()

        local pos = location
        if target then
            pos = target:GetAbsOrigin()
        end
        local next_target = nil

        local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), -- int, your team number
        pos, -- point, center point
        nil, -- handle, cacheUnit. (not known)
        data.radius, -- float, radius. or use FIND_UNITS_EVERYWHERE
        DOTA_UNIT_TARGET_TEAM_ENEMY, -- int, team filter
        DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_CREEP, -- int, type filter
        0, -- int, flag filter
        FIND_ANY_ORDER, -- int, order filter
        false -- bool, can grow cache
        )

        table.sort(enemies, function(a, b)
            if not data.hit_units[a] and data.hit_units[b] then
                return true
            end
            if data.hit_units[a] and not data.hit_units[b] then
                return false
            end
            if a:HasModifier("modifier_fiddlesticks_terrify_old") and
                not b:HasModifier("modifier_fiddlesticks_terrify_old") then
                return true
            end
            return false
        end)

        -- pick next target
        for _, enemy in pairs(enemies) do
            if enemy ~= target then
                next_target = enemy
                break
            end
        end

        -- local sound_cast = "Hero_ShadowDemon.ShadowPoison.Impact"
        -- EmitSoundOn(sound_cast, caster)

        -- not found
        if not next_target then
            -- return projectile without target
            self:Returning(data, target)
            return
        end

        -- create bounce projectile
        data.projectile_info.Target = next_target
        data.projectile_info.Source = target
        ProjectileManager:CreateTrackingProjectile(data.projectile_info)
    end)

end

function orc_paralyzing_cask:Returning(data, target)
    if not target then
        -- unregister projectile
        local index = data.projectile_info.ExtraData.index
        self.projectiles[index] = nil
        self:DelUniqueInt(index)
        return
    end
end

orc_paralyzing_cask.unique = {}
orc_paralyzing_cask.i = 0
orc_paralyzing_cask.max = 65536
function orc_paralyzing_cask:GetUniqueInt()
    while self.unique[self.i] do
        self.i = self.i + 1
        if self.i == self.max then
            self.i = 0
        end
    end

    self.unique[self.i] = true
    return self.i
end
function orc_paralyzing_cask:DelUniqueInt(i)
    self.unique[i] = nil
end

-------------------------------------------------------------------------------------------------------
modifier_orc_paralyzing_cask = class({
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
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_NONE
    end
})
function modifier_orc_paralyzing_cask:AllowIllusionDuplicate()
    return false
end
function modifier_orc_paralyzing_cask:OnCreated(params)

end
function modifier_orc_paralyzing_cask:OnRefresh(params)
    self:OnCreated(params)
end
function modifier_orc_paralyzing_cask:DeclareFunctions()
    return {}
end
function modifier_orc_paralyzing_cask:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = true
    }
    return state
end

function modifier_orc_paralyzing_cask:GetEffectName()
    return "particles/generic_gameplay/generic_silenced.vpcf"
end
function modifier_orc_paralyzing_cask:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end
