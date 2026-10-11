LinkLuaModifier("modifier_ghost_insanity", "ability/ghost_insanity.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ghost_insanity_buff", "ability/ghost_insanity.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if ghost_insanity == nil then
	ghost_insanity = class({})
end
function ghost_insanity:GetIntrinsicModifierName()
	return "modifier_ghost_insanity"
end

---------------------------------------------------------------------
--Modifiers
modifier_ghost_insanity = class({
	IsHidden      = function(self) return true end,
	IsPurgable    = function(self) return false end,
	IsDebuff      = function(self) return false end,
	IsBuff        = function(self) return true end,
	RemoveOnDeath = function(self) return true end,
	GetAttributes = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})
function modifier_ghost_insanity:OnCreated(params)
	local ability = self:GetAbility()

	if ability then
		self.armor = ability:GetSpecialValueFor("armor")
		self.chance = ability:GetSpecialValueFor("chance")
		self.bonus_damage = ability:GetSpecialValueFor("bonus_damage")
		self.duration = ability:GetSpecialValueFor("duration")
	end



	if IsServer() then
	end
end

function modifier_ghost_insanity:OnRefresh(params)
	if IsServer() then
	end
end

function modifier_ghost_insanity:OnDestroy()
	if IsServer() then
	end
end

function modifier_ghost_insanity:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK
	}
end

function modifier_ghost_insanity:OnAttack(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	if RandomInt(1, 100) <= self.chance and not self:GetParent():HasModifier("modifier_ghost_insanity_buff") then
		local caster = self:GetParent()
		EmitSoundOn("Hero_Razor.UnstableCurrent.Target", caster)
		PlayEffOnUnit("particles/econ/items/razor/razor_arcana/razor_arcana_kill_effect_target_v2.vpcf", caster,{
			cps={0,1}
		})
		caster:AddNewModifier(caster, self:GetAbility(), "modifier_ghost_insanity_buff", { duration = self.duration })
	end
end

modifier_ghost_insanity_buff = class({
	IsHidden      = function(self) return false end,
	IsPurgable    = function(self) return false end,
	IsDebuff      = function(self) return false end,
	IsBuff        = function(self) return true end,
	RemoveOnDeath = function(self) return true end,
	GetAttributes = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})

function modifier_ghost_insanity_buff:OnCreated()
	if not self:GetAbility() then return end
	local ability = self:GetAbility()
	self.armor = ability:GetSpecialValueFor("armor")
	self.chance = ability:GetSpecialValueFor("chance")
	self.bonus_damage = ability:GetSpecialValueFor("bonus_damage")
end

function modifier_ghost_insanity_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
	}
end

function modifier_ghost_insanity_buff:GetModifierDamageOutgoing_Percentage()
	return self.bonus_damage
end

function modifier_ghost_insanity_buff:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_ghost_insanity_buff:GetEffectName()
	return "particles/units/heroes/hero_razor/razor_static_link_buff.vpcf"
end

function modifier_ghost_insanity_buff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end
