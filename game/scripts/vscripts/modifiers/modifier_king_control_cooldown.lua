-------------------------------------------------------------------------------------------------------
modifier_king_control_cooldown = class({
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
function modifier_king_control_cooldown:AllowIllusionDuplicate()
    return false
end
function modifier_king_control_cooldown:OnCreated(params)
    if not IsServer() then
        return
    end
end

function modifier_king_control_cooldown:GetTexture(params)
    return "action_attackmove"
end




