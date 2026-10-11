LinkLuaModifier( "modifier_shadow_frenzy", "ability/shadow_frenzy.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if shadow_frenzy == nil then
	shadow_frenzy = class({})
end
function shadow_frenzy:GetIntrinsicModifierName()
	return nil
end
---------------------------------------------------------------------
--Modifiers
if modifier_shadow_frenzy == nil then
	modifier_shadow_frenzy = class({})
end
function modifier_shadow_frenzy:IsHidden()
	return true
end
function modifier_shadow_frenzy:OnCreated(params)
	if IsServer() then
	end
end
function modifier_shadow_frenzy:IsPurgable(params)
	return false
end
function modifier_shadow_frenzy:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_shadow_frenzy:OnDestroy()
	if IsServer() then
	end
end
function modifier_shadow_frenzy:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
	}

end
function modifier_shadow_frenzy:GetModifierMoveSpeedBonus_Percentage()
	return 30
end
function modifier_shadow_frenzy:GetModifierConstantHealthRegen()
	return 5
end
