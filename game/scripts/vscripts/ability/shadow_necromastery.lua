LinkLuaModifier("modifier_shadow_necromastery", "ability/shadow_necromastery", LUA_MODIFIER_MOTION_NONE)

shadow_necromastery = {}

function shadow_necromastery:GetIntrinsicModifierName()
	if self:GetLevel() > 0 then
		return "modifier_shadow_necromastery"
	end
end

function shadow_necromastery:Spawn()
	if not IsServer() then return end
	local caster = self:GetCaster()
	Timers:CreateTimer(FrameTime(), function()
		local meta = GamePlay:FighterGetMeta(caster.fighterId)
		local mod = caster:FindModifierByName("modifier_shadow_necromastery")
		if meta and mod then
			if meta.modifierStack["modifier_shadow_necromastery"] then
				mod:SetStackCount(meta.modifierStack["modifier_shadow_necromastery"])
			end
		end
	end)
end

function shadow_necromastery:OnOwnerDied()
	if not IsServer() then return end
	local caster = self:GetCaster()

	if IsActiveBuilding(caster) then
		print("OnOwnerDied 1")
	else
		print("OnOwnerDied 2 ")
		local mod = caster:FindModifierByName("modifier_shadow_necromastery")
		local meta = GamePlay:FighterGetMeta(caster.fighterId)
		print(mod:GetStackCount())
		if meta then
			meta.modifierStack["modifier_shadow_necromastery"]=math.floor(mod:GetStackCount()/2)
		end
	end
end

modifier_shadow_necromastery = {}

function modifier_shadow_necromastery:IsHidden()
	return false
end

function modifier_shadow_necromastery:IsDebuff()
	return false
end

function modifier_shadow_necromastery:IsPurgable()
	return false
end

function modifier_shadow_necromastery:RemoveOnDeath()
	return false
end

function modifier_shadow_necromastery:OnCreated(kv)
	if not self:GetAbility() then return end
	self.soul_max = self:GetAbility():GetSpecialValueFor("necromastery_max_souls")
	self.soul_release = self:GetAbility():GetSpecialValueFor("soul_release")
	self.soul_damage = self:GetAbility():GetSpecialValueFor("necromastery_damage_per_soul")
end

function modifier_shadow_necromastery:OnRefresh(kv)
	if not self:GetAbility() then return end
	self.soul_max = self:GetAbility():GetSpecialValueFor("necromastery_max_souls")
	self.soul_release = self:GetAbility():GetSpecialValueFor("soul_release")
	self.soul_damage = self:GetAbility():GetSpecialValueFor("necromastery_damage_per_soul")
end

function modifier_shadow_necromastery:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE
	}
end

function modifier_shadow_necromastery:GetModifierSpellAmplify_Percentage()
	return self:GetStackCount()
end

function modifier_shadow_necromastery:OnDeath(params)
	if IsServer() then
		self:DeathLogic(params)
		self:KillLogic(params)
	end
end

function modifier_shadow_necromastery:GetModifierPreAttack_BonusDamage(params)
	if not self:GetParent():IsIllusion() then
		local max_stack = self.soul_max
		return math.min(self.soul_max, self:GetStackCount()) * self.soul_damage
	end
end

function modifier_shadow_necromastery:DeathLogic(params)
	local unit = params.unit
	local pass = false
	if unit == self:GetParent() and params.reincarnate == false then
		pass = true
	end

	if pass then
		local after_death = math.floor(self:GetStackCount() * self.soul_release)
		self:SetStackCount(math.max(after_death, 1))
	end
end

function modifier_shadow_necromastery:KillLogic(params)
	local target = params.unit
	local attacker = params.attacker
	local pass = false
	if attacker == self:GetParent() and target ~= self:GetParent() and attacker:IsAlive() then
		if (not target:IsIllusion()) and (not target:IsBuilding()) then
			pass = true
		end
	end

	if pass and (not self:GetParent():PassivesDisabled()) then
		self:AddStack(1)

		ProjectileManager:CreateTrackingProjectile({
			Target = self:GetParent(),
			Source = target,
			EffectName = "particles/units/heroes/hero_nevermore/nevermore_necro_souls.vpcf",
			iMoveSpeed = 400,
			vSourceLoc = target:GetAbsOrigin(),
			bDodgeable = false,
			bReplaceExisting = false,
			flExpireTime = GameRules:GetGameTime() + 5,
			bProvidesVision = false,
		})
	end
end

function modifier_shadow_necromastery:AddStack()
	local after = self:GetStackCount() + 1
	if after > self.soul_max then
		after = self.soul_max
	end
	self:SetStackCount(after)
end
