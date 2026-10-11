LinkLuaModifier("modifier_arctic_cold_attack", "ability/arctic_cold_attack.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_arctic_cold_attack_debuff", "ability/arctic_cold_attack.lua", LUA_MODIFIER_MOTION_NONE)
-- Abilities
if arctic_cold_attack == nil then
    arctic_cold_attack = class({})
end
function arctic_cold_attack:GetIntrinsicModifierName()
    return "modifier_arctic_cold_attack"
end
---------------------------------------------------------------------
-- Modifiers
if modifier_arctic_cold_attack == nil then
    modifier_arctic_cold_attack = class({})
end

function modifier_arctic_cold_attack:IsHidden()
    return true
end

function modifier_arctic_cold_attack:IsPurgable(params)
    return false
end

function modifier_arctic_cold_attack:OnCreated(params)
    if not self:GetAbility() then return end
    local ability=self:GetAbility()
    self.duration=ability:GetSpecialValueFor("duration")
    
    if IsServer() then
    end
end
function modifier_arctic_cold_attack:OnRefresh(params)
    if IsServer() then
    end
end
function modifier_arctic_cold_attack:OnDestroy()
    if IsServer() then
    end
end

function modifier_arctic_cold_attack:DeclareFunctions()
    return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end
function modifier_arctic_cold_attack:OnAttackLanded(params)
    if not IsServer() then
        return
    end
    if params.attacker ~= self:GetParent() then
        return
    end

    if params.target:IsMagicImmune() then
        return
    end
    local caster=self:GetCaster()
    local duration=self.duration
    local target=params.target
    local ability=self:GetAbility()
    
    duration = duration * (1 - CalUnitStatusResistance(params.target))
	params.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_arctic_cold_attack_debuff", {duration=duration})
end

modifier_arctic_cold_attack_debuff = class({
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

function modifier_arctic_cold_attack_debuff:OnCreated(kv)
    if not self:GetAbility() then return end
    local ability=self:GetAbility()

    self.attack_slow=ability:GetSpecialValueFor("attack_slow")
    self.move_slow=ability:GetSpecialValueFor("move_slow")

end

function modifier_arctic_cold_attack_debuff:OnRefresh(kv)
    self:OnCreated(kv)
end
function modifier_arctic_cold_attack_debuff:DeclareFunctions()
    local funcs = {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE}
    return funcs
end

function modifier_arctic_cold_attack_debuff:GetModifierMoveSpeedBonus_Percentage()
    return -self.move_slow
end
function modifier_arctic_cold_attack_debuff:GetModifierAttackSpeedPercentage(params)
    if self:GetParent():IsAncient() then
        return -self.attack_slow*(100-BOSS_ATTACK_SPEED_REDUCTION_RESISTANCE)/100
    end
    return -self.attack_slow
end
function modifier_arctic_cold_attack_debuff:GetStatusEffectName()
    return "particles/status_fx/status_effect_frost_lich.vpcf"
end
function modifier_arctic_cold_attack_debuff:StatusEffectPriority()
    return 100
end
