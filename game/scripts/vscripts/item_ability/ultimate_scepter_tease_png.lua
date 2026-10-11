LinkLuaModifier( "modifier_ultimate_scepter_tease_png", "item_ability/ultimate_scepter_tease_png.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if ultimate_scepter_tease_png == nil then
	ultimate_scepter_tease_png = class({})
end
function ultimate_scepter_tease_png:GetIntrinsicModifierName()
	return "modifier_ultimate_scepter_tease_png"
end
---------------------------------------------------------------------
--Modifiers
if modifier_ultimate_scepter_tease_png == nil then
	modifier_ultimate_scepter_tease_png = class({})
end
function modifier_ultimate_scepter_tease_png:OnCreated(params)
	if IsServer() then
	end
end
function modifier_ultimate_scepter_tease_png:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_ultimate_scepter_tease_png:OnDestroy()
	if IsServer() then
	end
end
function modifier_ultimate_scepter_tease_png:DeclareFunctions()
	return {
	}
end