LinkLuaModifier( "modifier_arctic_ice_ability/arctic_ice_path_1_1", "ability/arctic_ice_path_1.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if arctic_ice_ability/arctic_ice_path_1_1 == nil then
	arctic_ice_ability/arctic_ice_path_1_1 = class({})
end
function arctic_ice_ability/arctic_ice_path_1_1:GetIntrinsicModifierName()
	return "modifier_arctic_ice_ability/arctic_ice_path_1_1"
end
---------------------------------------------------------------------
--Modifiers
if modifier_arctic_ice_ability/arctic_ice_path_1_1 == nil then
	modifier_arctic_ice_ability/arctic_ice_path_1_1 = class({})
end
function modifier_arctic_ice_ability/arctic_ice_path_1_1:OnCreated(params)
	if IsServer() then
	end
end
function modifier_arctic_ice_ability/arctic_ice_path_1_1:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_arctic_ice_ability/arctic_ice_path_1_1:OnDestroy()
	if IsServer() then
	end
end
function modifier_arctic_ice_ability/arctic_ice_path_1_1:DeclareFunctions()
	return {
	}
end