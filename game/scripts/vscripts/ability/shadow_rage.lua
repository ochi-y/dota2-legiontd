LinkLuaModifier( "modifier_shadow_rage", "ability/shadow_rage.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if shadow_rage == nil then
	shadow_rage = class({})
end
function shadow_rage:GetIntrinsicModifierName()
	return "modifier_shadow_rage"
end
---------------------------------------------------------------------
--Modifiers
if modifier_shadow_rage == nil then
	modifier_shadow_rage = class({})
end
function modifier_shadow_rage:OnCreated(params)
	if IsServer() then
	end
end
function modifier_shadow_rage:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_shadow_rage:OnDestroy()
	if IsServer() then
	end
end
function modifier_shadow_rage:DeclareFunctions()
	return {
	}
end