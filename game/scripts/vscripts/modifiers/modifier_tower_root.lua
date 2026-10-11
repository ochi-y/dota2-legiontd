-------------------------------------------------------------------------------------------------------
modifier_tower_root = class({
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
function modifier_tower_root:AllowIllusionDuplicate()
    return false
end


function modifier_tower_root:GetTexture()
	return "alpha_wolf_command_aura"
end


function modifier_tower_root:OnCreated(params)
    -- self.damage = params.damage
    -- self:SetHasCustomTransmitterData(true) 
end

function modifier_tower_root:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_DISABLE_TURNING,
        MODIFIER_PROPERTY_MOVESPEED_LIMIT
    }
    return funcs
end

function modifier_tower_root:GetModifierDisableTurning( params )
	return true
end
function modifier_tower_root:GetModifierMoveSpeed_Limit( params )
	return 0
end

function modifier_tower_root:CheckState()
    return {
        [MODIFIER_STATE_ROOTED]=true
    }
end
