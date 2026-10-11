LinkLuaModifier("modifier_arctic_frost_shield", "ability/arctic_frost_shield.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_arctic_frost_shield_buff", "ability/arctic_frost_shield.lua", LUA_MODIFIER_MOTION_NONE)
-- Abilities
if arctic_frost_shield == nil then
    arctic_frost_shield = class({})
end
function arctic_frost_shield:GetIntrinsicModifierName()
    return "modifier_arctic_frost_shield"
end
---------------------------------------------------------------------
-- Modifiers
modifier_arctic_frost_shield = class({
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

function modifier_arctic_frost_shield:OnCreated(params)
    if not self:GetAbility() then return end
    local ability = self:GetAbility()
    self.damage = ability:GetSpecialValueFor("damage")
    self.radius = ability:GetSpecialValueFor("radius")

    if IsServer() then
    end
end
function modifier_arctic_frost_shield:OnRefresh(params)
    if IsServer() then
    end
end
function modifier_arctic_frost_shield:OnDestroy()
    if IsServer() then
    end
end
function modifier_arctic_frost_shield:DeclareFunctions()
    return {}
end
function modifier_arctic_frost_shield:IsAura()
    return true
end
function modifier_arctic_frost_shield:GetModifierAura()
    return "modifier_arctic_frost_shield_buff"
end
function modifier_arctic_frost_shield:GetAuraRadius()

    return self.radius

end

function modifier_arctic_frost_shield:GetAuraDuration()
    return 0
end

function modifier_arctic_frost_shield:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_arctic_frost_shield:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_arctic_frost_shield:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

function modifier_arctic_frost_shield:GetAuraEntityReject(hEntity)
    return false
end
--
modifier_arctic_frost_shield_buff = class({
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

function modifier_arctic_frost_shield_buff:OnCreated()
    if not self:GetAbility() then return end
    local ability = self:GetAbility()
    self.damage = ability:GetSpecialValueFor("damage")
end

function modifier_arctic_frost_shield_buff:DeclareFunctions()
    return {MODIFIER_EVENT_ON_ATTACKED}
end
function modifier_arctic_frost_shield_buff:OnAttacked(params)
    if not IsServer() then
        return
    end
    if params.target ~= self:GetParent() then
        return
    end
    local attacker = params.attacker
    local target = params.target
    
    if target:IsMagicImmune() then
        return
    end

    if attacker:GetAttackCapability() == DOTA_UNIT_CAP_MELEE_ATTACK then
        local factor = SimpleGetAttackFactor(target, attacker)
        local damage = math.ceil(self.damage * params.damage * factor / 100)
        SimpleApplyDamage(self:GetAbility(), self:GetCaster(), attacker, damage, nil,
        DOTA_DAMAGE_FLAG_BYPASSES_ALL_BLOCK + DOTA_DAMAGE_FLAG_REFLECTION)
    end
end

