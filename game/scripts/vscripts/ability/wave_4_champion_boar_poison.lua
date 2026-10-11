LinkLuaModifier( "modifier_wave_4_champion_boar_poison", "ability/wave_4_champion_boar_poison.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if wave_4_champion_boar_poison == nil then
	wave_4_champion_boar_poison = class({})
end
function wave_4_champion_boar_poison:GetIntrinsicModifierName()
	return "modifier_wave_4_champion_boar_poison"
end
---------------------------------------------------------------------
--Modifiers
if modifier_wave_4_champion_boar_poison == nil then
	modifier_wave_4_champion_boar_poison = class({})
end
function modifier_wave_4_champion_boar_poison:OnCreated(params)
	if IsServer() then
	end
end
function modifier_wave_4_champion_boar_poison:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_wave_4_champion_boar_poison:OnDestroy()
	if IsServer() then
	end
end
function modifier_wave_4_champion_boar_poison:DeclareFunctions()
	return {
	}
end