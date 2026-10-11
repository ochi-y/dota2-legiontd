LinkLuaModifier("modifier_arctic_bleeding", "ability/arctic_bleeding.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_arctic_bleeding_debuff", "ability/arctic_bleeding.lua", LUA_MODIFIER_MOTION_NONE)
-- Abilities
if arctic_bleeding == nil then
    arctic_bleeding = class({})
end
function arctic_bleeding:GetIntrinsicModifierName()
    return "modifier_arctic_bleeding"
end
---------------------------------------------------------------------
-- Modifiers
modifier_arctic_bleeding = class({
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
function modifier_arctic_bleeding:OnCreated(params)
    if IsServer() then
    end
    if not self:GetAbility() then return end

    local ability = self:GetAbility()
    self.hp_percent = ability:GetSpecialValueFor("hp_percent")
    self.chance = ability:GetSpecialValueFor("chance")
    self.duration = ability:GetSpecialValueFor("duration")

end
function modifier_arctic_bleeding:OnRefresh(params)
    if IsServer() then
    end
end
function modifier_arctic_bleeding:OnDestroy()
    if IsServer() then
    end
end
function modifier_arctic_bleeding:DeclareFunctions()
    return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end
function modifier_arctic_bleeding:OnAttackLanded(params)
    if not IsServer() then
        return
    end
    if params.attacker ~= self:GetParent() then
        return
    end
    local caster = self:GetParent()
    local target = params.target

    if target:IsMagicImmune() then
        return
    end
    local ability = self:GetAbility()
    local duration = self.duration
    duration = duration * (1 - CalUnitStatusResistance(target))

    local chance=self.chance


    if RandomInt(1, 100) <= chance then
        EmitSoundOn("DOTA_Item.Maim", target)
        target:AddNewModifier(caster, self:GetAbility(), "modifier_arctic_bleeding_debuff", {
            duration = duration
        })
    end
end
---------------------------------------------------------------------
-- Modifiers

modifier_arctic_bleeding_debuff = class({
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
function modifier_arctic_bleeding_debuff:OnCreated(params)
    if not self:GetAbility() then return end
    if IsServer() then
        self:StartIntervalThink(1)
    end

    local ability = self:GetAbility()
    self.damage = ability:GetSpecialValueFor("damage")
    self.attack_slow = ability:GetSpecialValueFor("attack_slow")

end
function modifier_arctic_bleeding_debuff:OnRefresh(params)
    if IsServer() then
    end
end
function modifier_arctic_bleeding_debuff:OnDestroy()
    if IsServer() then
    end
end
function modifier_arctic_bleeding_debuff:DeclareFunctions()
    return {MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE}
end
function modifier_arctic_bleeding_debuff:GetModifierAttackSpeedPercentage(params)
    if self:GetParent():IsAncient() then
        return -self.attack_slow * (100 - BOSS_ATTACK_SPEED_REDUCTION_RESISTANCE) / 100
    end
    return -self.attack_slow
end
function modifier_arctic_bleeding_debuff:OnIntervalThink()
    if not IsServer() then
        return
    end
    SimpleApplyDamage(self:GetAbility(), self:GetCaster(), self:GetParent(), self.damage)
end

function modifier_arctic_bleeding_debuff:GetEffectName()
    return "particles/items2_fx/sange_maim.vpcf"
end
function modifier_arctic_bleeding_debuff:GetEffectAttachType()
    return PATTACH_POINT_FOLLOW
end
