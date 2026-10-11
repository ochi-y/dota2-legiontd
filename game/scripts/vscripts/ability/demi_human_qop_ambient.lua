LinkLuaModifier( "modifier_demi_human_qop_ambient", "ability/demi_human_qop_ambient.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if demi_human_qop_ambient == nil then
	demi_human_qop_ambient = class({})
end
function demi_human_qop_ambient:GetIntrinsicModifierName()
	return "modifier_demi_human_qop_ambient"
end
---------------------------------------------------------------------
--Modifiers
if modifier_demi_human_qop_ambient == nil then
	modifier_demi_human_qop_ambient = class({})
end
function modifier_demi_human_qop_ambient:IsHidden(params)
	return true
end
function modifier_demi_human_qop_ambient:OnCreated(params)
	if IsServer() then
	end
end
function modifier_demi_human_qop_ambient:IsPurgable(params)
	return false
end
function modifier_demi_human_qop_ambient:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_demi_human_qop_ambient:OnDestroy()
	if IsServer() then
	end
end
function modifier_demi_human_qop_ambient:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS
	}
end
function modifier_demi_human_qop_ambient:GetActivityTranslationModifiers()
    return "qop_arc"
end
