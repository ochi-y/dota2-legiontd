LinkLuaModifier( "modifier_paladin_conscript", "ability/paladin_conscript.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if paladin_conscript == nil then
	paladin_conscript = class({})
end
function paladin_conscript:GetIntrinsicModifierName()
	return "modifier_paladin_conscript"
end
---------------------------------------------------------------------
--Modifiers
if modifier_paladin_conscript == nil then
	modifier_paladin_conscript = class({})
end
function modifier_paladin_conscript:OnCreated(params)
	if IsServer() then
	end
end
function modifier_paladin_conscript:IsPurgable(params)
	return false
end
function modifier_paladin_conscript:IsHidden(params)
	return true
end
function modifier_paladin_conscript:OnDestroy()
	if IsServer() then
	end
end
function modifier_paladin_conscript:DeclareFunctions()
	return {
	}
end