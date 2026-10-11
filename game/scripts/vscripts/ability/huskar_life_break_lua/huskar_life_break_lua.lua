LinkLuaModifier( "modifier_huskar_life_break_lua", "ability/huskar_life_break_lua/huskar_life_break_lua.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if huskar_life_break_lua == nil then
	huskar_life_break_lua = class({})
end
function huskar_life_break_lua:GetIntrinsicModifierName()
	return "modifier_huskar_life_break_lua"
end
---------------------------------------------------------------------
--Modifiers
if modifier_huskar_life_break_lua == nil then
	modifier_huskar_life_break_lua = class({})
end
function modifier_huskar_life_break_lua:OnCreated(params)
	if IsServer() then
	end
end
function modifier_huskar_life_break_lua:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_huskar_life_break_lua:OnDestroy()
	if IsServer() then
	end
end
function modifier_huskar_life_break_lua:DeclareFunctions()
	return {
	}
end