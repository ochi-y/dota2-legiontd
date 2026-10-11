LinkLuaModifier( "modifier_ability_paralyzing_cask", "ability/ability_paralyzing_cask.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if ability_paralyzing_cask == nil then
	ability_paralyzing_cask = class({})
end
function ability_paralyzing_cask:GetIntrinsicModifierName()
	return "modifier_ability_paralyzing_cask"
end
---------------------------------------------------------------------
--Modifiers
if modifier_ability_paralyzing_cask == nil then
	modifier_ability_paralyzing_cask = class({})
end
function modifier_ability_paralyzing_cask:OnCreated(params)
	if IsServer() then
	end
end
function modifier_ability_paralyzing_cask:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_ability_paralyzing_cask:OnDestroy()
	if IsServer() then
	end
end
function modifier_ability_paralyzing_cask:DeclareFunctions()
	return {
	}
end