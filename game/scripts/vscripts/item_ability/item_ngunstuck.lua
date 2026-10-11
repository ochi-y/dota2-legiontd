LinkLuaModifier( "modifier_item_ngunstuck", "item_ability/item_ngunstuck.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if item_ngunstuck == nil then
	item_ngunstuck = class({})
end
function item_ngunstuck:GetIntrinsicModifierName()
	return "modifier_item_ngunstuck"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_ngunstuck == nil then
	modifier_item_ngunstuck = class({})
end
function modifier_item_ngunstuck:OnCreated(params)
	if IsServer() then
	end
end
function modifier_item_ngunstuck:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_item_ngunstuck:OnDestroy()
	if IsServer() then
	end
end
function modifier_item_ngunstuck:DeclareFunctions()
	return {
	}
end