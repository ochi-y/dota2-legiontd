LinkLuaModifier( "modifier_arctic_super_power", "ability/arctic_super_power.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if arctic_super_power == nil then
	arctic_super_power = class({})
end
function arctic_super_power:GetIntrinsicModifierName()
	return "modifier_arctic_super_power"
end
---------------------------------------------------------------------
--Modifiers
if modifier_arctic_super_power == nil then
	modifier_arctic_super_power = class({})
end
function modifier_arctic_super_power:OnCreated(params)
	if IsServer() then
	end
end
function modifier_arctic_super_power:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_arctic_super_power:OnDestroy()
	if IsServer() then
	end
end
function modifier_arctic_super_power:DeclareFunctions()
	return {
	}
end