LinkLuaModifier( "modifier_builder", "builder.lua.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if builder == nil then
	builder = class({})
end
function builder:GetIntrinsicModifierName()
	return "modifier_builder"
end
---------------------------------------------------------------------
--Modifiers
if modifier_builder == nil then
	modifier_builder = class({})
end
function modifier_builder:OnCreated(params)
	if IsServer() then
	end
end
function modifier_builder:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_builder:OnDestroy()
	if IsServer() then
	end
end
function modifier_builder:DeclareFunctions()
	return {
	}
end