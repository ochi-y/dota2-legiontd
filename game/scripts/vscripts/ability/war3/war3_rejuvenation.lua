LinkLuaModifier( "modifier_war3_rejuvenation", "ability/war3/war3_rejuvenation.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if war3_rejuvenation == nil then
	war3_rejuvenation = class({})
end
function war3_rejuvenation:GetIntrinsicModifierName()
	return "modifier_war3_rejuvenation"
end
---------------------------------------------------------------------
--Modifiers
if modifier_war3_rejuvenation == nil then
	modifier_war3_rejuvenation = class({})
end
function modifier_war3_rejuvenation:OnCreated(params)
	if IsServer() then
	end
end
function modifier_war3_rejuvenation:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_war3_rejuvenation:OnDestroy()
	if IsServer() then
	end
end
function modifier_war3_rejuvenation:DeclareFunctions()
	return {
	}
end