
-------------------------------------------------------------------------------------------------------
modifier_ai_freeze = class({
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
function modifier_ai_freeze:AllowIllusionDuplicate()
    return false
end
function modifier_ai_freeze:OnCreated(params)
end
function modifier_ai_freeze:OnRefresh(params)
end
function modifier_ai_freeze:CheckState()
    return {
        [MODIFIER_STATE_STUNNED]=true
    }
end
