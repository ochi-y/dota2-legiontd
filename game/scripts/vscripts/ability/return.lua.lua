LinkLuaModifier( "modifier_return", "ability/return.lua.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if return == nil then
	return = class({})
end
function return:GetIntrinsicModifierName()
	return "modifier_return"
end
---------------------------------------------------------------------
--Modifiers
if modifier_return == nil then
	modifier_return = class({})
end
function modifier_return:OnCreated(params)
	if IsServer() then
	end
end
function modifier_return:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_return:OnDestroy()
	if IsServer() then
	end
end
function modifier_return:DeclareFunctions()
	return {
	}
end