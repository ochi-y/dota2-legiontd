LinkLuaModifier( "modifier_impale", "ability/nyx_assassin/impale.lua.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if impale == nil then
	impale = class({})
end
function impale:GetIntrinsicModifierName()
	return "modifier_impale"
end
---------------------------------------------------------------------
--Modifiers
if modifier_impale == nil then
	modifier_impale = class({})
end
function modifier_impale:OnCreated(params)
	if IsServer() then
	end
end
function modifier_impale:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_impale:OnDestroy()
	if IsServer() then
	end
end
function modifier_impale:DeclareFunctions()
	return {
	}
end