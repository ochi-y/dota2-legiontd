LinkLuaModifier("modifier_marine_feast", "ability/marine_feast.lua", LUA_MODIFIER_MOTION_NONE)
-- Abilities
if marine_feast == nil then
    marine_feast = class({})
end
function marine_feast:GetIntrinsicModifierName()
    return "modifier_marine_feast"
end
---------------------------------------------------------------------
-- Modifiers
modifier_marine_feast = class({
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
function modifier_marine_feast:OnCreated()
    self.count = 0
    local ability=self:GetAbility()
    self.attack_count=ability:GetSpecialValueFor("attack_count")
    self.heal=ability:GetSpecialValueFor("heal")
end

function modifier_marine_feast:DeclareFunctions()
    return {MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_marine_feast:OnTakeDamage(params)
    if IsServer() then
        if params.attacker == self:GetParent() and params.damage_category==DOTA_DAMAGE_CATEGORY_ATTACK then
            self.count = self.count + 1
            if self.count % self.attack_count == 0 then
                local heal = self.heal
               -- self:GetParent():Heal(heal, self:GetAbility())

                self:GetParent():HealWithParams(heal, self:GetAbility(), true, true,self:GetParent() , false)

                local effect_lifesteal = ParticleManager:CreateParticle(
                    "particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
                ParticleManager:SetParticleControl(effect_lifesteal, 0, self:GetParent():GetAbsOrigin())
                ParticleManager:ReleaseParticleIndex(effect_lifesteal)
            end
        end
    end
end
