LinkLuaModifier("modifier_ghost_gunslinger", "ability/ghost_gunslinger.lua", LUA_MODIFIER_MOTION_NONE)
-- Abilities
if ghost_gunslinger == nil then
    ghost_gunslinger = class({})
end
function ghost_gunslinger:GetIntrinsicModifierName()
    if self:GetLevel() then
        return "modifier_ghost_gunslinger"
    end
end

---------------------------------------------------------------------
-- Modifiers
-------------------------------------------------------------------------------------------------------
modifier_ghost_gunslinger = class({
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

function modifier_ghost_gunslinger:AllowIllusionDuplicate()
    return false
end

function modifier_ghost_gunslinger:OnCreated(params)
    local ability = self:GetAbility()

    if not ability then
        return
    end

    self.double_shot_chance = ability:GetSpecialValueFor("double_shot_chance")

    if not IsServer() then
        return
    end
    self.attackMap = {}
    self.flag = false
end

function modifier_ghost_gunslinger:OnRefresh(params)
    --
    self:OnCreated(params)
end

function modifier_ghost_gunslinger:DeclareFunctions()
    return { MODIFIER_EVENT_ON_ATTACK, MODIFIER_EVENT_ON_ATTACK_RECORD, MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND }
end

function modifier_ghost_gunslinger:GetAttackSound(params)
    return "Hero_Muerta.PierceTheVeil.Attack"
end

function modifier_ghost_gunslinger:OnAttackRecord(params)
    if not IsServer() then
        return
    end
    if params.attacker ~= self:GetParent() then
        return
    end
    local caster = self:GetCaster()
    if RandomInt(1, 100) <= self.double_shot_chance then
        self.attackMap[params.record] = true

        if caster:GetUnitName() == "ghost_wraith" then
            -- StartAnimation(caster, {
            --     duration = 0.3,
            --     activity = ACT_DOTA_CAST_ABILITY_3,
            --     rate = 3
            -- })
            -- caster:StartGesture(ACT_DOTA_CAST_ABILITY_3)
            -- StartAnimation(caster, {
            --     duration = 0.3,
            --     activity = ACT_DOTA_CAST_ABILITY_3,
            --     rate = 3
            -- })
            -- self:PlayEffects()
        end

        --
    end
    --
end

function modifier_ghost_gunslinger:PlayEffects()
    -- Get Resources
    local particle_cast = "particles/units/heroes/hero_muerta/muerta_gunslinger.vpcf"

    -- Create Particle
    local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:ReleaseParticleIndex(effect_cast)
end

function modifier_ghost_gunslinger:OnAttack(params)
    if not IsServer() then
        return
    end
    if params.attacker ~= self:GetParent() then
        return
    end
    local ability = self:GetAbility()
    local target = params.target
    --
    local caster = self:GetCaster()
    local range = caster:Script_GetAttackRange()

    if not self.flag and self.attackMap[params.record] then
        local units = FindAbilityTarget(ability, caster:GetAbsOrigin(), range + 100, {
            findOrder = FIND_ANY_ORDER
        })
        local hitTarget = units[1]

        for _, unit in ipairs(units) do
            if unit ~= target then
                hitTarget = unit
                break
            end
        end

        if hitTarget then
            self.flag = true
            caster:PerformAttack(hitTarget, true, true, true, false, true, false, false)
            self.flag = false
        end
        self.attackMap[params.record] = nil
    end
end
