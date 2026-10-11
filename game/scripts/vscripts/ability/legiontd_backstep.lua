LinkLuaModifier("modifier_legiontd_backstep_slow", "ability/legiontd_backstep", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_legiontd_backstep_leap", "ability/legiontd_backstep", LUA_MODIFIER_MOTION_HORIZONTAL)

-- Backstep - shoot a chestnut forward and leap backwards
if legiontd_backstep == nil then
    legiontd_backstep = class({})
end

function legiontd_backstep:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local caster_pos = caster:GetAbsOrigin()

    -- Ability parameters
    local leap_distance = self:GetSpecialValueFor("leap_distance")
    local projectile_speed = self:GetSpecialValueFor("projectile_speed")

    -- Aim towards the target
    local target_pos = target:GetAbsOrigin()
    local forward = (target_pos - caster_pos):Normalized()

    -- Cast sound - Hoodwink chestnut shot
    EmitSoundOn("Hero_Hoodwink.AcornShot.Cast", caster)

    -- Play the cast animation
    caster:StartGesture(ACT_DOTA_CAST_ABILITY_1)

    -- Leaf effect at the caster position
    local leaves_fx = ParticleManager:CreateParticle(
        "models/heroes/hoodwink/debut/particles/hoodwink_jump_leaves.vpcf",
        PATTACH_ABSORIGIN,
        caster
    )
    ParticleManager:SetParticleControl(leaves_fx, 0, caster_pos)
    ParticleManager:ReleaseParticleIndex(leaves_fx)

    -- Fire a homing chestnut projectile at the target
    ProjectileManager:CreateTrackingProjectile({
        Target = target,
        Source = caster,
        Ability = self,
        EffectName = "particles/units/heroes/hero_hoodwink/hoodwink_acorn_shot_tracking.vpcf",
        iMoveSpeed = projectile_speed,
        vSourceLoc = caster_pos + Vector(0, 0, 96),  -- fired from the chest
        bDrawsOnMinimap = false,
        bDodgeable = true,
        bIsAttack = false,
        bVisibleToEnemies = true,
        bReplaceExisting = false,
        flExpireTime = GameRules:GetGameTime() + 10,
        bProvidesVision = false,
    })

    -- Leap backwards, away from the target
    local backward = -forward
    local leap_target = caster_pos + backward * leap_distance

    -- Add the leap motion controller with destination and attack target
    caster:AddNewModifier(caster, self, "modifier_legiontd_backstep_leap", {
        target_x = leap_target.x,
        target_y = leap_target.y,
        target_z = leap_target.z,
        attack_target = target:entindex()  -- entindex of the unit to attack
    })
end

-- Callback for the homing projectile hit
function legiontd_backstep:OnProjectileHit(hTarget, vLocation)
    if not hTarget then return end
    if hTarget:IsInvulnerable() then return end

    local caster = self:GetCaster()
    local slow_duration = self:GetSpecialValueFor("slow_duration")

    -- Hit sound
    EmitSoundOn("Hero_Hoodwink.AcornShot.Target", hTarget)

    -- Hit effect
    local impact_fx = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_hoodwink/hoodwink_acorn_shot_impact.vpcf",
        PATTACH_ABSORIGIN_FOLLOW,
        hTarget
    )
    ParticleManager:ReleaseParticleIndex(impact_fx)

    -- Perform one normal attack
    caster:PerformAttack(
        hTarget,      -- target
        false,        -- bUseCastAttackOrb
        true,         -- bProcessProcs - run attack procs
        true,         -- bSkipCooldown - ignore the attack cooldown
        false,        -- bIgnoreInvis
        false,        -- bUseProjectile - deal damage directly, no projectile
        false,        -- bFakeAttack
        false         -- bNeverMiss
    )

    -- Apply the slow
    local adjusted_duration = slow_duration * (1 - CalUnitStatusResistance(hTarget))
    hTarget:AddNewModifier(caster, self, "modifier_legiontd_backstep_slow", {
        duration = adjusted_duration
    })

    return true
end

---------------------------------------------------------------------
-- Slow debuff
modifier_legiontd_backstep_slow = class({
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

function modifier_legiontd_backstep_slow:OnCreated(params)
    if not self:GetAbility() then return end

    local ability = self:GetAbility()
    self.move_slow_pct = ability:GetSpecialValueFor("move_slow_pct")
end

function modifier_legiontd_backstep_slow:OnRefresh(params)
    self:OnCreated(params)
end

function modifier_legiontd_backstep_slow:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
end

function modifier_legiontd_backstep_slow:GetModifierMoveSpeedBonus_Percentage()
    return self.move_slow_pct
end

function modifier_legiontd_backstep_slow:GetTexture()
    return "hoodwink_acorn_shot"
end

function modifier_legiontd_backstep_slow:GetEffectName()
    return "particles/units/heroes/hero_hoodwink/hoodwink_acorn_shot_slow.vpcf"
end

function modifier_legiontd_backstep_slow:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

---------------------------------------------------------------------
-- Leap motion controller
modifier_legiontd_backstep_leap = class({
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return false
    end,
    IsDebuff = function(self)
        return false
    end
})

function modifier_legiontd_backstep_leap:GetMotionControllerPriority()
    return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM
end

function modifier_legiontd_backstep_leap:OnCreated(params)
    if not IsServer() then return end

    print("[Backstep] leap modifier created")

    local ability = self:GetAbility()
    if not ability then
        print("[Backstep] error: could not get the ability")
        self:Destroy()
        return
    end

    self.caster = self:GetCaster()
    self.start_pos = self.caster:GetAbsOrigin()

    -- Remember the attack target
    if params.attack_target then
        self.attack_target_index = params.attack_target
        print(string.format("[Backstep] saved attack target: %d", self.attack_target_index))
    end

    -- Leap speed, derived from distance and duration
    local leap_distance = ability:GetSpecialValueFor("leap_distance")
    local leap_duration = 0.4  -- the leap lasts 0.2s
    self.leap_speed = leap_distance / leap_duration

    self.time_elapsed = 0
    self.leap_duration = leap_duration

    print(string.format("[Backstep] leap: distance=%.1f, duration=%.2fs, speed=%.1f",
        leap_distance, leap_duration, self.leap_speed))

    -- Rebuild the destination vector from the parameters
    if params.target_x and params.target_y and params.target_z then
        self.target_point = Vector(params.target_x, params.target_y, params.target_z)

        local direction = (self.target_point - self.start_pos)
        direction.z = 0
        self.direction = direction:Normalized()
        self.distance = direction:Length2D()

        print(string.format("[Backstep] start: (%.1f, %.1f, %.1f)",
            self.start_pos.x, self.start_pos.y, self.start_pos.z))
        print(string.format("[Backstep] end: (%.1f, %.1f, %.1f)",
            self.target_point.x, self.target_point.y, self.target_point.z))
        print(string.format("[Backstep] actual distance: %.1f", self.distance))
    else
        print("[Backstep] error: no destination parameter")
        self:Destroy()
        return
    end

    -- Apply the motion controller
    if self:ApplyHorizontalMotionController() == false then
        print("[Backstep] error: could not apply the motion controller")
        self:Destroy()
        return
    end

    print("[Backstep] motion controller applied, leaping")

    -- Leap sound
    EmitSoundOn("Hero_Hoodwink.Bushwhack.Impact", self.caster)


end

function modifier_legiontd_backstep_leap:UpdateHorizontalMotion(me, dt)
    if not IsServer() then return end

    self.time_elapsed = self.time_elapsed + dt

    -- Has the leap finished?
    if self.time_elapsed >= self.leap_duration then
        print(string.format("[Backstep] leap complete: %.3fs total", self.time_elapsed))
        self:Destroy()
        return
    end

    -- Eased progress, 0 to 1
    local progress = self.time_elapsed / self.leap_duration

    -- Ease out: fast at the start, slow at the end
    -- formula: 1 - (1 - t)^2
    local eased_progress = 1 - math.pow(1 - progress, 2)

    -- Other curves are available too:
    -- ease in: eased_progress = progress * progress
    -- ease in-out: eased_progress = progress < 0.5 and 2 * progress * progress or 1 - math.pow(-2 * progress + 2, 2) / 2

    -- Update the position along the eased curve
    local current_distance = self.distance * eased_progress
    local new_location = self.start_pos + self.direction * current_distance

    self.caster:SetAbsOrigin(new_location)

    -- Log the position every 0.1s to keep the log readable
    if not self.last_log_time then
        self.last_log_time = 0
    end
    self.last_log_time = self.last_log_time + dt
    if self.last_log_time >= 0.1 then
        print(string.format("[Backstep] leap progress: %.1f%% (eased: %.1f%%), position: (%.1f, %.1f)",
            progress * 100, eased_progress * 100, new_location.x, new_location.y))
        self.last_log_time = 0
    end
end

function modifier_legiontd_backstep_leap:OnHorizontalMotionInterrupted()
    if not IsServer() then return end
    print("[Backstep] warning: leap interrupted")
    self:Destroy()
end

function modifier_legiontd_backstep_leap:OnDestroy()
    if not IsServer() then return end

    local final_pos = self:GetParent():GetAbsOrigin()
    print(string.format("[Backstep] leap destroyed, final position: (%.1f, %.1f, %.1f)",
        final_pos.x, final_pos.y, final_pos.z))

    -- Important: the motion controller must be interrupted or the game crashes
    self:GetParent():InterruptMotionControllers(true)
    print("[Backstep] motion controller interrupted")

    -- Once the leap is done, order the attack
    if self.attack_target_index then
        local target = EntIndexToHScript(self.attack_target_index)
        if target and not target:IsNull() and target:IsAlive() then
            print(string.format("[Backstep] ordering an attack on: %s", target:GetUnitName()))
            ExecuteOrderFromTable({
                UnitIndex = self.caster:entindex(),
                OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
                TargetIndex = target:entindex(),
                Queue = false
            })
        else
            print("[Backstep] target is gone or dead, switching to attack-move")
            -- If the target died, attack-move towards it
            local attack_move_pos = self.caster:GetAbsOrigin() + self.caster:GetForwardVector() * 300
            ExecuteOrderFromTable({
                UnitIndex = self.caster:entindex(),
                OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
                Position = attack_move_pos,
                Queue = false
            })
        end
    else
        print("[Backstep] no attack target was saved")
    end
end

function modifier_legiontd_backstep_leap:CheckState()
    return {
        [MODIFIER_STATE_STUNNED] = true,  -- cannot act while leaping
    }
end

