LinkLuaModifier("modifier_demi_human_fury", "ability/demi_human_fury.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_demi_human_fury_buff", "ability/demi_human_fury.lua", LUA_MODIFIER_MOTION_NONE)
-- Abilities
if demi_human_fury == nil then
    demi_human_fury = class({})
end
function demi_human_fury:GetIntrinsicModifierName()
    return "modifier_demi_human_fury"
end

---------------------------------------------------------------------
-- Modifiers
modifier_demi_human_fury = class({
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
function modifier_demi_human_fury:OnCreated(params)
    local ability = self:GetAbility()
    self.chance = ability:GetSpecialValueFor("chance")
    self.duration = ability:GetSpecialValueFor("duration")
    self.scepter_max_stack = ability:GetSpecialValueFor("scepter_max_stack")
end

function modifier_demi_human_fury:OnRefresh(params)
    local ability = self:GetAbility()
    self.chance = ability:GetSpecialValueFor("chance")
    self.duration = ability:GetSpecialValueFor("duration")
    self.scepter_max_stack = ability:GetSpecialValueFor("scepter_max_stack")
end

function modifier_demi_human_fury:OnDestroy()
    if IsServer() then
    end
end

function modifier_demi_human_fury:DeclareFunctions()
    return { MODIFIER_EVENT_ON_ATTACK }
end

function modifier_demi_human_fury:OnAttack(params)
    if not IsServer() then
        return
    end
    if params.attacker ~= self:GetParent() then
        return
    end
    local caster = self:GetParent()
    if RandomInt(1, 100) <= self.chance then
        PlayEffOnUnit(
            "particles/econ/items/huskar/huskar_2022_immortal/huskar_2022_immortal_life_break_spellstart.vpcf", caster)

        if not caster:HasModifier("modifier_demi_human_fury_buff") then
            EmitSoundOn("DOTA_Item.MaskOfMadness.Activate", caster)
        end
        local mod = caster:AddNewModifier(caster, self:GetAbility(), "modifier_demi_human_fury_buff", {
            duration = self.duration
        })
        if UTIL:HasScepter(caster) then
            if mod:GetStackCount() < self.scepter_max_stack then
                mod:IncrementStackCount()
            end
        else
            mod:SetStackCount(1)
        end
    end
end

---------------------------------------------------------------------
-- Modifiers
modifier_demi_human_fury_buff = class({
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
function modifier_demi_human_fury_buff:OnCreated(params)
    if not self:GetAbility() then return end
    if IsServer() then
    end
    local ability = self:GetAbility()
    self.attack_speed = ability:GetSpecialValueFor("attack_speed")
    --
end

function modifier_demi_human_fury_buff:OnRefresh(params)
    if not self:GetAbility() then return end
    if IsServer() then
    end
    self:OnCreated()
end

function modifier_demi_human_fury_buff:OnDestroy()
    if IsServer() then
    end
end

function modifier_demi_human_fury_buff:DeclareFunctions()
    return { MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE, MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
        MODIFIER_PROPERTY_MODEL_SCALE }
end

function modifier_demi_human_fury_buff:GetModifierModelScale()
    return 30
end

function modifier_demi_human_fury_buff:GetModifierAttackSpeedPercentage(params)
    return self.attack_speed * self:GetStackCount()
end

function modifier_demi_human_fury_buff:GetEffectName()
    return "particles/units/heroes/hero_ursa/ursa_enrage_buff_2.vpcf"
end

function modifier_demi_human_fury_buff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_demi_human_fury_buff:GetActivityTranslationModifiers()
    return "berserkers_blood"
end

-- function modifier_demi_human_fury_buff:AddEffects()
-- 	local particle_buff = "particles/units/heroes/hero_ursa/ursa_overpower_buff.vpcf"

-- 	self.effect_cast = ParticleManager:CreateParticle( particle_buff, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
-- 	ParticleManager:SetParticleControlEnt( self.effect_cast, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_head", self:GetParent():GetOrigin(), true)
-- 	ParticleManager:SetParticleControlEnt( self.effect_cast, 3, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetOrigin(), true)

-- 	self:AddParticle(
-- 		self.effect_cast,
-- 		false,
-- 		false,
-- 		-1,
-- 		false,
-- 		false
-- 	)
-- end
