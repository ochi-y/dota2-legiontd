LinkLuaModifier( "modifier_war3_devour_magic", "ability/war3_devour_magic.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if war3_devour_magic == nil then
	war3_devour_magic = class({})
end
function war3_devour_magic:GetIntrinsicModifierName()
	return "modifier_war3_devour_magic"
end
---------------------------------------------------------------------
--Modifiers
if modifier_war3_devour_magic == nil then
	modifier_war3_devour_magic = class({})
end
function modifier_war3_devour_magic:OnCreated(params)
	if IsServer() then
	end
end
function modifier_war3_devour_magic:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_war3_devour_magic:OnDestroy()
	if IsServer() then
	end
end
function modifier_war3_devour_magic:DeclareFunctions()
	return {
	}
end