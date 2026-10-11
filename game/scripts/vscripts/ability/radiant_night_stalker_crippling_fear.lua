LinkLuaModifier( "modifier_radiant_night_stalker_crippling_fear", "ability/radiant_night_stalker_crippling_fear.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if radiant_night_stalker_crippling_fear == nil then
	radiant_night_stalker_crippling_fear = class({})
end
function radiant_night_stalker_crippling_fear:GetIntrinsicModifierName()
	return "modifier_radiant_night_stalker_crippling_fear"
end
---------------------------------------------------------------------
--Modifiers
if modifier_radiant_night_stalker_crippling_fear == nil then
	modifier_radiant_night_stalker_crippling_fear = class({})
end
function modifier_radiant_night_stalker_crippling_fear:OnCreated(params)
	if IsServer() then
	end
end
function modifier_radiant_night_stalker_crippling_fear:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_radiant_night_stalker_crippling_fear:OnDestroy()
	if IsServer() then
	end
end
function modifier_radiant_night_stalker_crippling_fear:DeclareFunctions()
	return {
	}
end