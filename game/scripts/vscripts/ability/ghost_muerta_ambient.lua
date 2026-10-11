LinkLuaModifier( "modifier_ghost_muerta_ambient", "ability/ghost_muerta_ambient.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if ghost_muerta_ambient == nil then
	ghost_muerta_ambient = class({})
end
function ghost_muerta_ambient:GetIntrinsicModifierName()
	return "modifier_ghost_muerta_ambient"
end
---------------------------------------------------------------------
--Modifiers
-------------------------------------------------------------------------------------------------------
modifier_ghost_muerta_ambient = class({
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
function modifier_ghost_muerta_ambient:AllowIllusionDuplicate()
	return false
end
function modifier_ghost_muerta_ambient:OnCreated(params)
end
function modifier_ghost_muerta_ambient:OnRefresh(params)
	self:OnCreated(params)
end
function modifier_ghost_muerta_ambient:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS
	}
end
function modifier_ghost_muerta_ambient:GetActivityTranslationModifiers(params)
    return "faster"
end
