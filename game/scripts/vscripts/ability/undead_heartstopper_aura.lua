LinkLuaModifier("modifier_undead_heartstopper_aura", "ability/undead_heartstopper_aura.lua",
    LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_undead_heartstopper_aura_debuff", "ability/undead_heartstopper_aura.lua",
    LUA_MODIFIER_MOTION_NONE)
-- Abilities

undead_heartstopper_aura = class({})


wave_9_champion_heartstopper_aura=undead_heartstopper_aura

function undead_heartstopper_aura:GetIntrinsicModifierName()
    return "modifier_undead_heartstopper_aura"
end

---------------------------------------------------------------------
-- Modifiers

modifier_undead_heartstopper_aura = class({
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
function modifier_undead_heartstopper_aura:OnCreated(params)
    if not self:GetAbility() then return end
    local ability = self:GetAbility()
    self.aura_radius = ability:GetSpecialValueFor("aura_radius")

    if not IsServer() then return end


    local caster=self:GetCaster()
	PlayEffOnUnit("particles/units/heroes/hero_undying/undying_fg_aura2.vpcf",caster,{
		cpKv={
			[1]=Vector(self.aura_radius,self.aura_radius,self.aura_radius)
		},
		mod=self
	})

end
function modifier_undead_heartstopper_aura:OnRefresh(params)
    local ability = self:GetAbility()
    self.aura_radius = ability:GetSpecialValueFor("aura_radius")
end
function modifier_undead_heartstopper_aura:OnDestroy()
    if IsServer() then
    end
end
function modifier_undead_heartstopper_aura:DeclareFunctions()
    return {}
end

function modifier_undead_heartstopper_aura:IsAura()
    return true
end

function modifier_undead_heartstopper_aura:GetModifierAura()
    if not IsServer() then
        return
    end

    if self:GetParent():PassivesDisabled() then
        return nil
    else
        return "modifier_undead_heartstopper_aura_debuff"
    end
end

function modifier_undead_heartstopper_aura:GetAuraRadius()
    return self.aura_radius
end

function modifier_undead_heartstopper_aura:GetAuraDuration()
    return 0.3
end

function modifier_undead_heartstopper_aura:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_undead_heartstopper_aura:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_undead_heartstopper_aura:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_undead_heartstopper_aura:GetAuraEntityReject(hEntity)
    if IsServer() then

    end
    if hEntity:HasModifier("modifier_creep_dusumianyi") then
        return true
    end
    return false
end
---------------------------------------------------------------------
-- Modifiers
--------------------------------------------------------------------------------
modifier_undead_heartstopper_aura_debuff = class({
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
--------------------------------------------------------------------------------
-- Classifications
function modifier_undead_heartstopper_aura_debuff:IsHidden()
    return false
end

function modifier_undead_heartstopper_aura_debuff:IsDebuff()
    return true
end

function modifier_undead_heartstopper_aura_debuff:IsStunDebuff()
    return false
end

function modifier_undead_heartstopper_aura_debuff:IsPurgable()
    return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_undead_heartstopper_aura_debuff:OnCreated(kv)
    if not IsServer() then
        return
    end
    self.parent = self:GetParent()
    self.caster = self:GetCaster()
    -- references
    self.aura_damage = self:GetAbility():GetSpecialValueFor("aura_damage") 

    if not IsServer() then
        return
    end
    -- precache damage
    self.damageTable = {
        victim = self:GetParent(),
        attacker = self:GetCaster(),
        damage = 0,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self:GetAbility() -- Optional.
    }
    self:StartIntervalThink(1)
    self:OnIntervalThink()
end

function modifier_undead_heartstopper_aura_debuff:OnRefresh(kv)
end

function modifier_undead_heartstopper_aura_debuff:OnRemoved()
end

function modifier_undead_heartstopper_aura_debuff:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_undead_heartstopper_aura_debuff:DeclareFunctions()
    local funcs = {}
    return funcs
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_undead_heartstopper_aura_debuff:OnIntervalThink()
    if not IsServer() then
        return
    end
	self.damageTable.damage=self:GetParent():GetMaxHealth()*self.aura_damage/100
    ApplyDamage(self.damageTable)
end