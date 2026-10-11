LinkLuaModifier("modifier_shadow_sound_of_madness", "ability/shadow_sound_of_madness.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_shadow_sound_of_madness_buff", "ability/shadow_sound_of_madness.lua", LUA_MODIFIER_MOTION_NONE)
-- Abilities
if shadow_sound_of_madness == nil then
    shadow_sound_of_madness = class({})
end
function shadow_sound_of_madness:GetIntrinsicModifierName()
    return "modifier_shadow_sound_of_madness"
end
---------------------------------------------------------------------
-- Modifiers

modifier_shadow_sound_of_madness = class({
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
function modifier_shadow_sound_of_madness:IsPurgable(params)
    return false
end
function modifier_shadow_sound_of_madness:OnCreated(params)

    if not self:GetAbility() then return end

    local ability = self:GetAbility()
    self.life_steal = ability:GetSpecialValueFor("life_steal")
    self.radius = ability:GetSpecialValueFor("radius")
    if IsServer() then
    end
end
function modifier_shadow_sound_of_madness:OnRefresh(params)
    if IsServer() then
    end
end
function modifier_shadow_sound_of_madness:OnDestroy()
    if IsServer() then
    end
end
function modifier_shadow_sound_of_madness:DeclareFunctions()
    return {}
end
function modifier_shadow_sound_of_madness:IsAura()
    return true
end
function modifier_shadow_sound_of_madness:GetModifierAura()
    return "modifier_shadow_sound_of_madness_buff"
end
function modifier_shadow_sound_of_madness:GetAuraRadius()
	local radius=self.radius
	return radius
end

function modifier_shadow_sound_of_madness:GetAuraDuration()
    return 0
end

function modifier_shadow_sound_of_madness:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_shadow_sound_of_madness:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_shadow_sound_of_madness:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

function modifier_shadow_sound_of_madness:GetAuraEntityReject(hEntity)
    if not hEntity then return true end
    return hEntity:GetAttackCapability() == DOTA_UNIT_CAP_RANGED_ATTACK
end
--
modifier_shadow_sound_of_madness_buff = class({
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

function modifier_shadow_sound_of_madness_buff:OnCreated()
    if not self:GetAbility() then return end
    local ability = self:GetAbility()
    self.life_steal = ability:GetSpecialValueFor("life_steal")
    self.radius = ability:GetSpecialValueFor("radius")
end
function modifier_shadow_sound_of_madness_buff:DeclareFunctions()
    return {MODIFIER_EVENT_ON_TAKEDAMAGE}
end
function modifier_shadow_sound_of_madness_buff:OnTakeDamage(params)
    if IsServer() then

        local parent = self:GetParent()

        if params.attacker == parent and params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK then
            local heal = math.floor(params.damage * self.life_steal/100)


            parent:HealWithParams(heal, self, true, true, parent, false)

            -- show the heal number
            PopupHealing(parent, heal)

            local effect_lifesteal = ParticleManager:CreateParticle(
                "particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
            ParticleManager:SetParticleControl(effect_lifesteal, 0, parent:GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(effect_lifesteal)
        end
    end
end

