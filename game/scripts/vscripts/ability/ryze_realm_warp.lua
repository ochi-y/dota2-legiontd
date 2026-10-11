LinkLuaModifier( "modifier_ryze_realm_warp", "ability/ryze_realm_warp.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if ryze_realm_warp == nil then
	ryze_realm_warp = class({})
end
function ryze_realm_warp:GetIntrinsicModifierName()
	return "modifier_ryze_realm_warp"
end
---------------------------------------------------------------------
--Modifiers
if modifier_ryze_realm_warp == nil then
	modifier_ryze_realm_warp = class({})
end
function modifier_ryze_realm_warp:OnCreated(params)
	if IsServer() then
	end
end
function modifier_ryze_realm_warp:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_ryze_realm_warp:OnDestroy()
	if IsServer() then
	end
end
function modifier_ryze_realm_warp:DeclareFunctions()
	return {
	}
end