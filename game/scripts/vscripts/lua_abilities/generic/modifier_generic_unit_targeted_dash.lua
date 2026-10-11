if modifier_generic_unit_targeted_dash == nil then
    modifier_generic_unit_targeted_dash = class({})
end
function modifier_generic_unit_targeted_dash:OnCreated(params)
    self.close_distance = params.close_distance or 150
    self.far_distance = 2000

    self.speed = params.speed or 1000
    self.accel_duration = params.accel_duration or 0
    self.decel_distance = params.decel_distance or 0
    self.min_speed_pct = params.min_speed_pct or 1

    self.start_offset = params.start_offset or 0
    self.end_offset = params.end_offset or 0

    self.interrupted = false


    local vSpeed = params.vSpeed or 1000
    if IsServer() then
        self.target = EntIndexToHScript(params.targetIndex)
        if not self.target then
            self:Destroy()
            return
        end
        local parent = self:GetParent()
        local target = self.target
        if not self:ApplyHorizontalMotionController() then
            self.interrupted = true
            self:Destroy()
        end

        if vSpeed>0 then
            if not self:ApplyVerticalMotionController() then
                self.interrupted = true
                self:Destroy()
            end
        end

        local height_start = GetGroundHeight(parent:GetAbsOrigin(), parent) + self.start_offset
        local height_end = GetGroundHeight(target:GetAbsOrigin(), target) + self.end_offset

        local duration = (target:GetAbsOrigin() - parent:GetAbsOrigin()-(self.close_distance/2)):Length2D() / self.speed

        if duration<=0 then
            duration=0.1
        end
        self.vSpeed=vSpeed
        self.vAcc=2*((height_end-height_start)-vSpeed*duration)/(duration*duration)
        self.vStart=height_start
        self.vEnd=height_end
    end
end

function modifier_generic_unit_targeted_dash:OnRefresh(params)
    if IsServer() then
    end
end

function modifier_generic_unit_targeted_dash:OnDestroy()
    if IsServer() then
        -- self:GetParent():InterruptMotionControllers(true)
        if self.endCallback then
            self.endCallback(self.interrupted)
        end
        self:GetParent():RemoveHorizontalMotionController(self)
        self:GetParent():RemoveVerticalMotionController(self)
    end
end
function modifier_generic_unit_targeted_dash:DeclareFunctions()
    return {}
end
function modifier_generic_unit_targeted_dash:CheckState()
    local state = {
        [MODIFIER_STATE_DISARMED] = true
    }
    return state
end
function modifier_generic_unit_targeted_dash:UpdateHorizontalMotion(me, dt)

    if not IsServer() then
        return
    end

    

    local origin = self:GetParent():GetOrigin()
    
    if not self.target:IsAlive() then
        self:EndDash(false)
        return
    end
    -- 
    -- get direction
    local direction = self.target:GetOrigin() - origin
    direction.z = 0
    local distance = direction:Length2D()
    direction = direction:Normalized()

    -- stop if close to target
    if distance < self.close_distance then
        self:EndDash(true)
        return
    elseif distance > self.far_distance then
        self:EndDash(false)
        return
    end
    -- move towards direction
    local current_speed = self:GetCurrentSpeed(distance)
    local target = origin + direction * math.min(current_speed * dt, distance)
    self:GetParent():SetOrigin(target)
    -- face towards target
    self:GetParent():FaceTowards(self.target:GetOrigin())
end

function modifier_generic_unit_targeted_dash:GetCurrentSpeed(distance)
    local speed_pct = 1

    if self.accel_duration > 0 then
        speed_pct = math.min(speed_pct, self:GetElapsedTime() / self.accel_duration)
    end

    if self.decel_distance > 0 then
        speed_pct = math.min(speed_pct, distance / self.decel_distance)
    end

    speed_pct = math.max(self.min_speed_pct, speed_pct)
    return self.speed * speed_pct
end

function modifier_generic_unit_targeted_dash:GetVerticalPos(time)
    return self.vStart+time*self.vSpeed+self.vAcc*time*time/2
end

function modifier_generic_unit_targeted_dash:GetVerticalSpeed(time)
    return self.vStart+time*self.vAcc
end

function modifier_generic_unit_targeted_dash:UpdateVerticalMotion(me, dt)
    local pos = me:GetOrigin()
    local time = self:GetElapsedTime()

    local ground = GetGroundHeight(pos, me) + self.end_offset
    -- new
    local h=self.vStart+time*self.vSpeed+self.vAcc*time*time/2
    pos.z=h
    me:SetOrigin(pos)

    if pos.z <= ground then
        -- below ground, set height as ground then destroy
        pos.z = ground
        me:SetOrigin(pos)
        -- self:Destroy()
    end
end
function modifier_generic_unit_targeted_dash:OnHorizontalMotionInterrupted()
    self.interrupted = true
    self:Destroy()
end

function modifier_generic_unit_targeted_dash:OnVerticalMotionInterrupted()
    self.interrupted = true
    self:Destroy()
end

function modifier_generic_unit_targeted_dash:EndDash(success)
    -- cancel debuff if linken
    if success and (not self.target:TriggerSpellAbsorb(self:GetAbility())) then
        self.success = true
    end
    self:Destroy()
end

-- function modifier_generic_unit_targeted_dash:GetEffectName()
--     return "particles/units/heroes/hero_marci/marci_rebound_bounce.vpcf"
-- end

-- function modifier_generic_unit_targeted_dash:GetEffectAttachType()
--     return PATTACH_ABSORIGIN_FOLLOW
-- end
function modifier_generic_unit_targeted_dash:SetEndCallback(func)
    self.endCallback = func
end
