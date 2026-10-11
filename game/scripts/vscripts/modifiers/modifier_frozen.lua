modifier_frozen = class({
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

function modifier_frozen:OnCreated(params)
    if not IsServer() then
        return
    end
end

function modifier_frozen:DeclareFunctions()
    local funcs = {}
    return funcs
end

function modifier_frozen:CheckState()
    return {
        -- [MODIFIER_STATE_FROZEN] = true,
    }
end
