LinkLuaModifier( "modifier_shadow_sven_ambient", "ability/shadow_sven_ambient.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if shadow_sven_ambient == nil then
	shadow_sven_ambient = class({})
end
function shadow_sven_ambient:GetIntrinsicModifierName()
	return "modifier_shadow_sven_ambient"
end
---------------------------------------------------------------------
--Modifiers
if modifier_shadow_sven_ambient == nil then
	modifier_shadow_sven_ambient = class({
		GetStatusEffectName     = function(self) return "particles/status_fx/status_effect_gods_strength.vpcf" end,
    	StatusEffectPriority    = function(self) return 10 end,
	})
end
function modifier_shadow_sven_ambient:IsPurgable(params)
	return false
end
function modifier_shadow_sven_ambient:IsHidden(params)
	return true
end
function modifier_shadow_sven_ambient:OnCreated(params)
	if IsServer() then
	end
end
function modifier_shadow_sven_ambient:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_shadow_sven_ambient:OnDestroy()
	if IsServer() then
	end
end
function modifier_shadow_sven_ambient:DeclareFunctions()
	return {
	}
end