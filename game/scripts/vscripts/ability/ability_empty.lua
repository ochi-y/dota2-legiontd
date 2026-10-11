LinkLuaModifier( "modifier_ability_empty", "ability/ability_empty.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if ability_empty == nil then
	ability_empty = class({})
end
function ability_empty:GetIntrinsicModifierName()
	return nil
end
