LinkLuaModifier( "modifier_radiant_kez_shodo_sai", "ability/radiant_kez_shodo_sai.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if radiant_kez_shodo_sai == nil then
	radiant_kez_shodo_sai = class({})
end
function radiant_kez_shodo_sai:GetIntrinsicModifierName()
	return "modifier_radiant_kez_shodo_sai"
end
---------------------------------------------------------------------
--Modifiers
if modifier_radiant_kez_shodo_sai == nil then
	modifier_radiant_kez_shodo_sai = class({})
end
function modifier_radiant_kez_shodo_sai:OnCreated(params)
	if IsServer() then
	end
end
function modifier_radiant_kez_shodo_sai:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_radiant_kez_shodo_sai:OnDestroy()
	if IsServer() then
	end
end
function modifier_radiant_kez_shodo_sai:DeclareFunctions()
	return {
	}
end