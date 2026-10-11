modifier_attack_speed = class({
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

function modifier_attack_speed:OnCreated(params)
    if not IsServer() then
        return
    end
    self.attackSpeed=params.attackSpeed
end

function modifier_attack_speed:DeclareFunctions()
    local funcs = {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
    return funcs
end

function modifier_attack_speed:GetModifierAttackSpeedBonus_Constant(params)
    return self.attackSpeed
end
