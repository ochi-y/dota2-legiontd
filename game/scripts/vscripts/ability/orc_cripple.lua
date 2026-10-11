LinkLuaModifier("modifier_orc_cripple", "ability/orc_cripple.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_orc_cripple_attack", "ability/orc_cripple.lua", LUA_MODIFIER_MOTION_NONE)
-- Abilities
if orc_cripple == nil then
    orc_cripple = class({})
end

function orc_cripple:GetIntrinsicModifierName()
    return "modifier_orc_cripple_attack"
end
---------------------------------------------------------------------
-- Modifiers
if modifier_orc_cripple_attack == nil then
    modifier_orc_cripple_attack = class({})
end

function modifier_orc_cripple_attack:IsHidden()
    return true
end
function modifier_orc_cripple_attack:IsPurgable(params)
    return false
end

function modifier_orc_cripple_attack:OnCreated(params)
    if not self:GetAbility() then return end
    local ability=self:GetAbility()
    self.duration=ability:GetSpecialValueFor("duration")

    if IsServer() then
    end
end
function modifier_orc_cripple_attack:OnRefresh(params)
    if IsServer() then
    end
end
function modifier_orc_cripple_attack:OnDestroy()
    if IsServer() then
    end
end
function modifier_orc_cripple_attack:DeclareFunctions()
    return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end
function modifier_orc_cripple_attack:OnAttackLanded(params)
    if not IsServer() then
        return
    end
    if params.attacker ~= self:GetParent() then
        return
    end

    if params.target:IsMagicImmune() then
        return
    end

    local duration=self.duration

    duration = duration * (1 - CalUnitStatusResistance(params.target))

	params.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_orc_cripple", {duration=duration})
end

---------------------------------------------------------------------
-- Modifiers

modifier_orc_cripple = class({
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
    end,
    GetEffectAttachType = function(self)
        return PATTACH_OVERHEAD_FOLLOW
    end,
    GetEffectName = function(self)
        return 'particles/units/heroes/hero_bane/bane_enfeeble.vpcf'
    end
})

function modifier_orc_cripple:OnCreated(params)
    if not self:GetAbility() then return end
    local ability=self:GetAbility()
    self.damage_reduction=ability:GetSpecialValueFor("damage_reduction")
    
    if IsServer() then
    end
end
function modifier_orc_cripple:OnRefresh(params)
    if IsServer() then
    end
end
function modifier_orc_cripple:OnDestroy()
    if IsServer() then
    end
end
function modifier_orc_cripple:DeclareFunctions()
    return {MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE}
end
function modifier_orc_cripple:GetModifierDamageOutgoing_Percentage()
    return - self.damage_reduction
end
