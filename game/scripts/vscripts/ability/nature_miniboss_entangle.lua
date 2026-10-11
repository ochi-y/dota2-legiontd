LinkLuaModifier( "modifier_nature_miniboss_entangle", "ability/nature_miniboss_entangle.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if nature_miniboss_entangle == nil then
	nature_miniboss_entangle = class({})
end
function nature_miniboss_entangle:GetIntrinsicModifierName()
	return "modifier_nature_miniboss_entangle"
end
---------------------------------------------------------------------
--Modifiers
if modifier_nature_miniboss_entangle == nil then
	modifier_nature_miniboss_entangle = class({})
end
function modifier_nature_miniboss_entangle:OnCreated(params)
	if IsServer() then
	end
end
function modifier_nature_miniboss_entangle:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_nature_miniboss_entangle:OnDestroy()
	if IsServer() then
	end
end
function modifier_nature_miniboss_entangle:DeclareFunctions()
	return {
	}
end