LinkLuaModifier("modifier_ability_undying_flesh_golem", "ability/ability_undying_flesh_golem.lua",LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_ability_undying_flesh_golem_debuff", "ability/ability_undying_flesh_golem.lua",LUA_MODIFIER_MOTION_NONE)

--Abilities
ability_undying_flesh_golem = class({})
wave_17_champion_flesh_golem=ability_undying_flesh_golem
function ability_undying_flesh_golem:GetIntrinsicModifierName()
	return "modifier_ability_undying_flesh_golem"
end

---------------------------------------------------------------------
--Modifiers
-------------------------------------------------------------------------------------------------------
modifier_ability_undying_flesh_golem = class({
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
function modifier_ability_undying_flesh_golem:AllowIllusionDuplicate()
	return false
end

function modifier_ability_undying_flesh_golem:OnCreated(params)
	local ability=self:GetAbility()
	self.duration=ability:GetSpecialValueFor("duration")
end

function modifier_ability_undying_flesh_golem:OnRefresh(params)
	self:OnCreated(params)
end

function modifier_ability_undying_flesh_golem:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end

function modifier_ability_undying_flesh_golem:CheckState()
	local state = {
	}
	return state
end

function modifier_ability_undying_flesh_golem:OnAttackLanded(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	local target = params.target

	local caster=self:GetParent()

	local ability=self:GetAbility()

	target:AddNewModifier(caster, ability, "modifier_ability_undying_flesh_golem_debuff", {
		duration=self.duration
	})
end


-------------------------------------------------------------------------------------------------------
modifier_ability_undying_flesh_golem_debuff = class({
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
function modifier_ability_undying_flesh_golem_debuff:AllowIllusionDuplicate()
	return false
end
function modifier_ability_undying_flesh_golem_debuff:OnCreated(params)
	-- self.damage = params.damage
	-- self:SetHasCustomTransmitterData(true) 
	local ability=self:GetAbility()
	self.slow=ability:GetSpecialValueFor("slow")
	self.damage_amp=ability:GetSpecialValueFor("damage_amp")
	
end
function modifier_ability_undying_flesh_golem_debuff:OnRefresh(params)
	self:OnCreated(params)
end
function modifier_ability_undying_flesh_golem_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
end
function modifier_ability_undying_flesh_golem_debuff:CheckState()
	local state = {
	}
	return state
end

function modifier_ability_undying_flesh_golem_debuff:GetModifierIncomingDamage_Percentage(params)
	return  self.damage_amp
end
function modifier_ability_undying_flesh_golem_debuff:GetModifierMoveSpeedBonus_Percentage(params)
	return - self.slow
end

function modifier_ability_undying_flesh_golem_debuff:GetEffectName()
	return "particles/units/heroes/hero_undying/undying_fg_aura_debuff.vpcf"
end
function modifier_ability_undying_flesh_golem_debuff:GetEffectAttachType()
	return PATTACH_POINT_FOLLOW
end

