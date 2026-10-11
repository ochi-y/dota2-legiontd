LinkLuaModifier( "modifier_shadow_dance", "ability/shadow_dance.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if shadow_dance == nil then
	shadow_dance = class({})
end
function shadow_dance:GetIntrinsicModifierName()
	return "modifier_shadow_dance"
end
---------------------------------------------------------------------
--Modifiers
if modifier_shadow_dance == nil then
	modifier_shadow_dance = class({})
end
function modifier_shadow_dance:OnCreated(params)
	if IsServer() then
	end
end
function modifier_shadow_dance:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_shadow_dance:OnDestroy()
	if IsServer() then
	end
end
function modifier_shadow_dance:DeclareFunctions()
	return {
	}
end