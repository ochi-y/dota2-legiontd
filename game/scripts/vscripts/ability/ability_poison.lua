LinkLuaModifier( "modifier_ability_poison", "ability/ability_poison.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if ability_poison == nil then
	ability_poison = class({})
end
function ability_poison:GetIntrinsicModifierName()
	return "modifier_ability_poison"
end
---------------------------------------------------------------------
--Modifiers
if modifier_ability_poison == nil then
	modifier_ability_poison = class({})
end
function modifier_ability_poison:OnCreated(params)
	if IsServer() then
	end
end
function modifier_ability_poison:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_ability_poison:OnDestroy()
	if IsServer() then
	end
end
function modifier_ability_poison:DeclareFunctions()
	return {
	}
end