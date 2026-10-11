LinkLuaModifier( "modifier_arctic_ice_spear", "buildinghelper/arctic_ice_spear.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if arctic_ice_spear == nil then
	arctic_ice_spear = class({})
end
function arctic_ice_spear:GetIntrinsicModifierName()
	return "modifier_arctic_ice_spear"
end
---------------------------------------------------------------------
--Modifiers
if modifier_arctic_ice_spear == nil then
	modifier_arctic_ice_spear = class({})
end
function modifier_arctic_ice_spear:OnCreated(params)
	if IsServer() then
	end
end
function modifier_arctic_ice_spear:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_arctic_ice_spear:OnDestroy()
	if IsServer() then
	end
end
function modifier_arctic_ice_spear:DeclareFunctions()
	return {
	}
end