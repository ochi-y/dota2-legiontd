LinkLuaModifier( "modifier_ability_return", "ability/ability_return.lua.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if ability_return == nil then
	ability_return = class({})
end
function ability_return:GetIntrinsicModifierName()
	return "modifier_ability_return"
end
---------------------------------------------------------------------
--Modifiers
if modifier_ability_return == nil then
	modifier_ability_return = class({})
end
function modifier_ability_return:OnCreated(params)
	if IsServer() then
	end
end
function modifier_ability_return:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_ability_return:OnDestroy()
	if IsServer() then
	end
end
function modifier_ability_return:DeclareFunctions()
	return {
	}
end