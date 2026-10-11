LinkLuaModifier( "modifier_big_thunder_lizard_frenzy_png", "ability/big_thunder_lizard_frenzy_png.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if big_thunder_lizard_frenzy_png == nil then
	big_thunder_lizard_frenzy_png = class({})
end
function big_thunder_lizard_frenzy_png:GetIntrinsicModifierName()
	return "modifier_big_thunder_lizard_frenzy_png"
end
---------------------------------------------------------------------
--Modifiers
if modifier_big_thunder_lizard_frenzy_png == nil then
	modifier_big_thunder_lizard_frenzy_png = class({})
end
function modifier_big_thunder_lizard_frenzy_png:OnCreated(params)
	if IsServer() then
	end
end
function modifier_big_thunder_lizard_frenzy_png:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_big_thunder_lizard_frenzy_png:OnDestroy()
	if IsServer() then
	end
end
function modifier_big_thunder_lizard_frenzy_png:DeclareFunctions()
	return {
	}
end