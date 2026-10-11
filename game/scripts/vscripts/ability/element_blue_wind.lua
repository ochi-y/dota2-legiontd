LinkLuaModifier("modifier_element_blue_wind", "ability/element_blue_wind.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_element_blue_wind_debuff", "ability/element_blue_wind.lua", LUA_MODIFIER_MOTION_NONE)
-- Abilities
if element_blue_wind == nil then
    element_blue_wind = class({})
end
function element_blue_wind:GetIntrinsicModifierName()
    return "modifier_element_blue_wind"
end

function element_blue_wind:OnProjectileHit_ExtraData(target, location, ExtraData)
    if not target then
        return
    end
    if not IsServer() then
        return
    end

    local ability=self
    self.damage=ability:GetSpecialValueFor("damage")


    local damage=self.damage

    SimpleApplyDamage(self, self:GetCaster(), target, damage)
    EmitSoundOn("n_creep_Ranged.ProjectileImpact", target)
end
---------------------------------------------------------------------
-- Modifiers
modifier_element_blue_wind = class({
    IsHidden = function(self)
        return true
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
function modifier_element_blue_wind:OnCreated(params)
    if IsServer() then
    end
    self:StartIntervalThink(0.33)
end
function modifier_element_blue_wind:OnRefresh(params)
    if IsServer() then
    end
end
function modifier_element_blue_wind:OnDestroy()
    if IsServer() then
    end
end
function modifier_element_blue_wind:DeclareFunctions()
    return {}
end
function modifier_element_blue_wind:OnIntervalThink()
    if not IsServer() then
        return
    end
    local caster = self:GetParent()
    if caster:PassivesDisabled() then
        return
    end


    local target = SimpleFindOneRandomEnemy(caster:GetTeamNumber(), caster:GetAbsOrigin(), 450,DOTA_UNIT_TARGET_FLAG_NONE)
    if target then
        SimpleTrackingProjectile(self:GetAbility(), caster, target,
            "particles/base_attacks/ti9_radiant_ranged.vpcf", 800, {iSourceAttachment=DOTA_PROJECTILE_ATTACHMENT_HITLOCATION})
    end
end
