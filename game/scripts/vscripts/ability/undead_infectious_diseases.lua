LinkLuaModifier("modifier_undead_infectious_diseases", "ability/undead_infectious_diseases.lua",
    LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_undead_infectious_diseases_buff", "ability/undead_infectious_diseases.lua",
    LUA_MODIFIER_MOTION_NONE)
-- Abilities
if undead_infectious_diseases == nil then
    undead_infectious_diseases = class({})
end
function undead_infectious_diseases:GetIntrinsicModifierName()
    return "modifier_undead_infectious_diseases"
end
---------------------------------------------------------------------
-- Modifiers

modifier_undead_infectious_diseases = class({
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

function modifier_undead_infectious_diseases:OnCreated(params)
    if not self:GetAbility() then return end
    local ability = self:GetAbility()
    self.radius = ability:GetSpecialValueFor("radius")
    self.damage_reduction = ability:GetSpecialValueFor("damage_reduction")
    if IsServer() then
    end
end
function modifier_undead_infectious_diseases:OnRefresh(params)
    if IsServer() then
    end
end
function modifier_undead_infectious_diseases:OnDestroy()
    if IsServer() then
    end
end
function modifier_undead_infectious_diseases:DeclareFunctions()
    return {}
end
function modifier_undead_infectious_diseases:IsAura()
    return true
end
function modifier_undead_infectious_diseases:GetModifierAura()
    return "modifier_undead_infectious_diseases_buff"
end

function modifier_undead_infectious_diseases:GetAuraRadius()
    return self.radius
end

function modifier_undead_infectious_diseases:GetAuraDuration()
    return 0
end

function modifier_undead_infectious_diseases:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_undead_infectious_diseases:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_undead_infectious_diseases:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_undead_infectious_diseases:GetAuraEntityReject(hEntity)
    return false
end
function modifier_undead_infectious_diseases:GetEffectName()
    return "particles/units/heroes/hero_pudge/pudge_rot.vpcf"
end

function modifier_undead_infectious_diseases:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

--
modifier_undead_infectious_diseases_buff = class({
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return false
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
        return MODIFIER_ATTRIBUTE_MULTIPLE
    end
})

function modifier_undead_infectious_diseases_buff:OnCreated()
    if not self:GetAbility() then return end
    local ability = self:GetAbility()
    self.radius = ability:GetSpecialValueFor("radius")
    self.damage_reduction = ability:GetSpecialValueFor("damage_reduction")
end
function modifier_undead_infectious_diseases_buff:DeclareFunctions()
    return {MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE}
end
function modifier_undead_infectious_diseases_buff:GetModifierDamageOutgoing_Percentage()
    return -self.damage_reduction
end

