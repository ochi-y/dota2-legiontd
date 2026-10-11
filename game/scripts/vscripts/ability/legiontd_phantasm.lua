LinkLuaModifier("modifier_legiontd_phantasm_passive", "ability/legiontd_phantasm", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_legiontd_phantasm_illusion", "ability/legiontd_phantasm", LUA_MODIFIER_MOTION_NONE)

-- Phantasm - attacks have a chance to create an illusion of the caster
if legiontd_phantasm == nil then
    legiontd_phantasm = class({})
end

function legiontd_phantasm:GetIntrinsicModifierName()
    return "modifier_legiontd_phantasm_passive"
end

---------------------------------------------------------------------
-- Passive modifier - listens for attack landed events
modifier_legiontd_phantasm_passive = class({
    IsHidden = function(self)
        return true
    end,
    IsPurgable = function(self)
        return false
    end,
    IsDebuff = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return true
    end
})

function modifier_legiontd_phantasm_passive:OnCreated()
    if not IsServer() then return end
    self.current_illusion = nil  -- the illusion currently alive
    self.last_trigger_time = 0   -- last trigger time
end

function modifier_legiontd_phantasm_passive:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }
end

function modifier_legiontd_phantasm_passive:OnAttackLanded(params)
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end
    if not self:GetAbility() then return end

    local caster = self:GetParent()
    local ability = self:GetAbility()

    -- Illusions never trigger the passive
    if caster:IsCustomIllusion() then
        return
    end

    -- Ability cooldown
    local cooldown = ability:GetCooldown(ability:GetLevel())
    local current_time = GameRules:GetGameTime()
    if current_time - self.last_trigger_time < cooldown then
        return
    end

    -- Is an illusion already up?
    if self.current_illusion and not self.current_illusion:IsNull() and self.current_illusion:IsAlive() then
        return  -- an illusion is already up, do not trigger
    end

    -- Trigger the passive and create the illusion
    self:CreatePhantasm()

    -- Put the ability on cooldown
    ability:StartCooldown(ability:GetCooldown(ability:GetLevel()))

    -- Remember the trigger time
    self.last_trigger_time = current_time
end

function modifier_legiontd_phantasm_passive:CreatePhantasm()
    local caster = self:GetParent()
    local ability = self:GetAbility()

    -- Ability parameters
    local duration = ability:GetSpecialValueFor("illusion_duration")
    local outgoing_damage = ability:GetSpecialValueFor("outgoing_damage")
    local incoming_damage = ability:GetSpecialValueFor("incoming_damage")
    local range_reduction = ability:GetSpecialValueFor("ranged_attack_range_reduction")
    local min_range = ability:GetSpecialValueFor("min_attack_range")
    local spawn_distance = ability:GetSpecialValueFor("spawn_distance")

    -- Mirror image sound
    -- EmitSoundOn("Hero_NagaSiren.MirrorImage", caster)

    -- Illusion spawn position, 200 units ahead
    local forward = caster:GetForwardVector()
    local spawn_pos = caster:GetAbsOrigin() + forward * spawn_distance

    -- Create the illusion
    local illusion = caster:CreateIllusion(
        caster,                    -- unit to copy
        ability,                   -- ability
        duration,                  -- duration
        spawn_pos,                 -- spawn position
        outgoing_damage,           -- outgoing damage percentage
        incoming_damage,           -- incoming damage percentage
        false,                     -- can it respawn
        1,                         -- unit count
        {
            useLuaIllusionMod = true
        }
    )

    if illusion then
        -- Keep the illusion reference
        self.current_illusion = illusion

        -- Illusion spawn effect
        PlayEffOnUnit("particles/generic_gameplay/illusion_created_b.vpcf", illusion)

        -- Match the illusion health to the original
        local caster_hp = caster:GetHealth()
        local caster_max_hp = caster:GetMaxHealth()
        local illusion_max_hp = illusion:GetMaxHealth()
        local target_hp = (caster_hp / caster_max_hp) * illusion_max_hp
        illusion:SetHealth(target_hp)

        -- Strip the building abilities
        if GamePlay and GamePlay.removeBuildingAbility then
            GamePlay:removeBuildingAbility(illusion)
        end

        -- Temporary phase state
        illusion:AddNewModifier(caster, nil, "modifier_phased", {
            duration = 0.1
        })

        -- Face the caster direction
        illusion:SetForwardVector(caster:GetForwardVector())

        -- Match the level
        if caster:GetLevel() - illusion:GetLevel() > 0 then
            illusion:CreatureLevelUp(caster:GetLevel() - illusion:GetLevel())
        end

        -- Ranged originals get an illusion with a shorter attack range
        if caster:IsRangedAttacker() then
            -- Add the modifier that shortens the attack range
            illusion:AddNewModifier(caster, ability, "modifier_legiontd_phantasm_illusion", {
                range_reduction = range_reduction,
                min_range = min_range
            })
        else
            -- Melee units get it too, purely for the status effect
            illusion:AddNewModifier(caster, ability, "modifier_legiontd_phantasm_illusion", {
                range_reduction = 0,
                min_range = 0
            })
        end

        -- Add the illusion to the player unit list
        local pid = caster:GetPlayerOwnerID()
        local pdata = Player:GetPData(pid)
        if pdata then
            table.insert(pdata.creeps, illusion)
        end

        -- Copy the pathing point info
        if caster.wayStep then
            illusion.wayStep = caster.wayStep
        end
        if caster.waypoints then
            illusion.waypoints = caster.waypoints
        end
    end
end

---------------------------------------------------------------------
-- Modifier that shortens the illusion attack range
modifier_legiontd_phantasm_illusion = class({
    IsHidden = function(self)
        return true
    end,
    IsPurgable = function(self)
        return false
    end,
    IsDebuff = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return true
    end
})

function modifier_legiontd_phantasm_illusion:OnCreated(params)
    if not IsServer() then return end
    if not self:GetAbility() then return end

    self.range_reduction = params.range_reduction or 200
    self.min_range = params.min_range or 150

    -- Read the current attack range and shorten it
    local parent = self:GetParent()
    if parent and parent:IsRangedAttacker() then
        local current_range = parent:GetAttackRange()
        local new_range = math.max(current_range - self.range_reduction, self.min_range)
        self.final_range_reduction = current_range - new_range
    else
        self.final_range_reduction = 0
    end
end

function modifier_legiontd_phantasm_illusion:OnRefresh(params)
    self:OnCreated(params)
end

function modifier_legiontd_phantasm_illusion:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS
    }
end

function modifier_legiontd_phantasm_illusion:GetModifierAttackRangeBonus()
    return -self.final_range_reduction
end

function modifier_legiontd_phantasm_illusion:GetStatusEffectName()
    return "particles/status_fx/status_effect_grimstroke_ink_over.vpcf"
end

function modifier_legiontd_phantasm_illusion:StatusEffectPriority()
    return MODIFIER_PRIORITY_SUPER_ULTRA
end
