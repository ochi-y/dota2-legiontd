LinkLuaModifier("modifier_goblin_chemical_rage_tranformation", 'ability/goblin_chemical_rage', 0)
LinkLuaModifier('modifier_goblin_chemical_rage', 'ability/goblin_chemical_rage', 0)

goblin_chemical_rage = class({})

function goblin_chemical_rage:OnSpellStart()
    self:GetCaster():Purge(false, true, false, false, false)
    self:GetCaster():AddNewModifier(self:GetCaster(),self,'modifier_goblin_chemical_rage_tranformation',{duration = self:GetSpecialValueFor('transformation_time')})


	EmitSoundOn('Hero_Alchemist.ChemicalRage.Cast', self:GetCaster())
end

modifier_goblin_chemical_rage_tranformation = class({
    IsHidden = function() return true end,
    CheckState = function() return {
        [MODIFIER_STATE_INVULNERABLE] = true
    } end
})

function modifier_goblin_chemical_rage_tranformation:IsPurgable(params)
    return false
end

if IsServer() then
    function modifier_goblin_chemical_rage_tranformation:OnCreated()
        if self:GetParent():GetUnitName() == "npc_dota_hero_alchemist" then
            self:GetParent():StartGesture(ACT_DOTA_ALCHEMIST_CHEMICAL_RAGE_START)
        end
    end

    function modifier_goblin_chemical_rage_tranformation:OnDestroy()
        local caster = self:GetCaster()
        if caster:HasModifier("modifier_goblin_chemical_rage") then
            caster:RemoveModifierByName("modifier_goblin_chemical_rage")
        end
        caster:AddNewModifier(caster, self:GetAbility(), "modifier_goblin_chemical_rage", {duration = self:GetAbility():GetSpecialValueFor("duration")})
    end
end


modifier_goblin_chemical_rage = class({
    IsHidden                = function() return false end,
    IsPurgable              = function() return false end,
    IsDebuff                = function() return false end,
    IsBuff                  = function() return true end,
    AllowIllusionDuplicate  = function() return true end,
    DeclareFunctions        = function() return {
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
        MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND
    } end,
    GetEffectName = function() return "particles/units/heroes/hero_alchemist/alchemist_chemical_rage.vpcf" end,
    GetEffectAttachType = function() return PATTACH_ABSORIGIN_FOLLOW end,
    GetStatusEffectName = function() return "particles/status_fx/status_effect_chemical_rage.vpcf" end,
    StatusEffectPriority = function() return 10 end,
    GetHeroEffectName = function() return "particles/units/heroes/hero_alchemist/alchemist_chemical_rage_hero_effect.vpcf" end,
    HeroEffectPriority = function() return 10 end,
    GetActivityTranslationModifiers = function() return "chemical_rage" end,
    GetAttackSound = function() return "Hero_Alchemist.ChemicalRage.Attack" end
})

function modifier_goblin_chemical_rage:OnCreated()
    if not self:GetAbility() then return end
    local ability = self:GetAbility()
    self.bonus_mana_regen = ability:GetSpecialValueFor("bonus_mana_regen")
    self.bonus_health_regen = ability:GetSpecialValueFor('bonus_health_regen')
    self.base_attack_time = ability:GetSpecialValueFor('base_attack_time')
    self.bonus_movespeed = ability:GetSpecialValueFor('bonus_movespeed')

	EmitSoundOn('Hero_Alchemist.ChemicalRage', self:GetParent())
end

function modifier_goblin_chemical_rage:OnDestroy()
    if IsServer() then
        if self:GetParent():GetUnitName() == "npc_dota_hero_alchemist" then
            self:GetParent():StartGesture(ACT_DOTA_ALCHEMIST_CHEMICAL_RAGE_END)
        end
		StopSoundOn('Hero_Alchemist.ChemicalRage', self:GetParent())
    end
end

function modifier_goblin_chemical_rage:GetModifierBaseManaRegen()
	return self.bonus_mana_regen
end

function modifier_goblin_chemical_rage:GetModifierConstantHealthRegen()
	return self.bonus_health_regen
end

function modifier_goblin_chemical_rage:GetModifierMoveSpeedBonus_Constant()
	return self.bonus_movespeed
end

function modifier_goblin_chemical_rage:GetModifierBaseAttackTimeConstant()
	return self.base_attack_time
end