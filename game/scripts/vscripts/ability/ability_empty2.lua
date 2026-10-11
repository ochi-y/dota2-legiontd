LinkLuaModifier( "modifier_ability_empty2", "ability/ability_empty2.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if ability_empty2 == nil then
	ability_empty2 = class({})
end
function ability_empty2:GetIntrinsicModifierName()
	return nil
end
