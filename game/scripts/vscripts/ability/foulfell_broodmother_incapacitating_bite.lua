LinkLuaModifier("modifier_foulfell_broodmother_incapacitating_bite",
	"ability/foulfell_broodmother_incapacitating_bite.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_foulfell_broodmother_incapacitating_bite_orb",
	"ability/foulfell_broodmother_incapacitating_bite.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if foulfell_broodmother_incapacitating_bite == nil then
	foulfell_broodmother_incapacitating_bite = class({})
end
function foulfell_broodmother_incapacitating_bite:GetIntrinsicModifierName()
	return "modifier_foulfell_broodmother_incapacitating_bite"
end

-------------------------------------------------------------------------------------------------------
-- modifier   ---------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
modifier_foulfell_broodmother_incapacitating_bite = class({
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
function modifier_foulfell_broodmother_incapacitating_bite:AllowIllusionDuplicate()
	return false
end

function modifier_foulfell_broodmother_incapacitating_bite:OnCreated(params)
	if not self:GetAbility() then return end
	local ability = self:GetAbility()
	self.duration = ability:GetSpecialValueFor("duration")
	if not IsServer() then return end
end

function modifier_foulfell_broodmother_incapacitating_bite:OnRefresh(params)
	self:OnCreated(params)
end

function modifier_foulfell_broodmother_incapacitating_bite:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end

function modifier_foulfell_broodmother_incapacitating_bite:OnAttackLanded(params)
	if not IsServer() then
		return
	end
	if params.attacker ~= self:GetParent() then
		return
	end
	local target = params.target
	local parent = self:GetParent()
	if parent:IsIllusion() then
		return
	end
	if SimpleUnitFilter(self:GetAbility(), target) then
		target:AddNewModifier(params.attacker, self:GetAbility(), "modifier_foulfell_broodmother_incapacitating_bite_orb",
			{
				duration = self.duration
			})
	end
	--
end

-------------------------------------------------------------------------------------------------------
-- modifier   ---------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
modifier_foulfell_broodmother_incapacitating_bite_orb = class({
	IsHidden = function(self)
		return false
	end,
	IsPurgable = function(self)
		return true
	end,
	IsDebuff = function(self)
		return true
	end,
	IsBuff = function(self)
		return false
	end,
	RemoveOnDeath = function(self)
		return true
	end,
	GetAttributes = function(self)
		return MODIFIER_ATTRIBUTE_NONE
	end
})
function modifier_foulfell_broodmother_incapacitating_bite_orb:AllowIllusionDuplicate()
	return false
end

function modifier_foulfell_broodmother_incapacitating_bite_orb:OnCreated(params)
	if not self:GetAbility() then return end
	local ability = self:GetAbility()
	self.miss_chance = ability:GetSpecialValueFor("miss_chance")
	self.bonus_movespeed = ability:GetSpecialValueFor("bonus_movespeed")
	if not IsServer() then return end
end

function modifier_foulfell_broodmother_incapacitating_bite_orb:OnRefresh(params)
	self:OnCreated(params)
end

function modifier_foulfell_broodmother_incapacitating_bite_orb:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_MISS_PERCENTAGE
	}
end

function modifier_foulfell_broodmother_incapacitating_bite_orb:GetModifierMiss_Percentage(params)
	return self.miss_chance
end

function modifier_foulfell_broodmother_incapacitating_bite_orb:GetModifierMoveSpeedBonus_Percentage(params)
	return self.bonus_movespeed
end

function modifier_foulfell_broodmother_incapacitating_bite_orb:GetEffectName()
	return "particles/units/heroes/hero_broodmother/broodmother_incapacitatingbite_debuff.vpcf"
end

function modifier_foulfell_broodmother_incapacitating_bite_orb:GetEffectAttachType()
	return PATTACH_POINT_FOLLOW
end
