LinkLuaModifier( "modifier_orc_fiorc_berserknish_blow", "ability/orc_fiorc_berserknish_blow.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if orc_fiorc_berserknish_blow == nil then
	orc_fiorc_berserknish_blow = class({})
end
function orc_fiorc_berserknish_blow:GetIntrinsicModifierName()
	return "modifier_orc_fiorc_berserknish_blow"
end
---------------------------------------------------------------------
--Modifiers
if modifier_orc_fiorc_berserknish_blow == nil then
	modifier_orc_fiorc_berserknish_blow = class({})
end
function modifier_orc_fiorc_berserknish_blow:OnCreated(params)
	if IsServer() then
	end
end
function modifier_orc_fiorc_berserknish_blow:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_orc_fiorc_berserknish_blow:OnDestroy()
	if IsServer() then
	end
end
function modifier_orc_fiorc_berserknish_blow:DeclareFunctions()
	return {
	}
end