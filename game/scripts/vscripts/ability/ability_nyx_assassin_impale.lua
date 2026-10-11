LinkLuaModifier( "modifier_ability_nyx_assassin_impale", "ability/ability_nyx_assassin_impale.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if ability_nyx_assassin_impale == nil then
	ability_nyx_assassin_impale = class({})
end
function ability_nyx_assassin_impale:GetIntrinsicModifierName()
	return "modifier_ability_nyx_assassin_impale"
end
---------------------------------------------------------------------
--Modifiers
if modifier_ability_nyx_assassin_impale == nil then
	modifier_ability_nyx_assassin_impale = class({})
end
function modifier_ability_nyx_assassin_impale:OnCreated(params)
	if IsServer() then
	end
end
function modifier_ability_nyx_assassin_impale:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_ability_nyx_assassin_impale:OnDestroy()
	if IsServer() then
	end
end
function modifier_ability_nyx_assassin_impale:DeclareFunctions()
	return {
	}
end