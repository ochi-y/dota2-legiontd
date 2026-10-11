modifier_towerhide = class({
IsHidden                = function(self) return true end,
IsPurgable              = function(self) return false end,
IsDebuff                = function(self) return false end,
IsBuff                  = function(self) return true end,
RemoveOnDeath           = function(self) return true end,
GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})

function modifier_towerhide:OnCreated(params)
    if not IsServer() then return end
end

function modifier_towerhide:DeclareFunctions()
	local funcs = {
		MODIFIER_STATE_OUT_OF_GAME,
	}
	return funcs
end
function modifier_towerhide:GetModifierModelChange()
    if not IsServer() then return end
    return self.model
end
