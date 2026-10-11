LinkLuaModifier( "modifier_tinker_laser_lua", "lua_abilities/tinker_laser_lua/tinker_laser_lua.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if tinker_laser_lua == nil then
	tinker_laser_lua = class({})
end
function tinker_laser_lua:GetIntrinsicModifierName()
	return "modifier_tinker_laser_lua"
end
---------------------------------------------------------------------
--Modifiers
if modifier_tinker_laser_lua == nil then
	modifier_tinker_laser_lua = class({})
end
function modifier_tinker_laser_lua:OnCreated(params)
	if IsServer() then
	end
end
function modifier_tinker_laser_lua:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_tinker_laser_lua:OnDestroy()
	if IsServer() then
	end
end
function modifier_tinker_laser_lua:DeclareFunctions()
	return {
	}
end