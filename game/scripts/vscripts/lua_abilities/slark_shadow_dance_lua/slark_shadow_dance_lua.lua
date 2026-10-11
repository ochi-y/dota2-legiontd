LinkLuaModifier( "modifier_slark_shadow_dance_lua", "lua_abilities/slark_shadow_dance_lua/slark_shadow_dance_lua.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if slark_shadow_dance_lua == nil then
	slark_shadow_dance_lua = class({})
end
function slark_shadow_dance_lua:GetIntrinsicModifierName()
	return "modifier_slark_shadow_dance_lua"
end
---------------------------------------------------------------------
--Modifiers
if modifier_slark_shadow_dance_lua == nil then
	modifier_slark_shadow_dance_lua = class({})
end
function modifier_slark_shadow_dance_lua:OnCreated(params)
	if IsServer() then
	end
end
function modifier_slark_shadow_dance_lua:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_slark_shadow_dance_lua:OnDestroy()
	if IsServer() then
	end
end
function modifier_slark_shadow_dance_lua:DeclareFunctions()
	return {
	}
end