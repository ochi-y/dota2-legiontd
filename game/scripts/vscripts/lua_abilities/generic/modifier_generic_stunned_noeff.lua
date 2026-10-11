ximodifier_generic_stunned_noeff = class({})

--------------------------------------------------------------------------------
-- Classifications
function ximodifier_generic_stunned_noeff:IsDebuff()
	return true
end

function ximodifier_generic_stunned_noeff:IsStunDebuff()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function ximodifier_generic_stunned_noeff:OnCreated( kv )
	if not IsServer() then return end
end

function ximodifier_generic_stunned_noeff:OnRefresh( kv )
	self:OnCreated( kv )
end

function ximodifier_generic_stunned_noeff:OnRemoved()
end

function ximodifier_generic_stunned_noeff:OnDestroy()
end

--------------------------------------------------------------------------------
-- Status Effects
function ximodifier_generic_stunned_noeff:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
	}

	return state
end

--------------------------------------------------------------------------------
-- Modifier Effects
function ximodifier_generic_stunned_noeff:DeclareFunctions()
	local funcs = {
	}
	return funcs
end
