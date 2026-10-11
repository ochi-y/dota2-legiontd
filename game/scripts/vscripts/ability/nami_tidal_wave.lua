LinkLuaModifier( "modifier_nami_tidal_wave", "ability/nami_tidal_wave.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if nami_tidal_wave == nil then
	nami_tidal_wave = class({})
end
function nami_tidal_wave:GetIntrinsicModifierName()
	return "modifier_nami_tidal_wave"
end
---------------------------------------------------------------------
--Modifiers
if modifier_nami_tidal_wave == nil then
	modifier_nami_tidal_wave = class({})
end
function modifier_nami_tidal_wave:OnCreated(params)
	if IsServer() then
	end
end
function modifier_nami_tidal_wave:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_nami_tidal_wave:OnDestroy()
	if IsServer() then
	end
end
function modifier_nami_tidal_wave:DeclareFunctions()
	return {
	}
end