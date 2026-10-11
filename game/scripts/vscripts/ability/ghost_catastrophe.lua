LinkLuaModifier("modifier_ghost_catastrophe", "ability/ghost_catastrophe.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ghost_catastrophe_tag", "ability/ghost_catastrophe.lua", LUA_MODIFIER_MOTION_NONE)

-- Abilities
if ghost_catastrophe == nil then
    ghost_catastrophe = class({})
end
function ghost_catastrophe:OnAbilityPhaseStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    if target:HasModifier("modifier_ghost_catastrophe_tag") then
        return false
    end
    target:AddNewModifier(caster, self, "modifier_ghost_catastrophe_tag", {
        duration = 1
    })
    return true
end

function ghost_catastrophe:OnSpellStart()
    if not IsServer() then
        return
    end

    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    EmitSoundOn("Hero_ArcWarden.Flux.Cast", caster)

    -- SimplePlayLink("particles/units/heroes/hero_arc_warden/arc_warden_flux_cast.vpcf",caster,target,nil,nil,"attach_attack1")

    local effect_cast = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_arc_warden/arc_warden_flux_cast.vpcf", PATTACH_POINT_FOLLOW, caster)
    ParticleManager:SetParticleControlEnt(effect_cast, 0, caster, PATTACH_ROOTBONE_FOLLOW, "attach_attack1",
        caster:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(effect_cast, 1, target, PATTACH_ROOTBONE_FOLLOW, nil, target:GetAbsOrigin(),
        true)
    ParticleManager:SetParticleControlEnt(effect_cast, 2, caster, PATTACH_ROOTBONE_FOLLOW, "attach_attack1",
        caster:GetAbsOrigin(), true)
    ParticleManager:ReleaseParticleIndex(effect_cast)

    EmitSoundOn("Hero_ArcWarden.Flux.Target", target)

    local duration = self:GetSpecialValueFor("duration")
    duration = duration * (1 - CalUnitStatusResistance(target))
    target:AddNewModifier(caster, self, "modifier_ghost_catastrophe", {
        duration = duration
    })
end

modifier_ghost_catastrophe_tag = class({
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

modifier_ghost_catastrophe = class({
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

function modifier_ghost_catastrophe:OnCreated(params)
    if not self:GetAbility() then return end
    local ability = self:GetAbility()
    self.damage = ability:GetSpecialValueFor("damage")
    self.attack_slow = ability:GetSpecialValueFor("attack_slow")
    self.aoe_damage = ability:GetSpecialValueFor("aoe_damage")
    self.max_count = ability:GetSpecialValueFor("max_count")

    if IsServer() then
        self.caster = self:GetCaster()
        self.damageTable = {
            victim = self:GetParent(),
            attacker = self:GetCaster(),
            damage = self.damage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = self:GetAbility() -- Optional.
        }
        self:StartIntervalThink(1)
        local parent = self:GetParent()
        local effect_cast = ParticleManager:CreateParticle(
            "particles/units/heroes/hero_arc_warden/arc_warden_flux_tgt.vpcf", PATTACH_ROOTBONE_FOLLOW, parent)
        ParticleManager:SetParticleControl(effect_cast, 1, Vector(0, 0, 0))
        ParticleManager:SetParticleControl(effect_cast, 4, Vector(1, 0, 0))

        ParticleManager:SetParticleControlEnt(effect_cast, 2, parent, PATTACH_ABSORIGIN_FOLLOW, nil,
        parent:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(effect_cast, 0, parent, PATTACH_ABSORIGIN_FOLLOW, nil,
        parent:GetAbsOrigin(), true)

        self:AddParticle(effect_cast, false, false, -1, false, false)

    end
end

function modifier_ghost_catastrophe:OnRefresh(kv)
    self:OnCreated(kv)
end
function modifier_ghost_catastrophe:OnDestroy()
    if IsServer() then
    end
end
function modifier_ghost_catastrophe:DeclareFunctions()
    return {MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE, MODIFIER_EVENT_ON_DEATH}
end
function modifier_ghost_catastrophe:OnIntervalThink()
    if not IsServer() then
        return
    end
    ApplyDamage(self.damageTable)
    -- -- overhead damage info
    -- SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, self.parent, self.damageTable.damage,
    --     self.caster:GetPlayerOwner())
end

-- function modifier_ghost_catastrophe:GetEffectName()
--     return "particles/units/heroes/hero_arc_warden/arc_warden_flux_tgt.vpcf"
-- end

-- function modifier_ghost_catastrophe:GetEffectAttachType()
--     return PATTACH_ROOTBONE_FOLLOW
-- end

function modifier_ghost_catastrophe:GetModifierAttackSpeedPercentage()
    if self:GetParent():IsAncient() then
        return -self.attack_slow * (100 - BOSS_ATTACK_SPEED_REDUCTION_RESISTANCE) / 100
    end
    return -self.attack_slow
end
function modifier_ghost_catastrophe:OnDeath(params)
    if IsServer() then
        if params.unit == self:GetParent() then
            if IsActiveUnit(self.caster) then
                local parent = self:GetParent()
                local caster = self.caster
                local units = SimpleFindEnemy(caster:GetTeamNumber(), parent:GetAbsOrigin(), 400)
                EmitSoundOn("Hero_ArcWarden.SparkWraith.Damage", params.unit)
                for key, unit in pairs(units) do
                    if key<=self.max_count then
                        SimpleApplyDamage(self:GetAbility(), caster, unit, self.aoe_damage)
                        PlayEffOnUnit(
                            "particles/econ/items/arc_warden/arc_warden_ti9_immortal/arc_warden_ti9_wraith_cast_lightning_sparks.vpcf",
                            unit,{
                                cps={1}
                            })    
                    end
                end
            end
        end
    end
    return 0
end
