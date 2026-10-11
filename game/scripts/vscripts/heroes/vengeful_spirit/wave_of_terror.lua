LinkLuaModifier( "modifier_wave_of_terror", "heroes/vengeful_spirit/wave_of_terror.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if wave_of_terror == nil then
	wave_of_terror = class({})
end
function wave_of_terror:GetIntrinsicModifierName()
	return "modifier_wave_of_terror"
end
---------------------------------------------------------------------
--Modifiers
if modifier_wave_of_terror == nil then
	modifier_wave_of_terror = class({})
end
function modifier_wave_of_terror:OnCreated(params)
	if IsServer() then
	end
end
function modifier_wave_of_terror:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_wave_of_terror:OnDestroy()
	if IsServer() then
	end
end
function modifier_wave_of_terror:DeclareFunctions()
	return {
	}
end