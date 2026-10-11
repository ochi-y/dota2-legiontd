LinkLuaModifier( "modifier_demi_human_motar", "ability/demi_human_motar.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if demi_human_motar == nil then
	demi_human_motar = class({})
end
function demi_human_motar:GetIntrinsicModifierName()
	return "modifier_demi_human_motar"
end
---------------------------------------------------------------------
--Modifiers
modifier_demi_human_motar = class({
	IsHidden                = function(self) return true end,
	IsPurgable              = function(self) return false end,
	IsDebuff                = function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath           = function(self) return true end,
	GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
	})
function modifier_demi_human_motar:OnCreated(params)
	if IsServer() then
	end
end
function modifier_demi_human_motar:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_demi_human_motar:OnDestroy()
	if IsServer() then
	end
end

function modifier_demi_human_motar:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end

function modifier_demi_human_motar:OnAttackLanded(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	local ability=self:GetAbility()
	local target = params.target
	local caster=self:GetParent()

	local damage=params.damage

	local splashData = {{
		radius = ability:GetSpecialValueFor("small_radius"),
		damage = ability:GetSpecialValueFor("small_damage_pct") * damage/100
	}, {
		radius = ability:GetSpecialValueFor("large_radius"),
		damage = ability:GetSpecialValueFor("large_radius_pct") * damage/100
	}}
	splashAttack(caster,target,splashData, ability,{groundOnly=true})
end

