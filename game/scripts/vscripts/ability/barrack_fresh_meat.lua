LinkLuaModifier("modifier_barrack_fresh_meat", "ability/barrack_fresh_meat.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_barrack_fresh_meat_buff", "ability/barrack_fresh_meat.lua", LUA_MODIFIER_MOTION_NONE)
-- Abilities
if barrack_fresh_meat == nil then
    barrack_fresh_meat = class({})
end
function barrack_fresh_meat:GetIntrinsicModifierName()
    return "modifier_barrack_fresh_meat"
end

---------------------------------------------------------------------
-- Modifiers

modifier_barrack_fresh_meat = class({
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
    GetAttackSound = function() return "Hero_Pudge.Attack.Persona" end
})

function modifier_barrack_fresh_meat:OnCreated(params)
    if not self:GetAbility() then return end

    local ability = self:GetAbility()
    self.lifesteal = ability:GetSpecialValueFor("lifesteal")

    if IsServer() then
    end
end

function modifier_barrack_fresh_meat:OnRefresh(params)
    if IsServer() then
    end
end

function modifier_barrack_fresh_meat:OnDestroy()
    if IsServer() then
    end
end

function modifier_barrack_fresh_meat:DeclareFunctions()
    return { 
        MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND
     }
end

function modifier_barrack_fresh_meat:IsAura()
    return true
end

function modifier_barrack_fresh_meat:GetModifierAura()
    return "modifier_barrack_fresh_meat_buff"
end

function modifier_barrack_fresh_meat:GetAuraRadius()
    return 400
end

function modifier_barrack_fresh_meat:GetAuraDuration()
    return 1
end

function modifier_barrack_fresh_meat:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_barrack_fresh_meat:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_barrack_fresh_meat:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

function modifier_barrack_fresh_meat:GetAuraEntityReject(hEntity)
    if hEntity:GetAttackCapability() ~= DOTA_UNIT_CAP_MELEE_ATTACK then
        return true
    end
    return false
end

--
modifier_barrack_fresh_meat_buff = class({
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

function modifier_barrack_fresh_meat_buff:DeclareFunctions()
    return { MODIFIER_EVENT_ON_TAKEDAMAGE }
end

function modifier_barrack_fresh_meat_buff:OnCreated(params)
    if not self:GetAbility() then return end

    local ability = self:GetAbility()
    self.lifesteal = ability:GetSpecialValueFor("lifesteal")

    if IsServer() then
    end
end

function modifier_barrack_fresh_meat_buff:OnTakeDamage(params)
    if IsServer() then
        if params.attacker == self:GetParent() and params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK then
            local heal = params.damage * self.lifesteal / 100
            --  self:GetParent():Heal(heal, self:GetAbility())

            self:GetParent():HealWithParams(heal, self:GetAbility(), true, true, self:GetParent(), false)

            local effect_lifesteal = ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf",
                PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
            ParticleManager:SetParticleControl(effect_lifesteal, 0, self:GetParent():GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(effect_lifesteal)
        end
    end
end
