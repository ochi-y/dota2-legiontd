LinkLuaModifier( "modifier_war3_mass_teleport", "ability/war3/war3_mass_teleport.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if war3_mass_teleport == nil then
	war3_mass_teleport = class({})
end
function war3_mass_teleport:GetIntrinsicModifierName()
	return "modifier_war3_mass_teleport"
end
---------------------------------------------------------------------
--Modifiers
if modifier_war3_mass_teleport == nil then
	modifier_war3_mass_teleport = class({})
end
function modifier_war3_mass_teleport:OnCreated(params)
	if IsServer() then
	end
end
function modifier_war3_mass_teleport:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_war3_mass_teleport:OnDestroy()
	if IsServer() then
	end
end
function modifier_war3_mass_teleport:DeclareFunctions()
	return {
	}
end