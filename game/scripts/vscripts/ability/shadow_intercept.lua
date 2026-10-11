LinkLuaModifier("modifier_shadow_intercept_charge", "ability/shadow_intercept.lua", LUA_MODIFIER_MOTION_NONE)

-- Shadow intercept ability
if shadow_intercept == nil then
    shadow_intercept = class({})
end

function shadow_intercept:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    if not target then return end

    -- Ability parameters
    local min_range = self:GetSpecialValueFor("min_range")
    local stun_duration = self:GetSpecialValueFor("stun_duration")
    local damage = self:GetSpecialValueFor("damage")

    -- Range check: do not charge when the target is too close
    local distance = (caster:GetAbsOrigin() - target:GetAbsOrigin()):Length2D()
    if distance < min_range then
        -- target too close, no charge
        self:EndCooldown()
        return
    end

    -- Add the charge modifier
    caster:AddNewModifier(
        caster,
        self,
        "modifier_shadow_intercept_charge",
        {
            target_entindex = target:entindex(),
            charge_speed = 1000,
            stun_duration = stun_duration,
            damage = damage
        }
    )

    -- Cast sound
    EmitSoundOn("DOTA_Item.Butterfly", caster)
end

---------------------------------------------------------------------
-- Charge modifier
if modifier_shadow_intercept_charge == nil then
    modifier_shadow_intercept_charge = class({})
end

function modifier_shadow_intercept_charge:IsHidden()
    return false
end

function modifier_shadow_intercept_charge:IsPurgable()
    return false
end

function modifier_shadow_intercept_charge:OnCreated(params)
    if not IsServer() then return end

    -- Remember the target
    self.target = EntIndexToHScript(params.target_entindex)
    self.max_speed = params.charge_speed  -- max speed
    self.stun_duration = params.stun_duration
    self.damage = params.damage
    self.hit_target = false

    -- Acceleration settings
    self.current_speed = 500  -- starts slow
    self.acceleration = 6000  -- acceleration: +3000 speed per second
    self.interval = 0.03  -- tick interval

    -- Create the particle effect
    --
    -- particles/units/heroes/hero_spirit_breaker/spirit_breaker_charge.vpcf
    self.particle = ParticleManager:CreateParticle(
        "particles/econ/events/fall_2022/phase_boots/phase_boots_fall_2022.vpcf",
        PATTACH_ABSORIGIN_FOLLOW,
        self:GetParent()
    )

    -- Start moving
    self:StartIntervalThink(self.interval)
end

function modifier_shadow_intercept_charge:OnIntervalThink()
    if not IsServer() then return end

    local caster = self:GetParent()

    -- Is the target still alive?
    if not self.target or not self.target:IsAlive() then
        self:Destroy()
        return
    end

    -- Accelerate up to the maximum speed
    if self.current_speed < self.max_speed then
        self.current_speed = self.current_speed + self.acceleration * self.interval
        -- Never exceed the maximum speed
        if self.current_speed > self.max_speed then
            self.current_speed = self.max_speed
        end
    end

    -- Current position and target position
    local caster_pos = caster:GetAbsOrigin()
    local target_pos = self.target:GetAbsOrigin()
    local direction = (target_pos - caster_pos):Normalized()

    -- Distance
    local distance = (target_pos - caster_pos):Length2D()

    -- On arrival, deal damage and stun
    if distance < 150 and not self.hit_target then
        self:HitTarget()
        return
    end

    -- Move the caster at the current speed
    local new_pos = caster_pos + direction * self.current_speed * self.interval
    caster:SetAbsOrigin(new_pos)

    -- Face the target
    caster:SetForwardVector(direction)

    -- Destroy the trees along the path
    GridNav:DestroyTreesAroundPoint(caster_pos, 100, false)
end

function modifier_shadow_intercept_charge:HitTarget()
    if self.hit_target then return end
    self.hit_target = true

    local caster = self:GetParent()
    local target = self.target

    -- Deal the damage
    ApplyDamage({
        victim = target,
        attacker = caster,
        damage = self.damage,
        damage_type = DAMAGE_TYPE_PHYSICAL,
        ability = self:GetAbility()
    })

    -- Stun the target
    target:AddNewModifier(
        caster,
        self:GetAbility(),
        "modifier_stunned",
        {duration = self.stun_duration}
    )

    -- Impact sound
    -- EmitSoundOn("Hero_Spirit_Breaker.GreaterBash", target)
    EmitSoundOn("Hero_Marci.Grapple.Stun", target)

    -- Impact effect
    local hit_particle = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_spirit_breaker/spirit_breaker_greater_bash.vpcf",
        PATTACH_ABSORIGIN,
        target
    )
    ParticleManager:SetParticleControl(hit_particle, 0, target:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(hit_particle)

    -- Find the caster a spot so it does not get stuck inside the target
    FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)

    -- Brief no-collision state so the units can separate
    caster:AddNewModifier(
        caster,
        self:GetAbility(),
        "modifier_phased",
        {duration = 0.1}
    )

    -- Make the caster attack the target
    caster:MoveToTargetToAttack(target)

    -- Remove the charge modifier
    self:Destroy()
end

function modifier_shadow_intercept_charge:OnDestroy()
    if not IsServer() then return end

    -- Remove the particle effect
    if self.particle then
        ParticleManager:DestroyParticle(self.particle, false)
        ParticleManager:ReleaseParticleIndex(self.particle)
    end

    -- Stop the sound
    StopSoundOn("Hero_Spirit_Breaker.ChargeOfDarkness", self:GetParent())
end

function modifier_shadow_intercept_charge:CheckState()
    return {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
        [MODIFIER_STATE_IGNORING_MOVE_AND_ATTACK_ORDERS] = true
    }
end

function modifier_shadow_intercept_charge:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
        MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS
    }
end

function modifier_shadow_intercept_charge:GetModifierMoveSpeed_Absolute()
    return self.current_speed or self.max_speed or 0
end

function modifier_shadow_intercept_charge:GetActivityTranslationModifiers()
    return "run"
end
