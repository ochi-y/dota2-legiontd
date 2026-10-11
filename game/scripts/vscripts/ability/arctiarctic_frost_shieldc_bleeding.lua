LinkLuaModifier( "modifier_arctiarctic_frost_shieldc_bleeding", "ability/arctiarctic_frost_shieldc_bleeding.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if arctiarctic_frost_shieldc_bleeding == nil then
	arctiarctic_frost_shieldc_bleeding = class({})
end
function arctiarctic_frost_shieldc_bleeding:GetIntrinsicModifierName()
	return "modifier_arctiarctic_frost_shieldc_bleeding"
end
---------------------------------------------------------------------
--Modifiers
if modifier_arctiarctic_frost_shieldc_bleeding == nil then
	modifier_arctiarctic_frost_shieldc_bleeding = class({})
end
function modifier_arctiarctic_frost_shieldc_bleeding:OnCreated(params)
	if IsServer() then
	end
end
function modifier_arctiarctic_frost_shieldc_bleeding:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_arctiarctic_frost_shieldc_bleeding:OnDestroy()
	if IsServer() then
	end
end
function modifier_arctiarctic_frost_shieldc_bleeding:DeclareFunctions()
	return {
	}
end