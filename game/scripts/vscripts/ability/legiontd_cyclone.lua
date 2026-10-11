LinkLuaModifier("modifier_legiontd_cyclone", "ability/legiontd_cyclone", LUA_MODIFIER_MOTION_NONE)

-- Cyclone - lift an enemy into the air
if legiontd_cyclone == nil then
    legiontd_cyclone = class({})
end

function legiontd_cyclone:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    -- Check for Linken Sphere
    if target:TriggerSpellAbsorb(self) then
        return
    end

    -- Cast sound
    EmitSoundOn("DOTA_Item.Cyclone.Activate", target)

    -- Interrupt the target motion controller
    target:InterruptMotionControllers(true)

    -- Apply the cyclone modifier
    local duration = self:GetSpecialValueFor("duration")
    target:AddNewModifier(caster, self, "modifier_legiontd_cyclone", {
        duration = duration
    })
end

---------------------------------------------------------------------
-- Cyclone modifier
modifier_legiontd_cyclone = class({
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return false
    end,
    IsDebuff = function(self)
        return true
    end,
    IsStunDebuff = function(self)
        return false
    end
})

function modifier_legiontd_cyclone:GetMotionControllerPriority()
    return DOTA_MOTION_CONTROLLER_PRIORITY_HIGH
end

function modifier_legiontd_cyclone:IsMotionController()
    return true
end

function modifier_legiontd_cyclone:OnCreated(params)
    if not IsServer() then return end

    self.caster = self:GetCaster()
    self.parent = self:GetParent()

    -- Store the start position and angle, deep copying the vector to avoid aliasing
    local start = self.parent:GetAbsOrigin()
    self.start_pos = Vector(start.x, start.y, start.z)
    self.start_angle = self.parent:GetAngles()

    -- Current position, deep copied
    self.current_pos = Vector(start.x, start.y, start.z)

    -- Cyclone settings
    self.height = 300  -- peak height
    self.up_time = 0.3  -- rise time
    self.down_time = 0.3  -- fall time
    self.move_radius = 36  -- horizontal move radius

    print(string.format("[Cyclone] start position: (%.1f, %.1f, %.1f)",
        self.start_pos.x, self.start_pos.y, self.start_pos.z))
    print(string.format("[Cyclone] target height: %.1f", self.height))

    -- Create the cyclone effect on the ground, it does not follow the unit up
    self.particle = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_brewmaster/brewmaster_cyclone.vpcf",
        PATTACH_WORLDORIGIN,
        nil
    )
    -- Pin the effect to the start position on the ground
    ParticleManager:SetParticleControl(self.particle, 0, self.start_pos)

    -- Start the interval think
    self:StartIntervalThink(FrameTime())
end

function modifier_legiontd_cyclone:OnIntervalThink()
    self:HorizontalMotion(self.parent, FrameTime())
end

function modifier_legiontd_cyclone:HorizontalMotion(unit, dt)
    if not IsServer() then return end

    local elapsed = self:GetElapsedTime()
    local duration = self:GetDuration()

    -- Spin angle
    local angle = self.parent:GetAngles()
    local new_angle = RotateOrientation(angle, QAngle(0, 20, 0))
    self.parent:SetLocalAngles(new_angle.x, new_angle.y, new_angle.z)

    -- Z motion: rise, hover, fall
    local new_z
    if elapsed <= self.up_time then
        -- Rise: linear climb from the start height to the peak
        local progress = elapsed / self.up_time
        new_z = self.start_pos.z + (self.height * progress)

        if not self.logged_up then
            print(string.format("[Cyclone] rising: %.1f%%, height=%.1f",
                progress * 100, new_z - self.start_pos.z))
            self.logged_up = true
        end

    elseif duration - elapsed < self.down_time then
        -- Fall: linear drop back to the start height
        local remaining = duration - elapsed
        local down_progress = 1 - (remaining / self.down_time)
        new_z = self.start_pos.z + self.height * (1 - down_progress)

        if not self.logged_down then
            print(string.format("[Cyclone] falling: height=%.1f, target=%.1f",
                new_z - self.start_pos.z, 0))
            self.logged_down = true
        end

    else
        -- Hover: drift slightly around the peak
        local hover_time = elapsed - self.up_time
        local offset = math.sin(hover_time * 10) * 5
        new_z = self.start_pos.z + self.height + offset

        if not self.logged_hover then
            print(string.format("[Cyclone] hovering: height=%.1f", new_z - self.start_pos.z))
            self.logged_hover = true
        end
    end

    -- Apply the Z coordinate
    self.current_pos.z = new_z

    -- Circular motion on the XY plane
    self.current_pos.x = self.start_pos.x + math.sin(elapsed * 5 * math.pi / 2.5) * self.move_radius
    self.current_pos.y = self.start_pos.y + math.sin(elapsed * 6 * math.pi / 2.5) * self.move_radius

    -- Apply the new position, with a fresh vector each time to avoid aliasing
    self.parent:SetAbsOrigin(Vector(self.current_pos.x, self.current_pos.y, self.current_pos.z))
end

function modifier_legiontd_cyclone:OnHorizontalMotionInterrupted()
    if not IsServer() then return end
    self:Destroy()
end

function modifier_legiontd_cyclone:OnDestroy()
    if not IsServer() then return end

    print(string.format("[Cyclone] destroyed: final z=%.1f, start z=%.1f",
        self.parent:GetAbsOrigin().z, self.start_pos.z))

    -- Stop the sound
    StopSoundOn("DOTA_Item.Cyclone.Activate", self.parent)

    -- Destroy the effect
    if self.particle then
        ParticleManager:DestroyParticle(self.particle, false)
        ParticleManager:ReleaseParticleIndex(self.particle)
    end

    -- Restore the position and angle from the stored start
    self.parent:SetAbsOrigin(Vector(self.start_pos.x, self.start_pos.y, self.start_pos.z))
    self.parent:SetAngles(self.start_angle.x, self.start_angle.y, self.start_angle.z)

    print(string.format("[Cyclone] restored position: (%.1f, %.1f, %.1f)",
        self.parent:GetAbsOrigin().x, self.parent:GetAbsOrigin().y, self.parent:GetAbsOrigin().z))

    -- Resolve unit position conflicts
    ResolveNPCPositions(self.parent:GetAbsOrigin(), 128)

    -- Landing damage
    local damage = self:GetAbility():GetSpecialValueFor("damage")
    ApplyDamage({
        victim = self.parent,
        attacker = self.caster,
        damage = damage,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self:GetAbility()
    })

    -- Landing effect
    -- local land_fx = ParticleManager:CreateParticle(
    --     "particles/units/heroes/hero_brewmaster/brewmaster_thunder_clap.vpcf",
    --     PATTACH_ABSORIGIN,
    --     self.parent
    -- )
    -- ParticleManager:SetParticleControl(land_fx, 0, self.parent:GetAbsOrigin())
    -- ParticleManager:ReleaseParticleIndex(land_fx)

    -- Landing sound
    -- EmitSoundOn("Hero_Brewmaster.ThunderClap", self.parent)
end

function modifier_legiontd_cyclone:CheckState()
    return {
        [MODIFIER_STATE_STUNNED] = true,        -- stunned
        [MODIFIER_STATE_INVULNERABLE] = true,   -- invulnerable
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,  -- hide the health bar
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,  -- no unit collision
    }
end

function modifier_legiontd_cyclone:GetEffectName()
    return "particles/generic_gameplay/generic_disarm.vpcf"
end

function modifier_legiontd_cyclone:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end
