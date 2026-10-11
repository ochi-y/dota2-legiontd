LinkLuaModifier( "modifier_ability_empty1", "ability/ability_empty1.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if ability_empty1 == nil then
	ability_empty1 = class({})
end
function ability_empty1:GetIntrinsicModifierName()
	return nil
end
