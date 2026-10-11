LinkLuaModifier( "modifier_clinkz_death_pact", "ability/clinkz_death_pact.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if clinkz_death_pact == nil then
	clinkz_death_pact = class({})
end
function clinkz_death_pact:GetIntrinsicModifierName()
	return "modifier_clinkz_death_pact"
end
---------------------------------------------------------------------
--Modifiers
if modifier_clinkz_death_pact == nil then
	modifier_clinkz_death_pact = class({})
end
function modifier_clinkz_death_pact:OnCreated(params)
	if IsServer() then
	end
end
function modifier_clinkz_death_pact:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_clinkz_death_pact:OnDestroy()
	if IsServer() then
	end
end
function modifier_clinkz_death_pact:DeclareFunctions()
	return {
	}
end