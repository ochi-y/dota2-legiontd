LinkLuaModifier( "modifier_night_stalker_void", "ability/night_stalker_void.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if night_stalker_void == nil then
	night_stalker_void = class({})
end
function night_stalker_void:GetIntrinsicModifierName()
	return "modifier_night_stalker_void"
end
---------------------------------------------------------------------
--Modifiers
if modifier_night_stalker_void == nil then
	modifier_night_stalker_void = class({})
end
function modifier_night_stalker_void:OnCreated(params)
	if IsServer() then
	end
end
function modifier_night_stalker_void:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_night_stalker_void:OnDestroy()
	if IsServer() then
	end
end
function modifier_night_stalker_void:DeclareFunctions()
	return {
	}
end