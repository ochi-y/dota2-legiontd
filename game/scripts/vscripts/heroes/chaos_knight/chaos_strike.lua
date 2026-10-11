LinkLuaModifier( "modifier_chaos_strike", "heroes/chaos_knight/chaos_strike.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if chaos_strike == nil then
	chaos_strike = class({})
end
function chaos_strike:GetIntrinsicModifierName()
	return "modifier_chaos_strike"
end
---------------------------------------------------------------------
--Modifiers
if modifier_chaos_strike == nil then
	modifier_chaos_strike = class({})
end
function modifier_chaos_strike:OnCreated(params)
	if IsServer() then
	end
end
function modifier_chaos_strike:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_chaos_strike:OnDestroy()
	if IsServer() then
	end
end
function modifier_chaos_strike:DeclareFunctions()
	return {
	}
end