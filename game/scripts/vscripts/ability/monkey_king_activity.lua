LinkLuaModifier( "modifier_monkey_king_activity", "ability/monkey_king_activity.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if monkey_king_activity == nil then
	monkey_king_activity = class({})
end
function monkey_king_activity:GetIntrinsicModifierName()
	return "modifier_monkey_king_activity"
end
---------------------------------------------------------------------
--Modifiers


modifier_monkey_king_activity = class({
IsHidden                = function(self) return true end,
IsPurgable              = function(self) return false end,
IsDebuff                = function(self) return false end,
IsBuff                  = function(self) return true end,
RemoveOnDeath           = function(self) return true end,
GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})

function modifier_monkey_king_activity:OnCreated(params)
	if IsServer() then
	end
end
function modifier_monkey_king_activity:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_monkey_king_activity:OnDestroy()
	if IsServer() then
	end
end
function modifier_monkey_king_activity:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS
	}
end
function modifier_monkey_king_activity:GetActivityTranslationModifiers( params )
	return "run"
end
