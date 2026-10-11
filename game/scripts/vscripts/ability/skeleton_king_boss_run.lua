LinkLuaModifier( "modifier_skeleton_king_boss_run", "ability/skeleton_king_boss_run.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if skeleton_king_boss_run == nil then
	skeleton_king_boss_run = class({})
end
function skeleton_king_boss_run:GetIntrinsicModifierName()
	return "modifier_skeleton_king_boss_run"
end
---------------------------------------------------------------------
--Modifiers
modifier_skeleton_king_boss_run = class({
IsHidden                = function(self) return true end,
IsPurgable              = function(self) return false end,
IsDebuff                = function(self) return false end,
IsBuff                  = function(self) return true end,
RemoveOnDeath           = function(self) return true end,
GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})

function modifier_skeleton_king_boss_run:OnCreated(params)
	if IsServer() then
	end
end
function modifier_skeleton_king_boss_run:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_skeleton_king_boss_run:OnDestroy()
	if IsServer() then
	end
end
function modifier_skeleton_king_boss_run:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS
	}
end
function modifier_skeleton_king_boss_run:GetActivityTranslationModifiers( params )
	return "run"
end
