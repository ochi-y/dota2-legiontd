LinkLuaModifier( "modifier_healthbar_pips", "ability/healthbar_pips.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if healthbar_pips == nil then
	healthbar_pips = class({})
end
function healthbar_pips:GetIntrinsicModifierName()
	return "modifier_healthbar_pips"
end
---------------------------------------------------------------------
--Modifiers
-------------------------------------------------------------------------------------------------------
modifier_healthbar_pips = class({
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
function modifier_healthbar_pips:AllowIllusionDuplicate()
	return false
end
function modifier_healthbar_pips:OnCreated(params)
end
function modifier_healthbar_pips:OnRefresh(params)
	self:OnCreated(params)
end
function modifier_healthbar_pips:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTHBAR_PIPS 
	}
end
function modifier_healthbar_pips:GetModifierHealthBarPips()
	return 4
end

function modifier_healthbar_pips:CheckState()
	local state = {
	}

	return state
end
