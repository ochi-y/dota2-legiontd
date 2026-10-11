LinkLuaModifier( "modifier_dearadiant_juggernaut_healing_wardh_spawn", "ability/dearadiant_juggernaut_healing_wardh_spawn.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if dearadiant_juggernaut_healing_wardh_spawn == nil then
	dearadiant_juggernaut_healing_wardh_spawn = class({})
end
function dearadiant_juggernaut_healing_wardh_spawn:GetIntrinsicModifierName()
	return "modifier_dearadiant_juggernaut_healing_wardh_spawn"
end
---------------------------------------------------------------------
--Modifiers
if modifier_dearadiant_juggernaut_healing_wardh_spawn == nil then
	modifier_dearadiant_juggernaut_healing_wardh_spawn = class({})
end
function modifier_dearadiant_juggernaut_healing_wardh_spawn:OnCreated(params)
	if IsServer() then
	end
end
function modifier_dearadiant_juggernaut_healing_wardh_spawn:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_dearadiant_juggernaut_healing_wardh_spawn:OnDestroy()
	if IsServer() then
	end
end
function modifier_dearadiant_juggernaut_healing_wardh_spawn:DeclareFunctions()
	return {
	}
end