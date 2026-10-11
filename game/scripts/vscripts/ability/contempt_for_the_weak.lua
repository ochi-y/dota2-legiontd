LinkLuaModifier("modifier_contempt_for_the_weak", "ability/contempt_for_the_weak.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
contempt_for_the_weak = class({})
contempt_for_the_weak_hc = contempt_for_the_weak
function contempt_for_the_weak:GetIntrinsicModifierName()
	return "modifier_contempt_for_the_weak"
end

---------------------------------------------------------------------
--Modifiers
-------------------------------------------------------------------------------------------------------
modifier_contempt_for_the_weak = class({
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
function modifier_contempt_for_the_weak:AllowIllusionDuplicate()
	return false
end

function modifier_contempt_for_the_weak:OnCreated(params)
	if not self:GetAbility() then return end
	-- self.damage = params.damage
	-- self:SetHasCustomTransmitterData(true)

	local ability = self:GetAbility()
	self.health_pct = ability:GetSpecialValueFor("health_pct")
	self.damage_pct = ability:GetSpecialValueFor("damage_pct")
	self.boss_damage_pct = ability:GetSpecialValueFor("boss_damage_pct")
end

function modifier_contempt_for_the_weak:OnRefresh(params)
	-- self.damage = params.damage
	-- self:SetHasCustomTransmitterData(true)
	local ability = self:GetAbility()
	self.health_pct = ability:GetSpecialValueFor("health_pct")
	self.damage_pct = ability:GetSpecialValueFor("damage_pct")
	self.boss_damage_pct = ability:GetSpecialValueFor("boss_damage_pct")
end

function modifier_contempt_for_the_weak:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end

function modifier_contempt_for_the_weak:CheckState()
	local state = {
	}

	return state
end

function modifier_contempt_for_the_weak:OnAttackLanded(params)
	if not IsServer() then
		return
	end
	if params.attacker ~= self:GetParent() then
		return
	end
	local target = params.target
	local attacker = params.attacker

	if target:GetHealthPercent() <= self.health_pct and self:GetAbility():IsCooldownReady() then
		self:GetAbility():StartCooldown(self:GetAbility():GetEffectiveCooldown(self:GetAbility():GetLevel()))
		local dmg = self.damage_pct * target:GetMaxHealth() / 100

		if target:IsAncient() then
			dmg = self.boss_damage_pct * target:GetMaxHealth() / 100
		end

		SimpleApplyDamage(self:GetAbility(), attacker, target, self.damage_pct * target:GetMaxHealth() / 100,
			DAMAGE_TYPE_PHYSICAL)
		EmitSoundOn("Hero_SkeletonKing.CriticalStrike", self:GetParent())
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_CRITICAL, target, dmg, nil)
		return self.crit_mult
	end
end
