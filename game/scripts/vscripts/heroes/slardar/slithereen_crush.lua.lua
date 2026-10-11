LinkLuaModifier( "modifier_slithereen_crush", "heroes/slardar/slithereen_crush.lua.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if slithereen_crush == nil then
	slithereen_crush = class({})
end
function slithereen_crush:GetIntrinsicModifierName()
	return "modifier_slithereen_crush"
end
---------------------------------------------------------------------
--Modifiers
if modifier_slithereen_crush == nil then
	modifier_slithereen_crush = class({})
end
function modifier_slithereen_crush:OnCreated(params)
	if IsServer() then
	end
end
function modifier_slithereen_crush:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_slithereen_crush:OnDestroy()
	if IsServer() then
	end
end
function modifier_slithereen_crush:DeclareFunctions()
	return {
	}
end