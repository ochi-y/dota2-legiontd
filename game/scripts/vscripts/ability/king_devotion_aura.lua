LinkLuaModifier("modifier_king_devotion_aura", "ability/king_devotion_aura.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_king_devotion_aura_buff", "ability/king_devotion_aura.lua", LUA_MODIFIER_MOTION_NONE)
-- Abilities
if king_devotion_aura == nil then
    king_devotion_aura = class({})
end
function king_devotion_aura:GetIntrinsicModifierName()
    return "modifier_king_devotion_aura"
end
---------------------------------------------------------------------
-- Modifiers

modifier_king_devotion_aura = class({
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

function modifier_king_devotion_aura:OnCreated(params)
    if IsServer() then
    end
end
function modifier_king_devotion_aura:OnRefresh(params)
    if IsServer() then
    end
end
function modifier_king_devotion_aura:OnDestroy()
    if IsServer() then
    end
end
function modifier_king_devotion_aura:DeclareFunctions()
    return {}
end
function modifier_king_devotion_aura:IsAura()
    return true
end
function modifier_king_devotion_aura:GetModifierAura()
    return "modifier_king_devotion_aura_buff"
end
function modifier_king_devotion_aura:GetAuraRadius()
    return 1500
end

function modifier_king_devotion_aura:GetAuraDuration()
    return 1
end

function modifier_king_devotion_aura:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_king_devotion_aura:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_king_devotion_aura:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

function modifier_king_devotion_aura:GetAuraEntityReject(hEntity)
    return false
end
--
modifier_king_devotion_aura_buff = class({
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

function modifier_king_devotion_aura_buff:DeclareFunctions()
    return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end
function modifier_king_devotion_aura_buff:GetModifierPhysicalArmorBonus()
    return 5
end

