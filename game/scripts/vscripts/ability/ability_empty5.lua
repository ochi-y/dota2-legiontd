LinkLuaModifier( "modifier_ability_empty5", "ability/ability_empty5.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if ability_empty5 == nil then
	ability_empty5 = class({})
end
function ability_empty5:GetIntrinsicModifierName()
	return nil
end
