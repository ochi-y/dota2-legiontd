LinkLuaModifier("modifier_nature_thunder_storm", "ability/nature_thunder_storm.lua", LUA_MODIFIER_MOTION_NONE)

-- Thunder Storm - passive ability
-- Summons a storm cloud that strikes a nearby enemy every 3 seconds
if nature_thunder_storm == nil then
    nature_thunder_storm = class({})
end

function nature_thunder_storm:GetIntrinsicModifierName()
    return "modifier_nature_thunder_storm"
end

---------------------------------------------------------------------
-- Thunder Storm main modifier
modifier_nature_thunder_storm = class({
    IsHidden = function(self)
        return true
    end,
    IsPurgable = function(self)
        return false
    end,
    IsDebuff = function(self)
        return false
    end,
    IsBuff = function(self)
        return true
    end,
    RemoveOnDeath = function(self)
        return true
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_NONE
    end
})

function modifier_nature_thunder_storm:OnCreated(params)
    if not self:GetAbility() then return end
    local ability = self:GetAbility()

    self.damage = ability:GetSpecialValueFor("damage")
    self.stun_duration = ability:GetSpecialValueFor("stun_duration")
    self.strike_interval = ability:GetSpecialValueFor("strike_interval")
    self.strike_radius = ability:GetSpecialValueFor("strike_radius")

    if IsServer() then
        -- Lightning aura on the unit, the power of the storm cloud
        self.particle = ParticleManager:CreateParticle(
            "particles/units/heroes/hero_leshrac/leshrac_lightning_slow.vpcf",
            PATTACH_ABSORIGIN_FOLLOW,
            self:GetParent()
        )
        ParticleManager:SetParticleControl(self.particle, 0, self:GetParent():GetAbsOrigin())

        -- Start a timer that strikes every 3 seconds
        self:StartIntervalThink(self.strike_interval)
    end
end

function modifier_nature_thunder_storm:OnRefresh(params)
    self:OnCreated(params)
end

function modifier_nature_thunder_storm:OnDestroy()
    if IsServer() then
        -- Remove the lightning aura
        if self.particle then
            ParticleManager:DestroyParticle(self.particle, false)
            ParticleManager:ReleaseParticleIndex(self.particle)
        end
    end
end

function modifier_nature_thunder_storm:OnIntervalThink()
    if not IsServer() then return end

    local parent = self:GetParent()
    local caster = self:GetCaster()
    local ability = self:GetAbility()

    -- Find the closest enemy creep in range
    local enemies = FindUnitsInRadius(
        parent:GetTeamNumber(),
        parent:GetAbsOrigin(),
        nil,
        self.strike_radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_BASIC,  -- Only creeps, never heroes
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_CLOSEST,
        false
    )

    -- Strike the first enemy found
    if #enemies > 0 then
        local target = enemies[1]
        local target_pos = target:GetAbsOrigin()

        -- Lightning sound
        EmitSoundOnLocationWithCaster(target_pos, "Hero_Zuus.LightningBolt", caster)

        -- Create the lightning effect, following the Zeus lightning bolt
        local fx = ParticleManager:CreateParticle(
            "particles/units/heroes/hero_zuus/zuus_lightning_bolt.vpcf",
            PATTACH_ABSORIGIN,
            target
        )
        ParticleManager:SetParticleControl(fx, 0, Vector(target_pos.x, target_pos.y, 2000))
        -- Bind control point 1 to the attach_hitloc of the target
        ParticleManager:SetParticleControlEnt(
            fx,
            1,
            target,
            PATTACH_POINT_FOLLOW,
            "attach_hitloc",
            target:GetAbsOrigin(),
            true
        )
        ParticleManager:SetParticleControl(fx, 2, Vector(target_pos.x, target_pos.y, target_pos.z))
        ParticleManager:ReleaseParticleIndex(fx)

        -- Deal magic damage to the target
        ApplyDamage({
            victim = target,
            attacker = caster,
            damage = self.damage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = ability
        })

        -- Apply a short stun
        target:AddNewModifier(caster, ability, "modifier_stunned", {
            duration = self.stun_duration
        })
    end
end
