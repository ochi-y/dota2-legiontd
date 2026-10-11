LinkLuaModifier( "modifier_fury_swipes", "heroes/ursa/fury_swipes.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if fury_swipes == nil then
	fury_swipes = class({})
end
function fury_swipes:GetIntrinsicModifierName()
	return "modifier_fury_swipes"
end
---------------------------------------------------------------------
--Modifiers
if modifier_fury_swipes == nil then
	modifier_fury_swipes = class({})
end
function modifier_fury_swipes:OnCreated(params)
	if IsServer() then
	end
end
function modifier_fury_swipes:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_fury_swipes:OnDestroy()
	if IsServer() then
	end
end
function modifier_fury_swipes:DeclareFunctions()
	return {
	}
end