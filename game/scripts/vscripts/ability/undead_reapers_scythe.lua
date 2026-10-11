undead_reapers_scythe = undead_reapers_scythe or class({})
LinkLuaModifier("modifier_imba_reapers_scythe", "ability/undead_reapers_scythe", LUA_MODIFIER_MOTION_NONE)

-- function undead_reapers_scythe:GetAbilityTextureName()
-- 	return "necrolyte_reapers_scythe"
-- end

function undead_reapers_scythe:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()

		if target:TriggerSpellAbsorb(self) then
			return nil
		end

		-- Cast sound
		caster:EmitSound("Hero_Necrolyte.ReapersScythe.Cast")
		target:EmitSound("Hero_Necrolyte.ReapersScythe.Target")
		if (math.random(1, 100) <= 30) and (caster:GetName() == "npc_dota_hero_necrolyte") then
			caster:EmitSound("necrolyte_necr_ability_reap_0" .. math.random(1, 3))
		end

		-- Parameters
		local stun_duration = self:GetSpecialValueFor("stun_duration")

		target:AddNewModifier(caster, self, "modifier_imba_reapers_scythe", { duration = stun_duration })
	end
end

function undead_reapers_scythe:IsHiddenWhenStolen()
	return false
end

modifier_imba_reapers_scythe = modifier_imba_reapers_scythe or class({})
function modifier_imba_reapers_scythe:IgnoreTenacity() return true end

function modifier_imba_reapers_scythe:OnCreated()
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetParent()
		self.ability = self:GetAbility()
		self.damage_per_health = self.ability:GetSpecialValueFor("damage_per_health")
		self.boss_damage_per_health = self.ability:GetSpecialValueFor("boss_damage_per_health")

		local stun_fx = ParticleManager:CreateParticle("particles/generic_gameplay/generic_stunned.vpcf",
			PATTACH_OVERHEAD_FOLLOW, target)
		self:AddParticle(stun_fx, false, false, -1, false, false)
		local orig_fx = ParticleManager:CreateParticle(
			"particles/units/heroes/hero_necrolyte/necrolyte_scythe_orig.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		self:AddParticle(orig_fx, false, false, -1, false, false)

		local scythe_fx = ParticleManager:CreateParticle(
			"particles/units/heroes/hero_necrolyte/necrolyte_scythe_start.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:SetParticleControlEnt(scythe_fx, 0, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc",
			caster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(scythe_fx, 1, target, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc",
			target:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(scythe_fx)
	end
end

function modifier_imba_reapers_scythe:OnRefresh()
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetParent()
		self.ability = self:GetAbility()
		self.damage_per_health = self.ability:GetSpecialValueFor("damage_per_health")
		self.boss_damage_per_health = self.ability:GetSpecialValueFor("boss_damage_per_health")

		local stun_fx = ParticleManager:CreateParticle("particles/generic_gameplay/generic_stunned.vpcf",
			PATTACH_OVERHEAD_FOLLOW, target)
		self:AddParticle(stun_fx, false, false, -1, false, false)
		local orig_fx = ParticleManager:CreateParticle(
			"particles/units/heroes/hero_necrolyte/necrolyte_scythe_orig.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		self:AddParticle(orig_fx, false, false, -1, false, false)

		local scythe_fx = ParticleManager:CreateParticle(
			"particles/units/heroes/hero_necrolyte/necrolyte_scythe_start.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:SetParticleControlEnt(scythe_fx, 0, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc",
			caster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(scythe_fx, 1, target, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc",
			target:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(scythe_fx)
	end
end

function modifier_imba_reapers_scythe:GetEffectName()
	return "particles/units/heroes/hero_necrolyte/necrolyte_scythe.vpcf"
end

function modifier_imba_reapers_scythe:StatusEffectPriority()
	return MODIFIER_PRIORITY_ULTRA
end

function modifier_imba_reapers_scythe:GetPriority()
	return MODIFIER_PRIORITY_ULTRA
end

function modifier_imba_reapers_scythe:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_imba_reapers_scythe:CheckState()
	local state =
	{
		[MODIFIER_STATE_STUNNED] = true
	}
	return state
end

function modifier_imba_reapers_scythe:IsPurgable() return false end

function modifier_imba_reapers_scythe:IsPurgeException() return false end

function modifier_imba_reapers_scythe:DeclareFunctions()
	local decFuncs =
	{
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}
	return decFuncs
end

function modifier_imba_reapers_scythe:GetOverrideAnimation()
	return ACT_DOTA_DISABLED
end

function modifier_imba_reapers_scythe:OnRemoved()
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetParent()

		-- I don't know why this thing allows a frame for enemies to activate magic immunity before receiving damage but only if Reaper's Scythe would have been fatal...so let's just stun them for another frame
		target:AddNewModifier(caster, self:GetAbility(), "modifier_stunned", { duration = FrameTime() })

		if target:IsAlive() and self.ability then
			local damage = self.damage_per_health * (target:GetMaxHealth() - target:GetHealth())
			
			if target:IsAncient() then
				damage = self.boss_damage_per_health * (target:GetMaxHealth() - target:GetHealth())
			end

			-- If this very rough formula for damage exceeds that of the target's health, apply the respawn modifier that increases respawn time of target...

			-- if (self.damage * (1 + (caster:GetSpellAmplification(false) * 0.01)) * (1 - target:GetMagicalArmorValue())) >= target:GetHealth() then
			-- 	self:GetParent():AddNewModifier(self:GetCaster(), self.ability, "modifier_imba_reapers_scythe_respawn",
			-- 		{})
			-- end

			-- Deals damage (optimally, the ApplyDamage float number would be used for calculating whether the respawn modifier should be applied.
			-- However, that doesn't seem to be possible without actually inflicting the damage, and modifiers cannot be applied on dead units)
			local actually_dmg = ApplyDamage({
				attacker = caster,
				victim = target,
				ability = self.ability,
				damage = damage,
				damage_type = DAMAGE_TYPE_MAGICAL
			})
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_DAMAGE, target, actually_dmg, nil)

			-- ...HOWEVER, in the case of the target not actually dying under scythe due to incorrect calculations (ex. Dazzle Grave, Oracle False Promise, Bristleback damage reduction, etc.), remove the modifier
			-- This will prevent a indefinitely lingering respawn modifier that increases respawn time (or worse) upon an actual death later
			-- if target:IsAlive() and target:HasModifier("modifier_imba_reapers_scythe_respawn") then
			-- 	self:GetParent():RemoveModifierByName("modifier_imba_reapers_scythe_respawn")
			-- end
		end
	end
end
