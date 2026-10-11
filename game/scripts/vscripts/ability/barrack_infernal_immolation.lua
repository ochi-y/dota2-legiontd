LinkLuaModifier("modifier_barrack_infernal_immolation", "ability/barrack_infernal_immolation.lua",
    LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_barrack_infernal_immolation_debuff", "ability/barrack_infernal_immolation.lua",
    LUA_MODIFIER_MOTION_NONE)
-- Abilities
if barrack_infernal_immolation == nil then
    barrack_infernal_immolation = class({})
end
function barrack_infernal_immolation:GetIntrinsicModifierName()
    return "modifier_barrack_infernal_immolation"
end
---------------------------------------------------------------------
-- Modifiers

modifier_barrack_infernal_immolation = class({
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
function modifier_barrack_infernal_immolation:OnCreated(params)
    if not self:GetAbility() then return end
    local ability = self:GetAbility()
    self.radius = ability:GetSpecialValueFor("radius")

end
function modifier_barrack_infernal_immolation:OnRefresh(params)
    if IsServer() then
    end
    self:OnCreated(params)
end
function modifier_barrack_infernal_immolation:OnDestroy()
    if IsServer() then
    end
end
function modifier_barrack_infernal_immolation:DeclareFunctions()
    return {}
end

function modifier_barrack_infernal_immolation:IsAura()
    return true
end

function modifier_barrack_infernal_immolation:GetModifierAura()
    if not IsServer() then
        return
    end

    if self:GetParent():PassivesDisabled() then
        return nil
    else
        return "modifier_barrack_infernal_immolation_debuff"
    end
end

function modifier_barrack_infernal_immolation:GetAuraRadius()
    return self.radius
end

function modifier_barrack_infernal_immolation:GetAuraDuration()
    return 0.3
end

function modifier_barrack_infernal_immolation:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_barrack_infernal_immolation:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_barrack_infernal_immolation:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

function modifier_barrack_infernal_immolation:GetAuraEntityReject(hEntity)
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
modifier_barrack_infernal_immolation_debuff = class({
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
function modifier_barrack_infernal_immolation_debuff:IsHidden()
    return false
end

function modifier_barrack_infernal_immolation_debuff:IsDebuff()
    return true
end

function modifier_barrack_infernal_immolation_debuff:IsStunDebuff()
    return false
end

function modifier_barrack_infernal_immolation_debuff:IsPurgable()
    return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_barrack_infernal_immolation_debuff:OnCreated(kv)
    if not self:GetAbility() then return end
    if not IsServer() then
        return
    end
    self.parent = self:GetParent()
    self.caster = self:GetCaster()
    -- references
    local damage = self:GetAbility():GetSpecialValueFor("damage") 
    local particle = "particles/units/heroes/hero_brewmaster/brewmaster_fire_immolation_child.vpcf"

    local effect = ParticleManager:CreateParticle(particle, PATTACH_POINT_FOLLOW, self.parent)

    local dir = Normalized2D(self.parent:GetAbsOrigin() - self.caster:GetAbsOrigin())
	self.effect=effect
    ParticleManager:SetParticleControlEnt(effect, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
	self:AddParticle(effect, false, false, -1, false, false)
    if not IsServer() then
        return
    end
    -- precache damage
    self.damageTable = {
        victim = self:GetParent(),
        attacker = self:GetCaster(),
        damage = damage,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self:GetAbility() -- Optional.
    }
    self:StartIntervalThink(1)
    self:OnIntervalThink()
end

function modifier_barrack_infernal_immolation_debuff:OnRefresh(kv)
end

function modifier_barrack_infernal_immolation_debuff:OnRemoved()
end

function modifier_barrack_infernal_immolation_debuff:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_barrack_infernal_immolation_debuff:DeclareFunctions()
    local funcs = {}
    return funcs
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_barrack_infernal_immolation_debuff:OnIntervalThink()
    if not IsServer() then
        return
    end

    ApplyDamage(self.damageTable)

	local parent = self:GetParent()
    local caster = self:GetCaster()
	if parent and caster then
		local dir = Normalized2D(self.parent:GetAbsOrigin() - self.caster:GetAbsOrigin())
		--ParticleManager:SetParticleControl(self.effect, 1, 1000*dir)
	end
    -- overhead damage info
    -- SendOverheadEventMessage(
    -- 	nil,
    -- 	OVERHEAD_ALERT_BONUS_SPELL_DAMAGE,
    -- 	self.parent,
    -- 	self.damageTable.damage,
    -- 	self.caster:GetPlayerOwner()
    -- )
end

-- --------------------------------------------------------------------------------
-- -- Graphics & Animations
-- function modifier_barrack_infernal_immolation_debuff:GetEffectName()
-- 	return "particles/humanstd/barrack_infernal_immolation_debuff.vpcf"
-- end

-- function modifier_barrack_infernal_immolation_debuff:GetEffectAttachType()
-- 	return PATTACH_ABSORIGIN_FOLLOW
-- end
