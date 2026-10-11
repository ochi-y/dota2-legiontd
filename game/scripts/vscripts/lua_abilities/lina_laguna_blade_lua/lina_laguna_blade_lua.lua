LinkLuaModifier( "modifier_lina_laguna_blade_lua", "lua_abilities/lina_laguna_blade_lua/lina_laguna_blade_lua.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if lina_laguna_blade_lua == nil then
	lina_laguna_blade_lua = class({})
end
function lina_laguna_blade_lua:GetIntrinsicModifierName()
	return "modifier_lina_laguna_blade_lua"
end
---------------------------------------------------------------------
--Modifiers
if modifier_lina_laguna_blade_lua == nil then
	modifier_lina_laguna_blade_lua = class({})
end
function modifier_lina_laguna_blade_lua:OnCreated(params)
	if IsServer() then
	end
end
function modifier_lina_laguna_blade_lua:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_lina_laguna_blade_lua:OnDestroy()
	if IsServer() then
	end
end
function modifier_lina_laguna_blade_lua:DeclareFunctions()
	return {
	}
end