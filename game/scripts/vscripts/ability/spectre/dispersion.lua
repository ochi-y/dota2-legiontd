LinkLuaModifier( "modifier_dispersion", "ability/spectre/dispersion.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if dispersion == nil then
	dispersion = class({})
end
function dispersion:GetIntrinsicModifierName()
	return "modifier_dispersion"
end
---------------------------------------------------------------------
--Modifiers
if modifier_dispersion == nil then
	modifier_dispersion = class({})
end
function modifier_dispersion:OnCreated(params)
	if IsServer() then
	end
end
function modifier_dispersion:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_dispersion:OnDestroy()
	if IsServer() then
	end
end
function modifier_dispersion:DeclareFunctions()
	return {
	}
end