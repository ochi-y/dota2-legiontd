LinkLuaModifier( "modifier_paladin", "ability/paladin.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if paladin == nil then
	paladin = class({})
end
function paladin:GetIntrinsicModifierName()
	return "modifier_paladin"
end
---------------------------------------------------------------------
--Modifiers
if modifier_paladin == nil then
	modifier_paladin = class({})
end
function modifier_paladin:OnCreated(params)
	if IsServer() then
	end
end
function modifier_paladin:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_paladin:OnDestroy()
	if IsServer() then
	end
end
function modifier_paladin:DeclareFunctions()
	return {
	}
end