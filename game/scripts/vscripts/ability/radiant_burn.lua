LinkLuaModifier("modifier_radiant_burn", "ability/radiant_burn.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_radiant_burn_debuff", "ability/radiant_burn.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if radiant_burn == nil then
	radiant_burn = class({})
end
function radiant_burn:GetIntrinsicModifierName()
	return "modifier_radiant_burn"
end

modifier_radiant_burn = class({
	IsHidden         = function(self) return true end,
	IsPurgable       = function(self) return false end,
	IsDebuff         = function(self) return false end,
	IsBuff           = function(self) return true end,
	DeclareFunctions = function()
		return {
			MODIFIER_EVENT_ON_ATTACK_LANDED
		}
	end
})

function modifier_radiant_burn:OnCreated()
	if not self:GetAbility() then return end
	local ability = self:GetAbility()
	self.duration = ability:GetSpecialValueFor("duration")
	self.damage = ability:GetSpecialValueFor("damage")
	self.heal_reduction = ability:GetSpecialValueFor("heal_reduction")
end

function modifier_radiant_burn:OnRefresh()
	self:OnCreated()
end

function modifier_radiant_burn:OnAttackLanded(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	local target = params.target

	local duration = self.duration
	if params.attacker:PassivesDisabled() == false and SimpleUnitFilter(self:GetAbility(),target) then
		duration = duration * (1 - CalUnitStatusResistance(target))
		target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_radiant_burn_debuff", { duration = self.duration })
	end
end
function modifier_radiant_burn:GetEffectName()
	return "particles/units/heroes/hero_brewmaster/brewmaster_fire_ambient.vpcf"
end

function modifier_radiant_burn:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end



modifier_radiant_burn_debuff = class({
	IsHidden         = function(self) return false end,
	IsPurgable       = function(self) return true end,
	IsDebuff         = function(self) return true end,
	IsBuff           = function(self) return false end,
	DeclareFunctions = function()
		return {
			MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
		MODIFIER_PROPERTY_SPELL_LIFESTEAL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_LIFESTEAL_AMPLIFY_PERCENTAGE
		}
	end
})

function modifier_radiant_burn_debuff:OnCreated()
	if not self:GetAbility() then return end
	local ability = self:GetAbility()
	self.duration = ability:GetSpecialValueFor("duration")
	self.damage = ability:GetSpecialValueFor("damage")
	self.heal_reduction = ability:GetSpecialValueFor("heal_reduction")
	self:StartIntervalThink(0.25)
end

function modifier_radiant_burn_debuff:OnIntervalThink()
	if not self:GetAbility() then return end
	SimpleApplyDamage(self:GetAbility(),self:GetCaster(),self:GetParent(),self.damage*0.25)

end
function modifier_radiant_burn_debuff:GetEffectName()
	return "particles/units/heroes/hero_phoenix/phoenix_icarus_dive_burn_debuff.vpcf"
end

function modifier_radiant_burn_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_radiant_burn_debuff:GetModifierHealAmplify_PercentageTarget(params)
	return -1 * self.heal_reduction
end

function modifier_radiant_burn_debuff:GetModifierSpellLifestealRegenAmplify_Percentage(params)
	return -1 * self.heal_reduction
end

function modifier_radiant_burn_debuff:GetModifierHPRegenAmplify_Percentage(params)
	return -1 * self.heal_reduction
end

function modifier_radiant_burn_debuff:GetModifierLifestealRegenAmplify_Percentage(params)
	return -1 * self.heal_reduction
end
