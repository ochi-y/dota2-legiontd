LinkLuaModifier( "modifier_wave_6_hawk_dive", "ability/wave_6_hawk_dive.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if wave_6_hawk_dive == nil then
	wave_6_hawk_dive = class({})
end
function wave_6_hawk_dive:GetIntrinsicModifierName()
	return "modifier_wave_6_hawk_dive"
end
---------------------------------------------------------------------
--Modifiers
if modifier_wave_6_hawk_dive == nil then
	modifier_wave_6_hawk_dive = class({})
end
function modifier_wave_6_hawk_dive:OnCreated(params)
	if IsServer() then
	end
end
function modifier_wave_6_hawk_dive:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_wave_6_hawk_dive:OnDestroy()
	if IsServer() then
	end
end
function modifier_wave_6_hawk_dive:DeclareFunctions()
	return {
	}
end