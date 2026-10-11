
modifier_provides_fow_position = class({
IsDebuff                = function(self) return false end,
IsBuff                  = function(self) return true end,
RemoveOnDeath           = function(self) return true end,
GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_MULTIPLE end,
})

function modifier_provides_fow_position:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_provides_fow_position:IsPurgable()
	return false
end
--------------------------------------------------------------------------------
function modifier_provides_fow_position:CheckState()
	local state = {
		[MODIFIER_STATE_PROVIDES_VISION] = true
	}
	return state
end

function modifier_provides_fow_position:DeclareFunctions()
	local funcs =
	{
		MODIFIER_PROPERTY_PROVIDES_FOW_POSITION,
	}

	return funcs
end

--------------------------------------------------------------------------------

function modifier_provides_fow_position:GetModifierProvidesFOWVision( params )
	return 1
end

--------------------------------------------------------------------------------
