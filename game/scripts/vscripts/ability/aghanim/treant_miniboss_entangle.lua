LinkLuaModifier( "modifier_treant_miniboss_entangle", "ability/aghanim/treant_miniboss_entangle.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if treant_miniboss_entangle == nil then
	treant_miniboss_entangle = class({})
end
function treant_miniboss_entangle:GetIntrinsicModifierName()
	return "modifier_treant_miniboss_entangle"
end
---------------------------------------------------------------------
--Modifiers
if modifier_treant_miniboss_entangle == nil then
	modifier_treant_miniboss_entangle = class({})
end
function modifier_treant_miniboss_entangle:OnCreated(params)
	if IsServer() then
	end
end
function modifier_treant_miniboss_entangle:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_treant_miniboss_entangle:OnDestroy()
	if IsServer() then
	end
end
function modifier_treant_miniboss_entangle:DeclareFunctions()
	return {
	}
end