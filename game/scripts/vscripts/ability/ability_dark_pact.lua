LinkLuaModifier("modifier_ability_dark_pact", "ability/ability_dark_pact", LUA_MODIFIER_MOTION_NONE)

ability_dark_pact = {}

function ability_dark_pact:OnSpellStart()
    local caster = self:GetCaster()
    caster:AddNewModifier(caster, self, "modifier_ability_dark_pact", {})
end

modifier_ability_dark_pact = {}

function modifier_ability_dark_pact:IsHidden()
    return true
end

function modifier_ability_dark_pact:IsDebuff()
    return false
end

function modifier_ability_dark_pact:IsPurgable()
    return false
end

function modifier_ability_dark_pact:DestroyOnExpire()
    return false
end

function modifier_ability_dark_pact:OnCreated(kv)
    if not self:GetAbility() then return end
    self.delay_time = self:GetAbility():GetSpecialValueFor("delay")
    self.pulse_duration = self:GetAbility():GetSpecialValueFor("pulse_duration")
    self.total_pulses = self:GetAbility():GetSpecialValueFor("total_pulses")
    self.total_damage = self:GetAbility():GetSpecialValueFor("total_damage")

    self.radius = self:GetAbility():GetSpecialValueFor("radius")
    self.delay = true
    self.count = 0
    self.damage = self.total_damage / self.total_pulses

    if IsServer() then
    
        local caster=self:GetParent()

        
        self.damageTable = {
            attacker = self:GetParent(),
            damage = self.damage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = self:GetAbility()
        }

        self:StartIntervalThink(self.delay_time)

        local effect_cast = ParticleManager:CreateParticleForTeam(
            "particles/units/heroes/hero_slark/slark_dark_pact_start.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent(),
            self:GetParent():GetTeamNumber())
        ParticleManager:SetParticleControlEnt(effect_cast, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW,
            "attach_hitoc", self:GetParent():GetOrigin(), true)
        ParticleManager:ReleaseParticleIndex(effect_cast)

        EmitSoundOnLocationForAllies(self:GetParent():GetOrigin(), "Hero_Slark.DarkPact.PreCast", self:GetParent())


    end
end

modifier_ability_dark_pact.OnRefresh = modifier_ability_dark_pact.OnCreated

function modifier_ability_dark_pact:OnIntervalThink()
    if self.delay then
        self.delay = false
        self:StartIntervalThink(self.pulse_duration / self.total_pulses)
		local caster=self:GetParent()
        local effect_cast = ParticleManager:CreateParticle(
            "particles/units/heroes/hero_slark/slark_dark_pact_pulses.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        ParticleManager:SetParticleControlEnt(effect_cast, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW,
            "attach_hitloc", self:GetParent():GetOrigin(), true)
        ParticleManager:SetParticleControl(effect_cast, 2, Vector(self.radius, 0, 0))
        ParticleManager:ReleaseParticleIndex(effect_cast)
        EmitSoundOn("Hero_Slark.DarkPact.Cast", self:GetParent())
		caster:StartGesture(ACT_DOTA_CAST_ABILITY_1)
    else
        local enemies = FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetOrigin(), nil,
            self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)

        self.damageTable.damage = self.damage
        self.damageTable.damage_flags = 0

        for _, enemy in pairs(enemies) do
            self.damageTable.victim = enemy
            ApplyDamage(self.damageTable)
        end

        self:GetParent():Purge(false, true, false, true, true)

        self.damageTable.damage = self.damage / 2
        self.damageTable.damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL
        self.damageTable.victim = self:GetParent()

        ApplyDamage(self.damageTable)

        self.count = self.count + 1
        if self.count >= self.total_pulses then
            self:StartIntervalThink(-1)
            self:Destroy()
        end
    end
end
