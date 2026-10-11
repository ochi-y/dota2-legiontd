LinkLuaModifier("modifier_armor_heavy", "ability/attack/armor_heavy.lua", LUA_MODIFIER_MOTION_NONE)
-- Abilities
if armor_heavy == nil then
    armor_heavy = class({})
end
function armor_heavy:GetIntrinsicModifierName()
    return "modifier_armor_heavy"
end
---------------------------------------------------------------------
-- Modifiers
modifier_armor_heavy = class({
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

function modifier_armor_heavy:GetTexture()
    return "attack/armor_heavy"
end

function modifier_armor_heavy:OnCreated(params)
    if IsServer() then
        self:GetParent().armorType = "heavy"
    end
end
function modifier_armor_heavy:OnRefresh(params)
    if IsServer() then
    end
end
function modifier_armor_heavy:OnDestroy()
    if IsServer() then
    end
end
function modifier_armor_heavy:DeclareFunctions()
    return {}
end
