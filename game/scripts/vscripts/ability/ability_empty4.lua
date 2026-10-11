LinkLuaModifier( "modifier_ability_empty4", "ability/ability_empty4.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if ability_empty4 == nil then
	ability_empty4 = class({})
end
function ability_empty4:GetIntrinsicModifierName()
	return nil
end
