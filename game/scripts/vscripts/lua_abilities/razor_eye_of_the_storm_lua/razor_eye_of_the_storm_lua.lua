LinkLuaModifier( "modifier_razor_eye_of_the_storm_lua", "lua_abilities/razor_eye_of_the_storm_lua/razor_eye_of_the_storm_lua.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if razor_eye_of_the_storm_lua == nil then
	razor_eye_of_the_storm_lua = class({})
end
function razor_eye_of_the_storm_lua:GetIntrinsicModifierName()
	return "modifier_razor_eye_of_the_storm_lua"
end
---------------------------------------------------------------------
--Modifiers
if modifier_razor_eye_of_the_storm_lua == nil then
	modifier_razor_eye_of_the_storm_lua = class({})
end
function modifier_razor_eye_of_the_storm_lua:OnCreated(params)
	if IsServer() then
	end
end
function modifier_razor_eye_of_the_storm_lua:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_razor_eye_of_the_storm_lua:OnDestroy()
	if IsServer() then
	end
end
function modifier_razor_eye_of_the_storm_lua:DeclareFunctions()
	return {
	}
end