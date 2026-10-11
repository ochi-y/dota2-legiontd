LinkLuaModifier( "modifier_radiant_purge_attack", "ability/radiant_purge_attack.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if radiant_purge_attack == nil then
	radiant_purge_attack = class({})
end
function radiant_purge_attack:GetIntrinsicModifierName()
	return "modifier_radiant_purge_attack"
end
---------------------------------------------------------------------
--Modifiers
if modifier_radiant_purge_attack == nil then
	modifier_radiant_purge_attack = class({})
end
function modifier_radiant_purge_attack:OnCreated(params)
	if IsServer() then
	end
end
function modifier_radiant_purge_attack:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_radiant_purge_attack:OnDestroy()
	if IsServer() then
	end
end
function modifier_radiant_purge_attack:DeclareFunctions()
	return {
	}
end