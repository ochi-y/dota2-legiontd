LinkLuaModifier("modifier_demi_human_ransack", "ability/demi_human_ransack.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if demi_human_ransack == nil then
	demi_human_ransack = class({})
end
function demi_human_ransack:GetIntrinsicModifierName()
	return "modifier_demi_human_ransack"
end
-------------------------------------------------------------------------------------------------------
modifier_demi_human_ransack = class({
	IsHidden = function(self)
		return true
	end,
	IsPurgable = function(self)
		return false
	end,
	IsDebuff = function(self)
		return false
	end,
	IsBuff = function(self)
		return true
	end,
	RemoveOnDeath = function(self)
		return true
	end,
	GetAttributes = function(self)
		return MODIFIER_ATTRIBUTE_NONE
	end
})
function modifier_demi_human_ransack:AllowIllusionDuplicate()
	return false
end
function modifier_demi_human_ransack:OnCreated(params)
	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.health_steal=ability:GetSpecialValueFor("health_steal")
	self.max_count=ability:GetSpecialValueFor("max_count")
	if not IsServer() then return end
	-- self.damage = params.damage
	-- self:SetHasCustomTransmitterData(true) 
end
function modifier_demi_human_ransack:OnRefresh(params)
	self:OnCreated(params)
end
function modifier_demi_human_ransack:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end

function modifier_demi_human_ransack:OnAttackLanded(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	local target = params.target
	-- 
	local caster=self:GetCaster()
	local ability=self:GetAbility()
	SimpleApplyDamage(ability, caster, target, self.health_steal)
	local units=FindAbilityTarget(ability,caster:GetAbsOrigin(),ability:GetSpecialValueFor("radius"),{})
	local c=0
	for index, unit in ipairs(units) do
		if unit:GetUnitName()=="demi_human_slavemaster" or unit:GetUnitName()=="demi_human_servant" then
			unit:HealWithParams(self.health_steal, self:GetAbility(), false, true,caster, false)
			PlayEffOnUnit("particles/units/heroes/hero_meepo/meepo_ransack.vpcf",unit)
			c=c+1
			if c>=self.max_count then
				break
			end
		end
	end

end
