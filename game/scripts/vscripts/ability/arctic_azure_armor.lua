LinkLuaModifier("modifier_arctic_azure_armor", "ability/arctic_azure_armor.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_arctic_azure_armor_debuff", "ability/arctic_azure_armor.lua", LUA_MODIFIER_MOTION_NONE)
-- Abilities
if arctic_azure_armor == nil then
    arctic_azure_armor = class({})
end
function arctic_azure_armor:GetIntrinsicModifierName()
    return "modifier_arctic_azure_armor"
end
---------------------------------------------------------------------
-- Modifiers
if modifier_arctic_azure_armor == nil then
    modifier_arctic_azure_armor = class({})
end
function modifier_arctic_azure_armor:IsPurgable(params)
    return false
end
function modifier_arctic_azure_armor:OnCreated(params)
    if not self:GetAbility() then return end
    local ability = self:GetAbility()
    self.armor = ability:GetSpecialValueFor("armor")
    self.duration = ability:GetSpecialValueFor("duration")

end
function modifier_arctic_azure_armor:OnRefresh(params)
    if IsServer() then
    end
end
function modifier_arctic_azure_armor:OnDestroy()
    if IsServer() then
    end
end
function modifier_arctic_azure_armor:DeclareFunctions()
    return {MODIFIER_EVENT_ON_ATTACKED, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end
function modifier_arctic_azure_armor:GetModifierPhysicalArmorBonus()
    return self.armor
end

function modifier_arctic_azure_armor:OnAttacked(params)
    if not IsServer() then
        return
    end
    if params.target ~= self:GetParent() then
        return
    end
    local attacker = params.attacker
    local target = params.target

    if attacker:IsMagicImmune() then
        return
    end
    local duration=self.duration
    duration = duration * (1 - CalUnitStatusResistance(target))
    attacker:AddNewModifier(target, self:GetAbility(), "modifier_arctic_azure_armor_debuff", {
        duration = duration
    })
end
---------------------------------------------------------------------
-- Modifiers
modifier_arctic_azure_armor_debuff = class({
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
        return MODIFIER_ATTRIBUTE_NONE
    end
})

function modifier_arctic_azure_armor_debuff:OnCreated(kv)
    if not self:GetAbility() then return end
    local ability = self:GetAbility()
    self.attack_slow = ability:GetSpecialValueFor("attack_slow")
    self.move_slow = ability:GetSpecialValueFor("move_slow")
end

function modifier_arctic_azure_armor_debuff:OnRefresh(kv)
    self:OnCreated(kv)
end
function modifier_arctic_azure_armor_debuff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE
    }
    return funcs
end

function modifier_arctic_azure_armor_debuff:GetModifierMoveSpeedBonus_Percentage()
    return -self.move_slow
end
function modifier_arctic_azure_armor_debuff:GetModifierAttackSpeedPercentage(params)
    if self:GetParent():IsAncient() then
        return -self.attack_slow*(100-BOSS_ATTACK_SPEED_REDUCTION_RESISTANCE)/100
end
    return -self.attack_slow
end
function modifier_arctic_azure_armor_debuff:GetStatusEffectName()
    return "particles/generic_gameplay/generic_slowed_cold.vpcf"
end
function modifier_arctic_azure_armor_debuff:StatusEffectPriority()
    return 100
end
