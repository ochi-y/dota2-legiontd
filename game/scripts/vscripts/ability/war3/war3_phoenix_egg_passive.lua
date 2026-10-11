LinkLuaModifier( "modifier_war3_phoenix_egg_passive", "ability/war3/war3_phoenix_egg_passive.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if war3_phoenix_egg_passive == nil then
	war3_phoenix_egg_passive = class({})
end
function war3_phoenix_egg_passive:GetIntrinsicModifierName()
	return "modifier_war3_phoenix_egg_passive"
end
---------------------------------------------------------------------
--Modifiers
if modifier_war3_phoenix_egg_passive == nil then
	modifier_war3_phoenix_egg_passive = class({})
end
function modifier_war3_phoenix_egg_passive:OnCreated(params)
	if IsServer() then
	end
end
function modifier_war3_phoenix_egg_passive:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_war3_phoenix_egg_passive:OnDestroy()
	if IsServer() then
	end
end
function modifier_war3_phoenix_egg_passive:DeclareFunctions()
	return {
	}
end