LinkLuaModifier( "modifier_vengefulspirit_command_aura", "ability/vengefulspirit_command_aura.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if vengefulspirit_command_aura == nil then
	vengefulspirit_command_aura = class({})
end
function vengefulspirit_command_aura:GetIntrinsicModifierName()
	return "modifier_vengefulspirit_command_aura"
end
---------------------------------------------------------------------
--Modifiers
if modifier_vengefulspirit_command_aura == nil then
	modifier_vengefulspirit_command_aura = class({})
end
function modifier_vengefulspirit_command_aura:OnCreated(params)
	if IsServer() then
	end
end
function modifier_vengefulspirit_command_aura:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_vengefulspirit_command_aura:OnDestroy()
	if IsServer() then
	end
end
function modifier_vengefulspirit_command_aura:DeclareFunctions()
	return {
	}
end