LinkLuaModifier( "modifier_war3_mana_burn", "ability/war3/war3_mana_burn.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if war3_mana_burn == nil then
	war3_mana_burn = class({})
end
function war3_mana_burn:GetIntrinsicModifierName()
	return "modifier_war3_mana_burn"
end
---------------------------------------------------------------------
--Modifiers
if modifier_war3_mana_burn == nil then
	modifier_war3_mana_burn = class({})
end
function modifier_war3_mana_burn:OnCreated(params)
	if IsServer() then
	end
end
function modifier_war3_mana_burn:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_war3_mana_burn:OnDestroy()
	if IsServer() then
	end
end
function modifier_war3_mana_burn:DeclareFunctions()
	return {
	}
end