LinkLuaModifier( "modifier_ability_tree_grap", "ability/ability_tree_grap.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if ability_tree_grap == nil then
	ability_tree_grap = class({})
end
function ability_tree_grap:GetIntrinsicModifierName()
	return "modifier_ability_tree_grap"
end
---------------------------------------------------------------------
--Modifiers
if modifier_ability_tree_grap == nil then
	modifier_ability_tree_grap = class({})
end
function modifier_ability_tree_grap:OnCreated(params)
	if IsServer() then
	end
end
function modifier_ability_tree_grap:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_ability_tree_grap:OnDestroy()
	if IsServer() then
	end
end
function modifier_ability_tree_grap:DeclareFunctions()
	return {
	}
end