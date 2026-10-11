LinkLuaModifier("modifier_beast_azure_breath", "ability/beast_azure_breath.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if beast_azure_breath == nil then
	beast_azure_breath = class({})
end
function beast_azure_breath:GetIntrinsicModifierName()
	return "modifier_beast_azure_breath"
end

---------------------------------------------------------------------
--Modifiers
modifier_beast_azure_breath = class({
	IsHidden      = function(self) return true end,
	IsPurgable    = function(self) return false end,
	IsDebuff      = function(self) return false end,
	IsBuff        = function(self) return true end,
	RemoveOnDeath = function(self) return true end,
	GetAttributes = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})
function modifier_beast_azure_breath:OnCreated(params)
	if IsServer() then
	end
end

function modifier_beast_azure_breath:OnRefresh(params)
	if IsServer() then
	end
end

function modifier_beast_azure_breath:OnDestroy()
	if IsServer() then
	end
end

function modifier_beast_azure_breath:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end

function modifier_beast_azure_breath:OnAttackLanded(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	local ability = self:GetAbility()
	local target = params.target
	local caster = self:GetParent()
	local damage = params.damage

	local splashData = { {
		radius = ability:GetSpecialValueFor("small_radius"),
		damage = ability:GetSpecialValueFor("small_damage_pct") * damage / 100
	}, {
		radius = ability:GetSpecialValueFor("large_radius"),
		damage = ability:GetSpecialValueFor("large_radius_pct") * damage / 100
	} }

	splashAttack(caster, target, splashData, ability)
end
