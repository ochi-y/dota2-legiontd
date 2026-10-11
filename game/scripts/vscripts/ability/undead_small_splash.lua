LinkLuaModifier( "modifier_undead_small_splash", "ability/undead_small_splash.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if undead_small_splash == nil then
	undead_small_splash = class({})
end
function undead_small_splash:GetIntrinsicModifierName()
	return "modifier_undead_small_splash"
end
---------------------------------------------------------------------
--Modifiers
modifier_undead_small_splash = class({
	IsHidden                = function(self) return true end,
	IsPurgable              = function(self) return false end,
	IsDebuff                = function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath           = function(self) return true end,
	GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
	})
function modifier_undead_small_splash:OnCreated(params)
	if IsServer() then
	end
end
function modifier_undead_small_splash:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_undead_small_splash:OnDestroy()
	if IsServer() then
	end
end

function modifier_undead_small_splash:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end

function modifier_undead_small_splash:OnAttackLanded(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	local ability=self:GetAbility()
	local target = params.target
	local caster=self:GetParent()
	local damage=params.damage
	local splashData = {{
		radius = ability:GetSpecialValueFor("small_radius"),
		damage = ability:GetSpecialValueFor("small_damage_pct") * damage/100
	}}

	splashAttack(caster,target,splashData, ability,{groundOnly=true})
end

