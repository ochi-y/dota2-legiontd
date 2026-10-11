LinkLuaModifier( "modifier_abilityreturn", "ability/abilityreturn.lua.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if abilityreturn == nil then
	abilityreturn = class({})
end
function abilityreturn:GetIntrinsicModifierName()
	return "modifier_abilityreturn"
end
---------------------------------------------------------------------
--Modifiers
if modifier_abilityreturn == nil then
	modifier_abilityreturn = class({})
end
function modifier_abilityreturn:OnCreated(params)
	if IsServer() then
	end
end
function modifier_abilityreturn:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_abilityreturn:OnDestroy()
	if IsServer() then
	end
end
function modifier_abilityreturn:DeclareFunctions()
	return {
	}
end