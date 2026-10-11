LinkLuaModifier("modifier_legiontd_defend", "ability/legiontd_defend.lua", LUA_MODIFIER_MOTION_NONE)
-- Abilities
if legiontd_defend == nil then
    legiontd_defend = class({})
end
function legiontd_defend:OnToggle()
    local caster = self:GetCaster()
    local modifier = caster:FindModifierByName("modifier_legiontd_defend")
    if self:GetToggleState() then
        caster:AddNewModifier(caster, self, "modifier_legiontd_defend", {})
    else
        if modifier then
            modifier:Destroy()
        end
    end
end
function legiontd_defend:OnProjectileHit_ExtraData(target, location, params)
    if not target then
        return
    end
	local factor=SimpleGetAttackFactor(self:GetCaster(), target)
	SimpleApplyDamage(self,self:GetCaster(),target,params.damage*factor,DAMAGE_TYPE_PHYSICAL)
end

---------------------------------------------------------------------
-- Modifiers
-------------------------------------------------------------------------------------------------------
modifier_legiontd_defend = class({
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
function modifier_legiontd_defend:AllowIllusionDuplicate()
    return false
end
function modifier_legiontd_defend:OnCreated(params)
    -- self.damage = params.damage
    -- self:SetHasCustomTransmitterData(true) 

    local ability = self:GetAbility()
    self.chance = ability:GetSpecialValueFor("chance")
    self.damage_taken = ability:GetSpecialValueFor("damage_taken")
    self.move_speed_slow = ability:GetSpecialValueFor("move_speed_slow")
end
function modifier_legiontd_defend:DeclareFunctions()
    return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, 
	MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK}
end
-- function modifier_legiontd_defend:OnAttackLanded(params)
--     if not IsServer() then
--         return
--     end
--     local attacker = params.attacker
--     if attacker and params.target == self:GetParent() then
--         local speed = attacker:GetProjectileSpeed() or 1000
--         local model = GetUnitKV(attacker:GetUnitName(), "ProjectileModel", 1)
--         if not model then
--             model = "particles/units/heroes/hero_windrunner/windrunner_base_attack.vpcf"
--         end
--         SimpleTrackingProjectile(self:GetAbility(), self:GetParent(), attacker, model, speed)
--     end
-- end
function modifier_legiontd_defend:doReflect(attacker, damage)
    if not IsServer() then
        return
    end
    local speed = attacker:GetProjectileSpeed() or 1000
    local model = GetUnitKV(attacker:GetUnitName(), "ProjectileModel", 1)
    if not model then
        model = "particles/units/heroes/hero_windrunner/windrunner_base_attack.vpcf"
    end
    SimpleTrackingProjectile(self:GetAbility(), self:GetParent(), attacker, model, speed, {
        ExtraData = {
            damage = damage
        }
    })
end
function modifier_legiontd_defend:GetModifierPhysical_ConstantBlock(params)
    if not IsServer() then
        return
    end
    local target = self:GetParent()
    local attacker = params.attacker
    if attacker and params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK and attacker.attackType == "pierce" and params.ranged_attack then
        if RandomInt(1, 100) <= self.chance then
            self:doReflect(attacker, params.original_damage)
            return params.damage
        else
            return math.ceil(params.damage * (100 - self.damage_taken) / 100)
        end
    end
end
function modifier_legiontd_defend:CheckState()
    local state = {}
    return state
end

function modifier_legiontd_defend:GetModifierMoveSpeedBonus_Percentage()
    return -self.move_speed_slow
end

