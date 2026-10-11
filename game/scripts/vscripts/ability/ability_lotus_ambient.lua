LinkLuaModifier( "modifier_ability_lotus_ambient", "ability/ability_lotus_ambient.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if ability_lotus_ambient == nil then
	ability_lotus_ambient = class({})
end
function ability_lotus_ambient:GetIntrinsicModifierName()
	return "modifier_ability_lotus_ambient"
end
---------------------------------------------------------------------
--Modifiers
if modifier_ability_lotus_ambient == nil then
	modifier_ability_lotus_ambient = class({})
end
function modifier_ability_lotus_ambient:OnCreated(params)
	if IsServer() then
	end
end
function modifier_ability_lotus_ambient:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_ability_lotus_ambient:OnDestroy()
	if IsServer() then
	end
end
function modifier_ability_lotus_ambient:DeclareFunctions()
	return {
	}
end

function modifier_ability_lotus_ambient:GetEffectName()
	return "particles/world_fountain_of_life/fol_ambient.vpcf"
end
function modifier_ability_lotus_ambient:GetEffectAttachType()
	return PATTACH_POINT_FOLLOW
end
