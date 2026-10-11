LinkLuaModifier( "modifier_mech_tiny_astral_order_ambient", "ability/mech_tiny_astral_order_ambient.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if mech_tiny_astral_order_ambient == nil then
	mech_tiny_astral_order_ambient = class({})
end
function mech_tiny_astral_order_ambient:GetIntrinsicModifierName()
	return "modifier_mech_tiny_astral_order_ambient"
end
---------------------------------------------------------------------
--Modifiers
if modifier_mech_tiny_astral_order_ambient == nil then
	modifier_mech_tiny_astral_order_ambient = class({})
end
function modifier_mech_tiny_astral_order_ambient:OnCreated(params)
	if IsServer() then
	end
end
function modifier_mech_tiny_astral_order_ambient:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_mech_tiny_astral_order_ambient:OnDestroy()
	if IsServer() then
	end
end
function modifier_mech_tiny_astral_order_ambient:DeclareFunctions()
	return {
	}
end
function modifier_mech_tiny_astral_order_ambient:GetEffectName()
	return "particles/econ/items/tiny/tiny_astral_order/tiny_astral_order_shoulder_ambient.vpcf"
end
function modifier_mech_tiny_astral_order_ambient:GetEffectAttachType()
	return PATTACH_POINT_FOLLOW
end
