LinkLuaModifier( "modifier_upgrade_farm_x2", "ability/upgrade_farm_x2.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if upgrade_farm_x2 == nil then
	upgrade_farm_x2 = class({})
end
function upgrade_farm_x2:GetIntrinsicModifierName()
	return "modifier_upgrade_farm_x2"
end
---------------------------------------------------------------------
--Modifiers
if modifier_upgrade_farm_x2 == nil then
	modifier_upgrade_farm_x2 = class({})
end
function modifier_upgrade_farm_x2:OnCreated(params)
	if IsServer() then
	end
end
function modifier_upgrade_farm_x2:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_upgrade_farm_x2:OnDestroy()
	if IsServer() then
	end
end
function modifier_upgrade_farm_x2:DeclareFunctions()
	return {
	}
end