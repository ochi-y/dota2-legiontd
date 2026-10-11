LinkLuaModifier( "modifier_demi_inject_steroids", "ability/demi_inject_steroids.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if demi_inject_steroids == nil then
	demi_inject_steroids = class({})
end
function demi_inject_steroids:GetIntrinsicModifierName()
	return "modifier_demi_inject_steroids"
end
---------------------------------------------------------------------
--Modifiers
if modifier_demi_inject_steroids == nil then
	modifier_demi_inject_steroids = class({})
end
function modifier_demi_inject_steroids:OnCreated(params)
	if IsServer() then
	end
end
function modifier_demi_inject_steroids:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_demi_inject_steroids:OnDestroy()
	if IsServer() then
	end
end
function modifier_demi_inject_steroids:DeclareFunctions()
	return {
	}
end