LinkLuaModifier( "modifier_item_fengzhizhang", "item_ability/item_fengzhizhang.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if item_fengzhizhang == nil then
	item_fengzhizhang = class({})
end
function item_fengzhizhang:GetIntrinsicModifierName()
	return "modifier_item_fengzhizhang"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_fengzhizhang == nil then
	modifier_item_fengzhizhang = class({})
end
function modifier_item_fengzhizhang:OnCreated(params)
	if IsServer() then
	end
end
function modifier_item_fengzhizhang:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_item_fengzhizhang:OnDestroy()
	if IsServer() then
	end
end
function modifier_item_fengzhizhang:DeclareFunctions()
	return {
	}
end