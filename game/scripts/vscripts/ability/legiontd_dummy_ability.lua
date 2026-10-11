LinkLuaModifier("modifier_legiontd_dummy_ability", "ability/legiontd_dummy_ability.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if legiontd_dummy_ability == nil then
	legiontd_dummy_ability = class({})
end
function legiontd_dummy_ability:GetIntrinsicModifierName()
	return "modifier_legiontd_dummy_ability"
end

-------------------------------------------------------------------------------------------------------
-- modifier   ---------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
modifier_legiontd_dummy_ability = class({
	IsHidden = function(self)
		return false
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
function modifier_legiontd_dummy_ability:AllowIllusionDuplicate()
	return false
end

function modifier_legiontd_dummy_ability:OnCreated(params)
	if not self:GetAbility() then return end
	local ability = self:GetAbility()
	self.goldCost = ability:GetSpecialValueFor("goldCost")
	if not IsServer() then return end
end

function modifier_legiontd_dummy_ability:OnRefresh(params)
end

function modifier_legiontd_dummy_ability:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}
end

function modifier_legiontd_dummy_ability:OnTakeDamage(params)

	barebones:recordDamageTable(params.attacker,params.unit,params.damage,params.damage_type)

end
