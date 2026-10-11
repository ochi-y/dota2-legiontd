modifier_modelscale_change = class({
IsHidden                = function(self) return true end,
IsPurgable              = function(self) return false end,
IsDebuff                = function(self) return false end,
IsBuff                  = function(self) return true end,
RemoveOnDeath           = function(self) return true end,
GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})

function modifier_modelscale_change:OnCreated(params)
    if not IsServer() then return end
    self.modelScale=params.modelScale
end

function modifier_modelscale_change:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MODEL_SCALE,
	}
	return funcs
end

function modifier_modelscale_change:GetModifierModelScale()
	if not IsServer() then return end
    return self.modelScale
end
