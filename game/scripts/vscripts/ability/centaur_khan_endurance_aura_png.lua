LinkLuaModifier( "modifier_centaur_khan_endurance_aura_png", "ability/centaur_khan_endurance_aura_png.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if centaur_khan_endurance_aura_png == nil then
	centaur_khan_endurance_aura_png = class({})
end
function centaur_khan_endurance_aura_png:GetIntrinsicModifierName()
	return "modifier_centaur_khan_endurance_aura_png"
end
---------------------------------------------------------------------
--Modifiers
if modifier_centaur_khan_endurance_aura_png == nil then
	modifier_centaur_khan_endurance_aura_png = class({})
end
function modifier_centaur_khan_endurance_aura_png:OnCreated(params)
	if IsServer() then
	end
end
function modifier_centaur_khan_endurance_aura_png:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_centaur_khan_endurance_aura_png:OnDestroy()
	if IsServer() then
	end
end
function modifier_centaur_khan_endurance_aura_png:DeclareFunctions()
	return {
	}
end