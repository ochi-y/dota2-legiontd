LinkLuaModifier( "modifier_tb_effect", "ability/tb_effect.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if tb_effect == nil then
	tb_effect = class({})
end
function tb_effect:GetIntrinsicModifierName()
	return "modifier_tb_effect"
end
---------------------------------------------------------------------
--Modifiers

modifier_tb_effect = class({
IsHidden                = function(self) return true end,
IsPurgable              = function(self) return false end,
IsDebuff                = function(self) return false end,
IsBuff                  = function(self) return true end,
RemoveOnDeath           = function(self) return true end,
GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})
function modifier_tb_effect:OnCreated(params)
	if IsServer() then
	end
end
function modifier_tb_effect:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_tb_effect:OnDestroy()
	if IsServer() then
	end
end
function modifier_tb_effect:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND
	}
end
function modifier_tb_effect:GetEffectName()
	return "particles/units/heroes/hero_terrorblade/terrorblade_metamorphosis.vpcf"
end

function modifier_tb_effect:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_tb_effect:GetAttackSound()
	return "Hero_Terrorblade_Morphed.Attack"
end