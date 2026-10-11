LinkLuaModifier( "modifier_elemeny_ice_wall", "ability/elemeny_ice_wall.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if elemeny_ice_wall == nil then
	elemeny_ice_wall = class({})
end
function elemeny_ice_wall:GetIntrinsicModifierName()
	return "modifier_elemeny_ice_wall"
end
---------------------------------------------------------------------
--Modifiers
if modifier_elemeny_ice_wall == nil then
	modifier_elemeny_ice_wall = class({})
end
function modifier_elemeny_ice_wall:OnCreated(params)
	if IsServer() then
	end
end
function modifier_elemeny_ice_wall:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_elemeny_ice_wall:OnDestroy()
	if IsServer() then
	end
end
function modifier_elemeny_ice_wall:DeclareFunctions()
	return {
	}
end