LinkLuaModifier( "modifier_upgrade_farm_1", "ability/upgrade_farm_1.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if upgrade_farm_1 == nil then
	upgrade_farm_1 = class({})
end
function upgrade_farm_1:GetIntrinsicModifierName()
	return "modifier_upgrade_farm_1"
end
---------------------------------------------------------------------
--Modifiers
if modifier_upgrade_farm_1 == nil then
	modifier_upgrade_farm_1 = class({})
end
function modifier_upgrade_farm_1:OnCreated(params)
	if IsServer() then
	end
end
function modifier_upgrade_farm_1:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_upgrade_farm_1:OnDestroy()
	if IsServer() then
	end
end
function modifier_upgrade_farm_1:DeclareFunctions()
	return {
	}
end