LinkLuaModifier( "modifier_ability_empty6", "ability/ability_empty6.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if ability_empty6 == nil then
	ability_empty6 = class({})
end
function ability_empty6:GetIntrinsicModifierName()
	return nil
end
