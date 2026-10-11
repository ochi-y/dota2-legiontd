LinkLuaModifier("modifier_marine_poison_attack_slow", "ability/marine_poison_attack", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_generic_orb_effect_lua", "lua_abilities/generic/modifier_generic_orb_effect_lua",
    LUA_MODIFIER_MOTION_NONE)

if marine_poison_attack == nil then
    marine_poison_attack = class({})
end

function marine_poison_attack:Spawn()
    if not IsServer() then return end
    self:ToggleAutoCast()
end

function marine_poison_attack:GetIntrinsicModifierName()
    return "modifier_generic_orb_effect_lua"
end

function marine_poison_attack:GetProjectileName()
    return "particles/units/heroes/hero_viper/viper_poison_attack.vpcf"
end

function marine_poison_attack:OnOrbFire(params)
    local sound_cast = "hero_viper.poisonAttack.Cast"
    EmitSoundOn(sound_cast, self:GetCaster())
end

function marine_poison_attack:OnOrbImpact(params)
    local duration = self:GetSpecialValueFor("duration")

    local modif = params.target:AddNewModifier(self:GetCaster(), self, "modifier_marine_poison_attack_slow",
        { duration = duration })
    modif:SetStackCount(modif:GetStackCount() + 1)

    local sound_cast = "hero_viper.poisonAttack.Target"
    EmitSoundOn(sound_cast, params.target)
end

--------------------------------------------------------------------------------
modifier_marine_poison_attack_slow = class({
    IsHidden            = function(self) return false end,
    IsPurgable          = function(self) return true end,
    IsPurgeException    = function(self) return true end,
    IsDebuff            = function(self) return true end,
    IsBuff              = function(self) return false end,
    RemoveOnDeath       = function(self) return true end,
    DeclareFunctions    = function(self)
        return {
            MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
           -- MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
        }
    end,
    GetEffectName       = function(self) return "particles/units/heroes/hero_viper/viper_poison_debuff.vpcf" end,
    GetEffectAttachType = function(self) return PATTACH_ABSORIGIN_FOLLOW end,
})


--------------------------------------------------------------------------------

function modifier_marine_poison_attack_slow:OnCreated()
    self.damage = self:GetAbility():GetSpecialValueFor("damage")

    self.movement_speed = self:GetAbility():GetSpecialValueFor("movement_speed") * (-1)
    self.magic_resistance = self:GetAbility():GetSpecialValueFor("magic_resistance") * (-1)
    self.max_stacks = self:GetAbility():GetSpecialValueFor("max_stacks")

    self:StartIntervalThink(1)
end

function modifier_marine_poison_attack_slow:OnRefresh()
    self.damage = self:GetAbility():GetSpecialValueFor("damage")
    self.movement_speed = self:GetAbility():GetSpecialValueFor("movement_speed") * (-1)
    self.magic_resistance = self:GetAbility():GetSpecialValueFor("magic_resistance") * (-1)
    self.max_stacks = self:GetAbility():GetSpecialValueFor("max_stacks")

    if self:GetStackCount() > self.max_stacks then
        self:SetStackCount(self.max_stacks)
    end
end

if IsServer() then
    function modifier_marine_poison_attack_slow:OnIntervalThink()
        local damage = self.damage * self:GetStackCount()

        ApplyDamage({
            victim = self:GetParent(),
            attacker = self:GetCaster(),
            damage = damage,
            damage_type = self:GetAbility():GetAbilityDamageType(),
            ability = self:GetAbility()
        })

        SendOverheadEventMessage(self:GetParent(), OVERHEAD_ALERT_BONUS_POISON_DAMAGE, self:GetParent(), damage, nil)
    end
end

function modifier_marine_poison_attack_slow:GetModifierMoveSpeedBonus_Percentage() return self.movement_speed *
    self:GetStackCount() end

function modifier_marine_poison_attack_slow:GetModifierMagicalResistanceBonus() return self.magic_resistance *
    self:GetStackCount() end
