LinkLuaModifier( "modifier_sonic_wave", "heroes/queenofpain/sonic_wave.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if sonic_wave == nil then
	sonic_wave = class({})
end
function sonic_wave:GetIntrinsicModifierName()
	return "modifier_sonic_wave"
end
---------------------------------------------------------------------
--Modifiers
if modifier_sonic_wave == nil then
	modifier_sonic_wave = class({})
end
function modifier_sonic_wave:OnCreated(params)
	if IsServer() then
	end
end
function modifier_sonic_wave:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_sonic_wave:OnDestroy()
	if IsServer() then
	end
end
function modifier_sonic_wave:DeclareFunctions()
	return {
	}
end