LinkLuaModifier( "modifier_item_pwnage", "item_ability/item_pwnage.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if item_pwnage == nil then
	item_pwnage = class({})
end
function item_pwnage:GetIntrinsicModifierName()
	return "modifier_item_pwnage"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_pwnage == nil then
	modifier_item_pwnage = class({})
end
function modifier_item_pwnage:OnCreated(params)
	if IsServer() then
	end
end
function modifier_item_pwnage:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_item_pwnage:OnDestroy()
	if IsServer() then
	end
end
function modifier_item_pwnage:DeclareFunctions()
	return {
	}
end