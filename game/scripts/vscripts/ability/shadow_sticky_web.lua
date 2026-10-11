LinkLuaModifier("modifier_shadow_sticky_web", "ability/shadow_sticky_web.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_shadow_sticky_web_debuff", "ability/shadow_sticky_web.lua", LUA_MODIFIER_MOTION_NONE)
-- Abilities
if shadow_sticky_web == nil then
    shadow_sticky_web = class({})
end
function shadow_sticky_web:GetIntrinsicModifierName()
    return "modifier_shadow_sticky_web"
end
---------------------------------------------------------------------
-- Modifiers
if modifier_shadow_sticky_web == nil then
    modifier_shadow_sticky_web = class({})
end

function modifier_shadow_sticky_web:IsHidden()
    return true
end
function modifier_shadow_sticky_web:IsPurgable(params)
    return false
end
function modifier_shadow_sticky_web:OnCreated(params)
    if not self:GetAbility() then return end
    local ability = self:GetAbility()
    self.duration = ability:GetSpecialValueFor("duration")
    self.move_slow = ability:GetSpecialValueFor("move_slow")
    self.damage_reduction = ability:GetSpecialValueFor("damage_reduction")
end
function modifier_shadow_sticky_web:OnRefresh(params)
    if IsServer() then
    end
end
function modifier_shadow_sticky_web:OnDestroy()
    if IsServer() then
    end
end
function modifier_shadow_sticky_web:DeclareFunctions()
    return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end
function modifier_shadow_sticky_web:OnAttackLanded(params)
    if not IsServer() then
        return
    end
    if params.attacker ~= self:GetParent() then
        return
    end
    if params.target:IsMagicImmune() then
        return
    end
    if params.target:HasFlyMovementCapability() then
        local duration = self.duration
        duration = duration * (1 - CalUnitStatusResistance(params.target))
        params.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_shadow_sticky_web_debuff", {
            duration = duration
        })
    end
end

modifier_shadow_sticky_web_debuff = class({
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

function modifier_shadow_sticky_web_debuff:OnCreated(kv)
    local ability = self:GetAbility()
    self.move_slow = ability:GetSpecialValueFor("move_slow")
    self.damage_reduction = ability:GetSpecialValueFor("damage_reduction")
end

function modifier_shadow_sticky_web_debuff:OnRefresh(kv)
    self:OnCreated(kv)
end
function modifier_shadow_sticky_web_debuff:DeclareFunctions()
    local funcs = {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE}
    return funcs
end

function modifier_shadow_sticky_web_debuff:GetModifierDamageOutgoing_Percentage()
    return -self.damage_reduction
end

function modifier_shadow_sticky_web_debuff:GetModifierMoveSpeedBonus_Percentage()
    return -self.move_slow
end
function modifier_shadow_sticky_web_debuff:GetEffectName()
    return "particles/units/heroes/hero_broodmother/broodmother_silken_bola_root.vpcf"
end
function modifier_shadow_sticky_web_debuff:GetEffectAttachType()
    return PATTACH_POINT_FOLLOW
end
