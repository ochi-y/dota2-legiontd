LinkLuaModifier( "modifier_wave_2_champion_essence_shift", "ability/wave_2_champion_essence_shift.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if wave_2_champion_essence_shift == nil then
	wave_2_champion_essence_shift = class({})
end
function wave_2_champion_essence_shift:GetIntrinsicModifierName()
	return "modifier_wave_2_champion_essence_shift"
end
---------------------------------------------------------------------
--Modifiers
if modifier_wave_2_champion_essence_shift == nil then
	modifier_wave_2_champion_essence_shift = class({})
end
function modifier_wave_2_champion_essence_shift:OnCreated(params)
	if IsServer() then
	end
end
function modifier_wave_2_champion_essence_shift:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_wave_2_champion_essence_shift:OnDestroy()
	if IsServer() then
	end
end
function modifier_wave_2_champion_essence_shift:DeclareFunctions()
	return {
	}
end