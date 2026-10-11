LinkLuaModifier("modifier_undead_death_breath", "ability/undead_death_breath.lua", LUA_MODIFIER_MOTION_NONE)
-- Abilities
if undead_death_breath == nil then
    undead_death_breath = class({})
end
function undead_death_breath:GetIntrinsicModifierName()
    return "modifier_undead_death_breath"
end
---------------------------------------------------------------------
-- Modifiers
modifier_undead_death_breath = class({
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
function modifier_undead_death_breath:OnCreated(params)
    if IsServer() then
    end
end
function modifier_undead_death_breath:OnRefresh(params)
    if IsServer() then
    end
end
function modifier_undead_death_breath:OnDestroy()
    if IsServer() then
    end
end
function modifier_undead_death_breath:DeclareFunctions()
    return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end
function modifier_undead_death_breath:OnAttackLanded(params)
    if not IsServer() then
        return
    end
    if params.attacker ~= self:GetParent() then
        return
    end
    local ability = self:GetAbility()
    local target = params.target
    local caster = self:GetParent()
    local damage = params.damage

    local splashData = {{
        radius = ability:GetSpecialValueFor("small_radius"),
        damage = ability:GetSpecialValueFor("small_damage_pct") * damage/100
    }, {
        radius = ability:GetSpecialValueFor("large_radius"),
        damage = ability:GetSpecialValueFor("large_radius_pct") * damage/100
    }}
    splashAttack(caster, target, splashData, ability)
end
