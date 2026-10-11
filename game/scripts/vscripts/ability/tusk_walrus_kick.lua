LinkLuaModifier( "modifier_tusk_walrus_kick", "ability/tusk_walrus_kick.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if tusk_walrus_kick == nil then
	tusk_walrus_kick = class({})
end
function tusk_walrus_kick:GetIntrinsicModifierName()
	return "modifier_tusk_walrus_kick"
end
---------------------------------------------------------------------
--Modifiers
if modifier_tusk_walrus_kick == nil then
	modifier_tusk_walrus_kick = class({})
end
function modifier_tusk_walrus_kick:OnCreated(params)
	if IsServer() then
	end
end
function modifier_tusk_walrus_kick:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_tusk_walrus_kick:OnDestroy()
	if IsServer() then
	end
end
function modifier_tusk_walrus_kick:DeclareFunctions()
	return {
	}
end