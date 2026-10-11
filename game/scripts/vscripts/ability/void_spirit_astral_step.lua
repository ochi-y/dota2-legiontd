LinkLuaModifier( "modifier_void_spirit_astral_step", "ability/void_spirit_astral_step.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if void_spirit_astral_step == nil then
	void_spirit_astral_step = class({})
end
function void_spirit_astral_step:GetIntrinsicModifierName()
	return "modifier_void_spirit_astral_step"
end
---------------------------------------------------------------------
--Modifiers
if modifier_void_spirit_astral_step == nil then
	modifier_void_spirit_astral_step = class({})
end
function modifier_void_spirit_astral_step:OnCreated(params)
	if IsServer() then
	end
end
function modifier_void_spirit_astral_step:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_void_spirit_astral_step:OnDestroy()
	if IsServer() then
	end
end
function modifier_void_spirit_astral_step:DeclareFunctions()
	return {
	}
end