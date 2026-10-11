LinkLuaModifier( "modifier_viper_corrosive_skin_lua", "lua_abilities/viper_corrosive_skin_lua/viper_corrosive_skin_lua.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if viper_corrosive_skin_lua == nil then
	viper_corrosive_skin_lua = class({})
end
function viper_corrosive_skin_lua:GetIntrinsicModifierName()
	return "modifier_viper_corrosive_skin_lua"
end
---------------------------------------------------------------------
--Modifiers
if modifier_viper_corrosive_skin_lua == nil then
	modifier_viper_corrosive_skin_lua = class({})
end
function modifier_viper_corrosive_skin_lua:OnCreated(params)
	if IsServer() then
	end
end
function modifier_viper_corrosive_skin_lua:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_viper_corrosive_skin_lua:OnDestroy()
	if IsServer() then
	end
end
function modifier_viper_corrosive_skin_lua:DeclareFunctions()
	return {
	}
end