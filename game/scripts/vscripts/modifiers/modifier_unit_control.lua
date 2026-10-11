-------------------------------------------------------------------------------------------------------
modifier_unit_control = class({
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
        return MODIFIER_ATTRIBUTE_MULTIPLE
    end
})
function modifier_unit_control:AllowIllusionDuplicate()
    return false
end
function modifier_unit_control:OnCreated(params)
    if not IsServer() then
        return
    end
    -- self.damage = params.damage
    -- self:SetHasCustomTransmitterData(true) 
end
function modifier_unit_control:CheckState()
	local state = {
		[MODIFIER_STATE_DOMINATED] = true,
	}
	return state
end
