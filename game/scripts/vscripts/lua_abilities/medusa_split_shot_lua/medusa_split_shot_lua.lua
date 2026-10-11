LinkLuaModifier( "modifier_medusa_split_shot_lua", "lua_abilities/medusa_split_shot_lua/medusa_split_shot_lua.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if medusa_split_shot_lua == nil then
	medusa_split_shot_lua = class({})
end
function medusa_split_shot_lua:GetIntrinsicModifierName()
	return "modifier_medusa_split_shot_lua"
end
---------------------------------------------------------------------
--Modifiers
if modifier_medusa_split_shot_lua == nil then
	modifier_medusa_split_shot_lua = class({})
end
function modifier_medusa_split_shot_lua:OnCreated(params)
	if IsServer() then
	end
end
function modifier_medusa_split_shot_lua:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_medusa_split_shot_lua:OnDestroy()
	if IsServer() then
	end
end
function modifier_medusa_split_shot_lua:DeclareFunctions()
	return {
	}
end