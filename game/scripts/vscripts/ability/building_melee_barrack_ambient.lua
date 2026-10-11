LinkLuaModifier( "modifier_building_melee_barrack_ambient", "ability/building_melee_barrack_ambient.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if building_melee_barrack_ambient == nil then
	building_melee_barrack_ambient = class({})
end
function building_melee_barrack_ambient:GetIntrinsicModifierName()
	return "modifier_building_melee_barrack_ambient"
end
---------------------------------------------------------------------
--Modifiers
if modifier_building_melee_barrack_ambient == nil then
	modifier_building_melee_barrack_ambient = class({})
end
function modifier_building_melee_barrack_ambient:OnCreated(params)
	if IsServer() then
	end
end
function modifier_building_melee_barrack_ambient:IsHidden(params)
	return true
end
function modifier_building_melee_barrack_ambient:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_building_melee_barrack_ambient:OnDestroy()
	if IsServer() then
	end
end
function modifier_building_melee_barrack_ambient:DeclareFunctions()
	return {
	}
end
function modifier_building_melee_barrack_ambient:GetEffectName()
	return "particles/radiant_fx/good_barracks_melee001_amb.vpcf"
end
function modifier_building_melee_barrack_ambient:GetEffectAttachType()
	return PATTACH_POINT_FOLLOW
end

