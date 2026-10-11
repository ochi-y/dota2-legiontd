LinkLuaModifier("modifier_element_amplify_magic", "ability/element_amplify_magic.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_element_amplify_magic_buff", "ability/element_amplify_magic.lua", LUA_MODIFIER_MOTION_NONE)
-- Abilities
if element_amplify_magic == nil then
    element_amplify_magic = class({})
end
function element_amplify_magic:GetIntrinsicModifierName()
    return "modifier_element_amplify_magic"
end
---------------------------------------------------------------------
-- Modifiers

modifier_element_amplify_magic = class({
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

function modifier_element_amplify_magic:OnCreated(params)
    if not self:GetAbility() then return end
    if IsServer() then
    end

    local ability=self:GetAbility()

    if not ability then
        return
    end   
    
    self.radius=ability:GetSpecialValueFor("radius")
end
function modifier_element_amplify_magic:OnRefresh(params)
    if IsServer() then
    end
end
function modifier_element_amplify_magic:OnDestroy()
    if IsServer() then
    end
end
function modifier_element_amplify_magic:DeclareFunctions()
    return {}
end
function modifier_element_amplify_magic:IsAura()
    return true
end
function modifier_element_amplify_magic:GetModifierAura()
    return "modifier_element_amplify_magic_buff"
end
function modifier_element_amplify_magic:GetAuraRadius()
    local radius=self.radius
    return radius
end

function modifier_element_amplify_magic:GetAuraDuration()
    return 0.3
end

function modifier_element_amplify_magic:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_element_amplify_magic:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_element_amplify_magic:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

function modifier_element_amplify_magic:GetAuraEntityReject(hEntity)
    return false
end
--
modifier_element_amplify_magic_buff = class({
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

function modifier_element_amplify_magic_buff:OnCreated()
    if not self:GetAbility() then return end
    local ability=self:GetAbility()
    self.mana_rege_percent=ability:GetSpecialValueFor("mana_rege_percent")

    self.mana = self.mana_rege_percent * (self:GetParent():GetMaxMana())/100
end

function modifier_element_amplify_magic_buff:DeclareFunctions()
    return {MODIFIER_PROPERTY_MANA_REGEN_CONSTANT}
end
function modifier_element_amplify_magic_buff:GetModifierConstantManaRegen()
    return self.mana
end

