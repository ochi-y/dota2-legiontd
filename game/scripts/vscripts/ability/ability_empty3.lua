LinkLuaModifier( "modifier_ability_empty3", "ability/ability_empty3.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if ability_empty3 == nil then
	ability_empty3 = class({})
end
function ability_empty3:GetIntrinsicModifierName()
	return nil
end
