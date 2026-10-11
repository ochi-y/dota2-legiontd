LinkLuaModifier( "modifier_war3_flame_strike", "ability/war3/war3_flame_strike.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if war3_flame_strike == nil then
	war3_flame_strike = class({})
end
function war3_flame_strike:GetIntrinsicModifierName()
	return "modifier_war3_flame_strike"
end
---------------------------------------------------------------------
--Modifiers
if modifier_war3_flame_strike == nil then
	modifier_war3_flame_strike = class({})
end
function modifier_war3_flame_strike:OnCreated(params)
	if IsServer() then
	end
end
function modifier_war3_flame_strike:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_war3_flame_strike:OnDestroy()
	if IsServer() then
	end
end
function modifier_war3_flame_strike:DeclareFunctions()
	return {
	}
end