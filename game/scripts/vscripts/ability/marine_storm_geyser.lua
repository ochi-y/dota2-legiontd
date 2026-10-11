LinkLuaModifier("modifier_marine_storm_geyser_heal", "ability/marine_storm_geyser.lua", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_marine_storm_geyser_heal_buff", "ability/marine_storm_geyser.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_marine_storm_geyser_damage", "ability/marine_storm_geyser.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_marine_storm_geyser_tag", "ability/marine_storm_geyser.lua", LUA_MODIFIER_MOTION_NONE)

-- Abilities
if marine_storm_geyser == nil then
    marine_storm_geyser = class({})
end


function marine_storm_geyser:OnSpellStart()
    local caster = self:GetCaster()
    local pos = self:GetCursorPosition()


    if IsCustomBuilding(caster) then
		GamePlay:FighterSetAbilityTarget(caster.fighterId,self:GetAbilityName(),pos)
	end
    
    CreateModifierThinker(caster, self, "modifier_marine_storm_geyser_heal", {
        duration = 15
    }, pos, caster:GetTeamNumber(), false)
    CreateModifierThinker(caster, self, "modifier_marine_storm_geyser_damage", {
        duration = 15
    }, pos, caster:GetTeamNumber(), false)
    EmitSoundOn("Hero_Oracle.RainOfDestiny.Cast", caster)
end
---------------------------------------------------------------------
-- Modifiers
if modifier_marine_storm_geyser_heal == nil then
    modifier_marine_storm_geyser_heal = class({})
end
function modifier_marine_storm_geyser_heal:OnCreated(params)
    if not self:GetAbility() then return end
    local ability=self:GetAbility()
    self.hp_regen=ability:GetSpecialValueFor("hp_regen")
    self.hit_count=ability:GetSpecialValueFor("hit_count")
    self.damage=ability:GetSpecialValueFor("damage")
    self.hit_gap=ability:GetSpecialValueFor("hit_gap")
    self.duration=ability:GetSpecialValueFor("duration")
    self.radius=ability:GetSpecialValueFor("radius")





    if IsServer() then
        local caster = self:GetCaster()


        local parent = self:GetParent()
        local eff = "particles/units/heroes/hero_oracle/oracle_scepter_rain_of_destiny.vpcf"
        local particle = ParticleManager:CreateParticle(eff, PATTACH_ABSORIGIN_FOLLOW, parent)
        ParticleManager:SetParticleControlEnt(particle, 0, parent, PATTACH_ABSORIGIN_FOLLOW, nil, parent:GetAbsOrigin(),
            true)
        ParticleManager:SetParticleControl(particle, 1, Vector(self.radius, self.radius, self.radius))
        self.particle = particle
        EmitSoundOn("Hero_Oracle.RainOfDestiny", self:GetParent())
    end
end
function modifier_marine_storm_geyser_heal:OnRefresh(params)
    if IsServer() then

    end
end
function modifier_marine_storm_geyser_heal:IsPurgable(params)
    return false
end
function modifier_marine_storm_geyser_heal:OnDestroy()
    if IsServer() then
        ParticleManager:DestroyParticle(self.particle, false)
        StopSoundOn("Hero_Oracle.RainOfDestiny", self:GetParent())
    end
end
function modifier_marine_storm_geyser_heal:DeclareFunctions()
    return {}
end

function modifier_marine_storm_geyser_heal:IsAura()
    return true
end
function modifier_marine_storm_geyser_heal:GetModifierAura()
    return "modifier_marine_storm_geyser_heal_buff"
end
function modifier_marine_storm_geyser_heal:GetAuraRadius()
    return self.radius
end

function modifier_marine_storm_geyser_heal:GetAuraDuration()
    return 0
end

function modifier_marine_storm_geyser_heal:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_marine_storm_geyser_heal:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_marine_storm_geyser_heal:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

function modifier_marine_storm_geyser_heal:GetAuraEntityReject(hEntity)
    return false
end

modifier_marine_storm_geyser_heal_buff = class({
    IsHidden = function(self)
        return false
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

function modifier_marine_storm_geyser_heal_buff:OnCreated()
    if not self:GetAbility() then return end
    local ability=self:GetAbility()
    self.hp_regen=ability:GetSpecialValueFor("hp_regen")
    self.hit_count=ability:GetSpecialValueFor("hit_count")
    self.damage=ability:GetSpecialValueFor("damage")
    self.hit_gap=ability:GetSpecialValueFor("hit_gap")
    self.duration=ability:GetSpecialValueFor("duration")
    self.radius=ability:GetSpecialValueFor("radius")

    
end

function modifier_marine_storm_geyser_heal_buff:DeclareFunctions()
    return {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT}
end

function modifier_marine_storm_geyser_heal_buff:GetModifierConstantHealthRegen()
    return self.hp_regen
end
---------------------------------------------------------------------
-- Modifiers
if modifier_marine_storm_geyser_damage == nil then
    modifier_marine_storm_geyser_damage = class({})
end
function modifier_marine_storm_geyser_damage:OnCreated(params)
    if not self:GetAbility() then return end
    local ability=self:GetAbility()
    self.hp_regen=ability:GetSpecialValueFor("hp_regen")
    self.hit_count=ability:GetSpecialValueFor("hit_count")
    self.damage=ability:GetSpecialValueFor("damage")
    self.hit_gap=ability:GetSpecialValueFor("hit_gap")
    self.duration=ability:GetSpecialValueFor("duration")
    self.radius=ability:GetSpecialValueFor("radius")

    if IsServer() then



        self:StartIntervalThink(self.hit_gap)
        self:OnIntervalThink()
    end
end
function modifier_marine_storm_geyser_damage:OnRefresh(params)
    if IsServer() then
    end
end
function modifier_marine_storm_geyser_damage:OnDestroy()
    if IsServer() then
    end
end
function modifier_marine_storm_geyser_damage:IsPurgable(params)
    return false
end
function modifier_marine_storm_geyser_damage:DeclareFunctions()
    return {}
end
function modifier_marine_storm_geyser_damage:OnIntervalThink()
    if not IsServer() then
        return
    end
    local caster = self:GetCaster()

    local ability=self:GetAbility()
    if caster then
        local point = self:GetParent():GetOrigin()
        local units = SimpleFindEnemy(caster:GetTeamNumber(), point, self.radius)
        for i = 1, math.min(self.hit_count, #units) do

            local fx = ParticleManager:CreateParticle(
                "particles/units/heroes/hero_razor/razor_storm_lightning_strike.vpcf", PATTACH_WORLDORIGIN,
                self:GetParent())

            ParticleManager:SetParticleControl(fx, 0, self:GetParent():GetAbsOrigin() + Vector(0, 0, 500))

            ParticleManager:SetParticleControl(fx, 1, units[i]:GetAbsOrigin() + Vector(0, 0, 100))

            ParticleManager:ReleaseParticleIndex(fx)
            EmitSoundOn("Hero_razor.lightning", units[i])
            SimpleApplyDamage(ability, caster, units[i], self.damage)
        end
    end
end


function modifier_marine_storm_geyser_damage:GetEffectName()
    return "particles/units/heroes/hero_razor_reduced_flash/razor_rain_storm_reduced_flash.vpcf"
end
function modifier_marine_storm_geyser_damage:GetEffectAttachType()
    return PATTACH_POINT_FOLLOW
end

-------------------------------------------------------------------------------------------------------
modifier_marine_storm_geyser_tag = class({
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
function modifier_marine_storm_geyser_tag:AllowIllusionDuplicate()
    return false
end
function modifier_marine_storm_geyser_tag:OnCreated(params)
end
function modifier_marine_storm_geyser_tag:OnRefresh(params)
end
