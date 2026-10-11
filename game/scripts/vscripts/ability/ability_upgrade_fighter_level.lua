LinkLuaModifier( "modifier_ability_upgrade_fighter_level", "ability/ability_upgrade_fighter_level.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if ability_upgrade_fighter_level == nil then
	ability_upgrade_fighter_level = class({})
end
function ability_upgrade_fighter_level:GetIntrinsicModifierName()
	return "modifier_ability_upgrade_fighter_level"
end
---------------------------------------------------------------------
--Modifiers
if modifier_ability_upgrade_fighter_level == nil then
	modifier_ability_upgrade_fighter_level = class({})
end
function modifier_ability_upgrade_fighter_level:OnCreated(params)
	if IsServer() then
	end
end
function modifier_ability_upgrade_fighter_level:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_ability_upgrade_fighter_level:OnDestroy()
	if IsServer() then
	end
end
function modifier_ability_upgrade_fighter_level:DeclareFunctions()
	return {
	}
end