LinkLuaModifier("modifier_demi_human_inject_steroids", "ability/demi_human_inject_steroids.lua",
    LUA_MODIFIER_MOTION_NONE)
-- Abilities
if demi_human_inject_steroids == nil then
    demi_human_inject_steroids = class({})
end


function demi_human_inject_steroids:Spawn()
    if not IsServer() then
        return
    end
    Timers:CreateTimer(FrameTime(),function ()
        local caster=self:GetCaster()
        local meta=GamePlay:FighterGetMeta(caster.fighterId)
        if meta then

            if meta.age==0 then
                if self:GetAutoCastState() then
                    self:ToggleAutoCast()    
                end    
            else
                if meta.abilityAutocastMap[self:GetAbilityName()]~=self:GetAutoCastState() then
                    self:ToggleAutoCast()
                end
            end
        end
    end)
end

-- function demi_human_inject_steroids:ToggleAutoCast()
--     print("toggle")
--     if not IsServer() then
--         return
--     end
--     local caster=self:GetCaster()
--    -- local res= self.BaseClass.ToggleAutoCast( self )
--     local meta=GamePlay:FighterGetMeta(caster.fighterId)
--     print("meta")
--     if meta then
--         meta.abilityAutocastMap[self:GetAbilityName()]=self:GetAutoCastState()
--         print("meta.abilityAutocastMap[self:GetAbilityName()]",meta.abilityAutocastMap[self:GetAbilityName()])
--     end
--     return self.BaseClass.ToggleAutoCast( self )
-- end

function demi_human_inject_steroids:OnAbilityPhaseStart()
	local caster = self:GetCaster()
    if caster:HasModifier("modifier_demi_human_inject_steroids") then
        SendErrorMessage(caster:GetPlayerOwnerID(), "demi_human_already_inject")
        return false
    end
    if teckTree:UseResource(caster, self) then
        return true
    end
    return false
end

function demi_human_inject_steroids:OnSpellStart()
    if not IsServer() then
        return
    end
    local caster = self:GetCaster()
    caster:AddNewModifier(caster, self, "modifier_demi_human_inject_steroids", {})



end
---------------------------------------------------------------------
-- Modifiers
modifier_demi_human_inject_steroids = class({
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
    end,
    GetAttackSound = function()
        return "Hero_Alchemist.ChemicalRage.Attack"
    end,
    GetActivityTranslationModifiers = function()
        return "chemical_rage"
    end,

    GetEffectName = function()
        return "particles/units/heroes/hero_alchemist/alchemist_chemical_rage.vpcf"
    end,
    GetEffectAttachType = function()
        return PATTACH_ABSORIGIN_FOLLOW
    end,
    GetStatusEffectName = function()
        return "particles/status_fx/status_effect_chemical_rage.vpcf"
    end,
    StatusEffectPriority = function()
        return 10
    end,
    GetHeroEffectName = function()
        return "particles/units/heroes/hero_alchemist/alchemist_chemical_rage_hero_effect.vpcf"
    end,
    HeroEffectPriority = function()
        return 10
    end

})
function modifier_demi_human_inject_steroids:OnCreated(params)

    local ability = self:GetAbility()
    self.bonus_damage = ability:GetSpecialValueFor("bonus_damage")
    self.bonus_health = ability:GetSpecialValueFor("bonus_health")
    self.attack_time = ability:GetSpecialValueFor("attack_time")

    if not IsServer() then
        return
    end
    local caster = self:GetParent()
    SimpleAddHealth(caster, math.ceil(caster:GetBaseMaxHealth() * self.bonus_health / 100))
    EmitSoundOn("Hero_Alchemist.ChemicalRage.Cast", self:GetParent())
end
function modifier_demi_human_inject_steroids:OnRefresh(params)
    if IsServer() then
    end
end
function modifier_demi_human_inject_steroids:OnDestroy()
    if IsServer() then
    end
end
function modifier_demi_human_inject_steroids:DeclareFunctions()
    return {MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE, MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
            MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS, MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND}
end

function modifier_demi_human_inject_steroids:GetModifierBaseAttackTimeConstant(params)
    return self.attack_time
end

function modifier_demi_human_inject_steroids:GetModifierBaseDamageOutgoing_Percentage(params)
    return self.bonus_damage
end
function modifier_demi_human_inject_steroids:GetTexture()
    return "alchemist_chemical_rage"
end
