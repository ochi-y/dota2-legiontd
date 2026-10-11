LinkLuaModifier("modifier_item_rapier_x", "item_ability/item_rapier_x.lua", LUA_MODIFIER_MOTION_NONE)
-- Abilities
if item_rapier_x == nil then
    item_rapier_x = class({})
end
function item_rapier_x:GetIntrinsicModifierName()
    return "modifier_item_rapier_x"
end
---------------------------------------------------------------------
-- Modifiers
modifier_item_rapier_x = class({
IsHidden                = function(self) return true end,
IsPurgable              = function(self) return false end,
IsDebuff                = function(self) return false end,
IsBuff                  = function(self) return true end,
RemoveOnDeath           = function(self) return true end,
GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})
function modifier_item_rapier_x:OnCreated(params)
    if IsServer() then
		SimpleAddHealth(self:GetParent(),10000)
    end
end
function modifier_item_rapier_x:OnRefresh(params)
    if IsServer() then
    end
end
function modifier_item_rapier_x:OnDestroy()
    if IsServer() then
    end
end
function modifier_item_rapier_x:DeclareFunctions()
    return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
            MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end

function modifier_item_rapier_x:GetModifierPhysicalArmorBonus()
    return 6
end
function modifier_item_rapier_x:GetModifierAttackSpeedBonus_Constant()
    return 50
end

function modifier_item_rapier_x:GetModifierPreAttack_BonusDamage()
    return 150
end
