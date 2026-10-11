LinkLuaModifier( "modifier_beast_circle_slash", "ability/beast_circle_slash.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if beast_circle_slash == nil then
	beast_circle_slash = class({})
end
function beast_circle_slash:GetIntrinsicModifierName()
	return "modifier_beast_circle_slash"
end
---------------------------------------------------------------------
--Modifiers
modifier_beast_circle_slash = class({
	IsHidden                = function(self) return true end,
	IsPurgable              = function(self) return false end,
	IsDebuff                = function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath           = function(self) return true end,
	GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
	})
function modifier_beast_circle_slash:OnCreated(params)
	if IsServer() then
	end
end
function modifier_beast_circle_slash:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_beast_circle_slash:OnDestroy()
	if IsServer() then
	end
end

function modifier_beast_circle_slash:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end

function modifier_beast_circle_slash:OnAttackLanded(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	local ability=self:GetAbility()
	local target = params.target
	local caster=self:GetParent()
	local damage=params.damage
	--circleCleaveAttack( caster,target,target:GetAbsOrigin(),85,params.damage*0.4,ability,{groundOnly=true})

	local splashData = {{
		radius = ability:GetSpecialValueFor("small_radius"),
		damage = ability:GetSpecialValueFor("small_damage_pct") * damage/100
	}, {
		radius = ability:GetSpecialValueFor("large_radius"),
		damage = ability:GetSpecialValueFor("large_radius_pct") * damage/100
	}}

	splashAttack(caster,target,splashData, ability,{groundOnly=true})
end


