LinkLuaModifier( "modifier_nature_trueshot", "ability/nature_trueshot", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_nature_trueshot_bonus", "ability/nature_trueshot", LUA_MODIFIER_MOTION_NONE )

nature_trueshot = {}

-- function nature_trueshot:OnSpellStart()
-- 	local caster=self:GetCaster()
-- 	caster:AddNewModifier(caster, self, "modifier_nature_trueshot", {
-- 	})
-- end

function nature_trueshot:GetIntrinsicModifierName()
	if self:GetLevel()>0 then
		return "modifier_nature_trueshot"
	end
end

modifier_nature_trueshot = {}

function modifier_nature_trueshot:IsHidden()
	return true
end

function modifier_nature_trueshot:IsAura()
	if self:GetParent():PassivesDisabled() then return false end
	return true
end

function modifier_nature_trueshot:GetModifierAura()
	return "modifier_nature_trueshot_bonus"
end

function modifier_nature_trueshot:GetAuraRadius()
	if self:GetParent():PassivesDisabled() then return 0 end
	return self:GetAbility():GetSpecialValueFor( "radius" )
end

function modifier_nature_trueshot:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_nature_trueshot:GetAuraSearchType()
	return DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_HERO
end

function modifier_nature_trueshot:GetAuraEntityReject(unit)
	if unit:GetAttackCapability()~=DOTA_UNIT_CAP_RANGED_ATTACK then
		return true
	end
	return unit:GetLevel()<2
end

-------------------------------------------------------------------------------------------------------
modifier_nature_trueshot_bonus = class({
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
function modifier_nature_trueshot_bonus:AllowIllusionDuplicate()
	return false
end
function modifier_nature_trueshot_bonus:OnCreated(params)
	if not self:GetAbility() then return end
	local ability=self:GetAbility()
	self.trueshot_ranged_damage=ability:GetSpecialValueFor("trueshot_ranged_damage")
	if not IsServer() then return end
	local caster=self:GetCaster()
	self:SetStackCount( math.floor(0.01*self.trueshot_ranged_damage*(caster:GetBaseDamageMin()+caster:GetBaseDamageMax())/2))
end
function modifier_nature_trueshot_bonus:OnRefresh(params)
	self:OnCreated(params)
end

function modifier_nature_trueshot_bonus:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
	}
end
function modifier_nature_trueshot_bonus:GetModifierDamageOutgoing_Percentage()
	return self:GetStackCount()
end
