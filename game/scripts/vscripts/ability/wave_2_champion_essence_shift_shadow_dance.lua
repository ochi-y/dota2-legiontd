LinkLuaModifier( "modifier_wave_2_champion_essence_shift_shadow_dance", "ability/wave_2_champion_essence_shift_shadow_dance.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if wave_2_champion_essence_shift_shadow_dance == nil then
	wave_2_champion_essence_shift_shadow_dance = class({})
end
function wave_2_champion_essence_shift_shadow_dance:GetIntrinsicModifierName()
	return "modifier_wave_2_champion_essence_shift_shadow_dance"
end
---------------------------------------------------------------------
--Modifiers
if modifier_wave_2_champion_essence_shift_shadow_dance == nil then
	modifier_wave_2_champion_essence_shift_shadow_dance = class({})
end
function modifier_wave_2_champion_essence_shift_shadow_dance:OnCreated(params)
	if IsServer() then
	end
end
function modifier_wave_2_champion_essence_shift_shadow_dance:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_wave_2_champion_essence_shift_shadow_dance:OnDestroy()
	if IsServer() then
	end
end
function modifier_wave_2_champion_essence_shift_shadow_dance:DeclareFunctions()
	return {
	}
end