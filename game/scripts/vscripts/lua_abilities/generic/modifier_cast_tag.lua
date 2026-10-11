modifier_cast_tag = class({
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
        return false
    end,
    RemoveOnDeath = function(self)
        return true
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_MULTIPLE
    end
})
function modifier_cast_tag:AllowIllusionDuplicate()
    return false
end
function modifier_cast_tag:OnCreated(params)
end
function modifier_cast_tag:OnRefresh(params)
end
function modifier_cast_tag:DeclareFunctions()
    return {
    }
end
