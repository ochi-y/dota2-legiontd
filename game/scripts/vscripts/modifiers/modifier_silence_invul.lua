modifier_silence_invul = class({
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
        return false
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_NONE
    end
})

function modifier_silence_invul:OnCreated(params)
    if not IsServer() then
        return
    end
end

function modifier_silence_invul:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
    }
    return funcs
end

function modifier_silence_invul:GetModifierTotal_ConstantBlock()
    return self:GetParent():GetMaxHealth()
end

function modifier_silence_invul:CheckState()
    return {
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_SILENCED] = true,
        [MODIFIER_STATE_MUTED] = true,
    }
end
