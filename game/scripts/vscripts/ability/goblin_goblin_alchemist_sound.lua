LinkLuaModifier("modifier_goblin_goblin_alchemist_sound", "ability/goblin_goblin_alchemist_sound.lua",
    LUA_MODIFIER_MOTION_NONE)
-- Abilities
if goblin_goblin_alchemist_sound == nil then
    goblin_goblin_alchemist_sound = class({})
end
function goblin_goblin_alchemist_sound:GetIntrinsicModifierName()
    return "modifier_goblin_goblin_alchemist_sound"
end
---------------------------------------------------------------------
-- Modifiers

modifier_goblin_goblin_alchemist_sound = class({
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
    end,
    GetAttackSound = function()
        return "Hero_Alchemist.ChemicalRage.Attack"
    end
})

function modifier_goblin_goblin_alchemist_sound:OnCreated(params)
    if IsServer() then
    end
end
function modifier_goblin_goblin_alchemist_sound:OnRefresh(params)
    if IsServer() then
    end
end
function modifier_goblin_goblin_alchemist_sound:OnDestroy()
    if IsServer() then
    end
end
function modifier_goblin_goblin_alchemist_sound:DeclareFunctions()
    return {MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND}
end
