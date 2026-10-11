LinkLuaModifier( "modifier_radiant_hp_aura", "ability/radiant_hp_aura.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if radiant_hp_aura == nil then
	radiant_hp_aura = class({})
end
function radiant_hp_aura:GetIntrinsicModifierName()
	return "modifier_radiant_hp_aura"
end
---------------------------------------------------------------------
--Modifiers
if modifier_radiant_hp_aura == nil then
	modifier_radiant_hp_aura = class({})
end
function modifier_radiant_hp_aura:OnCreated(params)
	if IsServer() then
	end
end
function modifier_radiant_hp_aura:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_radiant_hp_aura:OnDestroy()
	if IsServer() then
	end
end
function modifier_radiant_hp_aura:DeclareFunctions()
	return {
	}
end