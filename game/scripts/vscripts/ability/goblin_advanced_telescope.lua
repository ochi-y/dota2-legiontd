LinkLuaModifier("modifier_goblin_advanced_telescope", "ability/goblin_advanced_telescope.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_goblin_advanced_telescope_buff", "ability/goblin_advanced_telescope.lua", LUA_MODIFIER_MOTION_NONE)
-- Abilities
if goblin_advanced_telescope == nil then
    goblin_advanced_telescope = class({})
end
function goblin_advanced_telescope:GetIntrinsicModifierName()
    return "modifier_goblin_advanced_telescope"
end
---------------------------------------------------------------------
-- Modifiers
modifier_goblin_advanced_telescope = class({
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

function modifier_goblin_advanced_telescope:OnCreated(params)
    if not self:GetAbility() then return end
    if IsServer() then
    end
    local ability=self:GetAbility()
    self.radius=ability:GetSpecialValueFor("radius")
end
function modifier_goblin_advanced_telescope:OnRefresh(params)
    if IsServer() then
    end
end
function modifier_goblin_advanced_telescope:OnDestroy()
    if IsServer() then
    end
end
function modifier_goblin_advanced_telescope:DeclareFunctions()
    return {}
end
function modifier_goblin_advanced_telescope:IsAura()
    return true
end
function modifier_goblin_advanced_telescope:GetModifierAura()
    return "modifier_goblin_advanced_telescope_buff"
end
function modifier_goblin_advanced_telescope:GetAuraRadius()
    return self.radius
end

function modifier_goblin_advanced_telescope:GetAuraDuration()
    return 1
end

function modifier_goblin_advanced_telescope:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_goblin_advanced_telescope:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_goblin_advanced_telescope:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_RANGED_ONLY
end

function modifier_goblin_advanced_telescope:GetAuraEntityReject(hEntity)
    return false
end
--
modifier_goblin_advanced_telescope_buff = class({
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
function modifier_goblin_advanced_telescope_buff:OnCreated(params)
    if not self:GetAbility() then return end
    self.damage = self:GetAbility():GetSpecialValueFor("damage")
end

function modifier_goblin_advanced_telescope_buff:DeclareFunctions()
    return {MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE}
end

function modifier_goblin_advanced_telescope_buff:GetModifierDamageOutgoing_Percentage()
    return self.damage
end

