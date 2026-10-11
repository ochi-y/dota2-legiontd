LinkLuaModifier( "modifier_dazzle_shadow_wave_lua", "lua_abilities/dazzle_shadow_wave_lua/dazzle_shadow_wave_lua.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if dazzle_shadow_wave_lua == nil then
	dazzle_shadow_wave_lua = class({})
end
function dazzle_shadow_wave_lua:GetIntrinsicModifierName()
	return "modifier_dazzle_shadow_wave_lua"
end
---------------------------------------------------------------------
--Modifiers
if modifier_dazzle_shadow_wave_lua == nil then
	modifier_dazzle_shadow_wave_lua = class({})
end
function modifier_dazzle_shadow_wave_lua:OnCreated(params)
	if IsServer() then
	end
end
function modifier_dazzle_shadow_wave_lua:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_dazzle_shadow_wave_lua:OnDestroy()
	if IsServer() then
	end
end
function modifier_dazzle_shadow_wave_lua:DeclareFunctions()
	return {
	}
end