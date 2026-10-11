LinkLuaModifier( "modifier_farm_tp", "ability/farm_tp.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if farm_tp == nil then
	farm_tp = class({})
end
function farm_tp:OnSpellStart()

	GamePlay:tryTp(self:GetCaster():GetPlayerOwnerID())

end
