modifier_model_change = class({
IsHidden                = function(self) return true end,
IsPurgable              = function(self) return false end,
IsDebuff                = function(self) return false end,
IsBuff                  = function(self) return true end,
RemoveOnDeath           = function(self) return true end,
GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})

function modifier_model_change:OnCreated(params)
    if not IsServer() then return end
    self.model=params.model
end

function modifier_model_change:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MODEL_CHANGE,
	}
	return funcs
end
function modifier_model_change:GetModifierModelChange()
    if not IsServer() then return end
    return self.model
end
