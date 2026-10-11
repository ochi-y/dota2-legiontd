LinkLuaModifier( "modifier_bane_nightmare_lua", "lua_abilities/bane_nightmare_lua/bane_nightmare_lua.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if bane_nightmare_lua == nil then
	bane_nightmare_lua = class({})
end
function bane_nightmare_lua:GetIntrinsicModifierName()
	return "modifier_bane_nightmare_lua"
end
---------------------------------------------------------------------
--Modifiers
if modifier_bane_nightmare_lua == nil then
	modifier_bane_nightmare_lua = class({})
end
function modifier_bane_nightmare_lua:OnCreated(params)
	if IsServer() then
	end
end
function modifier_bane_nightmare_lua:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_bane_nightmare_lua:OnDestroy()
	if IsServer() then
	end
end
function modifier_bane_nightmare_lua:DeclareFunctions()
	return {
	}
end