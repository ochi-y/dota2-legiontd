paladin_dragon_blood = {}

LinkLuaModifier( "modifier_paladin_dragon_blood", "ability/paladin_dragon_blood", LUA_MODIFIER_MOTION_NONE )

function paladin_dragon_blood:GetIntrinsicModifierName()
	return "modifier_paladin_dragon_blood"
end

modifier_paladin_dragon_blood = {}

function modifier_paladin_dragon_blood:IsHidden()
	return true
end

function modifier_paladin_dragon_blood:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}
end

function modifier_paladin_dragon_blood:GetModifierConstantHealthRegen()
	if not self:GetParent():PassivesDisabled() then
		return self:GetAbility():GetSpecialValueFor( "bonus_health_regen" )
	end
end

function modifier_paladin_dragon_blood:GetModifierPhysicalArmorBonus()
	if not self:GetParent():PassivesDisabled() then
		return self:GetAbility():GetSpecialValueFor( "bonus_armor" )
	end
end