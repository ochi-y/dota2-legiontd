LinkLuaModifier("modifier_ghost_soul_assumption", "ability/ghost_soul_assumption", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ghost_soul_assumption_stacks", "ability/ghost_soul_assumption", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ghost_soul_assumption_counter", "ability/ghost_soul_assumption", LUA_MODIFIER_MOTION_NONE)


ghost_soul_assumption                  = class({})
modifier_ghost_soul_assumption         = class({})
modifier_ghost_soul_assumption_stacks  = class({})
modifier_ghost_soul_assumption_counter = class({})



function ghost_soul_assumption:GetIntrinsicModifierName()
	return "modifier_ghost_soul_assumption"
end

function ghost_soul_assumption:OnUpgrade()
	if not IsServer() then return end

	if self:GetLevel() >= 1 and self:GetCaster():FindModifierByNameAndCaster(self:GetIntrinsicModifierName(), self:GetCaster()) and not self:GetCaster():FindModifierByNameAndCaster(self:GetIntrinsicModifierName(), self:GetCaster()).particle then
		self:GetCaster():FindModifierByNameAndCaster(self:GetIntrinsicModifierName(), self:GetCaster()).particle =
			ParticleManager:CreateParticle("particles/units/heroes/hero_visage/visage_soul_overhead.vpcf",
				PATTACH_OVERHEAD_FOLLOW, self:GetCaster())
		self:GetCaster():FindModifierByNameAndCaster(self:GetIntrinsicModifierName(), self:GetCaster()):AddParticle(
			self:GetCaster():FindModifierByNameAndCaster(self:GetIntrinsicModifierName(), self:GetCaster()).particle,
			false,
			false, -1, false, false)
	end
end

function ghost_soul_assumption:OnSpellStart()
	local target = self:GetCursorTarget()

	self:GetCaster():EmitSound("Hero_Visage.SoulAssumption.Cast")

	if self:GetCaster():GetName() == "npc_dota_hero_visage" then
		if RollPercentage(10) then
			if not self.responses_rare then
				self.responses_rare =
				{
					"visage_visa_soulassumption01",
					"visage_visa_soulassumption02",
					"visage_visa_soulassumption07"
				}
			end

			self:GetCaster():EmitSound(self.responses_rare[RandomInt(1, #self.responses_rare)])
		else
			if not self.responses then
				self.responses =
				{
					"visage_visa_gravechill_24",
					"visage_visa_gravechill_26",
					"visage_visa_gravechill_27",
					"visage_visa_gravechill_28",
					"visage_visa_gravechill_32"
				}
			end

			self:GetCaster():EmitSound(self.responses[RandomInt(1, #self.responses)])
		end
	end

	local assumption_counter_modifier = self:GetCaster():FindModifierByNameAndCaster(
		"modifier_ghost_soul_assumption_counter", self:GetCaster())
	local damage_bars                 = 0
	local effect_name                 = "particles/units/heroes/hero_visage/visage_soul_assumption_bolt.vpcf"
	-- IMBAfication: Soul Accelerant
	local overflow_counter            = 1

	if assumption_counter_modifier then
		damage_bars = math.min(
			math.floor(assumption_counter_modifier:GetStackCount() / self:GetSpecialValueFor("damage_limit")),
			self:GetSpecialValueFor("stack_limit"))
		overflow_counter = math.max(
			assumption_counter_modifier:GetStackCount() -
			(self:GetSpecialValueFor("damage_limit") * self:GetSpecialValueFor("stack_limit")), 0)

		if damage_bars > 0 then
			effect_name = "particles/units/heroes/hero_visage/visage_soul_assumption_bolt" .. damage_bars .. ".vpcf"
		end

		local assumption_stack_modifiers = self:GetCaster():FindAllModifiersByName(
			"modifier_ghost_soul_assumption_stacks")

		for _, mod in pairs(assumption_stack_modifiers) do
			mod:Destroy()
		end

		assumption_counter_modifier:Destroy()
	end

	local projectile =
	{
		Target            = nil,
		Source            = self:GetCaster(),
		Ability           = self,
		EffectName        = effect_name,
		iMoveSpeed        = math.min(self:GetSpecialValueFor("bolt_speed")),
		vSourceLoc        = self:GetCaster():GetAbsOrigin(),
		bDrawsOnMinimap   = false,
		bDodgeable        = true,
		bIsAttack         = false,
		bVisibleToEnemies = true,
		bReplaceExisting  = false,
		flExpireTime      = GameRules:GetGameTime() + 10.0,
		bProvidesVision   = false,

		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,

		ExtraData         = {
			charges = damage_bars
		}
	}

	projectile.Target = target
	ProjectileManager:CreateTrackingProjectile(projectile)

	local target_counter = 1

	-- CDOTA_BaseNPC: GetCastRangeBonus() added in Summer Scrub patch xd
	-- "Heroes and illusions have a higher priority than other units. Treats creep-heroes as creeps."
	local enemy_heroes = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), target:GetAbsOrigin(), nil,
		self:GetCastRange(self:GetCaster():GetAbsOrigin(), self:GetCaster()) + self:GetCaster():GetCastRangeBonus(),
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
		DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_ANY_ORDER, false)

	for _, enemy in pairs(enemy_heroes) do
		if target_counter >= 1 then
			break
		end
		if enemy ~= target then
			projectile.Target = enemy
			ProjectileManager:CreateTrackingProjectile(projectile)
			target_counter = target_counter + 1
		end
	end

	-- if target_counter < self:GetTalentSpecialValueFor("targets") then
	-- 	local enemy_creeps = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), target:GetAbsOrigin(), nil,
	-- 		self:GetCastRange(self:GetCaster():GetAbsOrigin(), self:GetCaster()) + self:GetCaster():GetCastRangeBonus(),
	-- 		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC,
	-- 		DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_ANY_ORDER, false)

	-- 	for _, enemy in pairs(enemy_creeps) do
	-- 		if target_counter >= self:GetTalentSpecialValueFor("targets") then
	-- 			break
	-- 		end

	-- 		if enemy ~= target then
	-- 			projectile.Target = enemy
	-- 			ProjectileManager:CreateTrackingProjectile(projectile)

	-- 			target_counter = target_counter + 1
	-- 		end
	-- 	end
	-- end
end

function ghost_soul_assumption:OnProjectileHit_ExtraData(target, location, data)
	if target and not target:TriggerSpellAbsorb(self) then
		target:EmitSound("Hero_Visage.SoulAssumption.Target")
		--
		local damageTable = {
			victim       = target,
			damage       = self:GetSpecialValueFor("soul_base_damage") +
				(self:GetSpecialValueFor("soul_charge_damage") * data.charges),
			damage_type  = self:GetAbilityDamageType(),
			damage_flags = DOTA_DAMAGE_FLAG_NONE,
			attacker     = self:GetCaster(),
			ability      = self
		}
		--
		ApplyDamage(damageTable)
	end
end

-------------------------------
-- SOUL ASSUMPTION MODIFIER --
------------------------------

function modifier_ghost_soul_assumption:IsHidden() return true end

function modifier_ghost_soul_assumption:IsPurgable() return false end

function modifier_ghost_soul_assumption:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

-- This shouldn't really happen but in case it gets ported in already leveled
function modifier_ghost_soul_assumption:OnCreated()
	if not IsServer() then return end

	if self:GetAbility() and self:GetAbility():GetLevel() >= 1 and not self.particle then
		self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_visage/visage_soul_overhead.vpcf",
			PATTACH_OVERHEAD_FOLLOW, self:GetParent())
		self:AddParticle(self.particle, false, false, -1, false, false)
	end
end

function modifier_ghost_soul_assumption:OnDestroy()
	if IsServer() and self.particle then
		ParticleManager:DestroyParticle(self.particle, true)
		ParticleManager:ReleaseParticleIndex(self.particle)
	end
end

function modifier_ghost_soul_assumption:DeclareFunctions()
	local decFuncs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}

	return decFuncs
end

function modifier_ghost_soul_assumption:OnTakeDamage(keys)
	-- "Only counts damage dealt by players (including their summons) and Roshan."
	-- "Only counts when the damage was dealt to a hero (excluding illusions and creep-heroes)."
	-- "Does not count self-inflicted damage, or damage less than 2 or greater than 3000 (after reductions)."


	-- (keys.attacker:IsControllableByAnyPlayer() or keys.attacker:IsRoshan()) 
	-- or string.find(keys.attacker:GetDebugName(), "npc_dota_visage_familiar")


	if (keys.unit:GetAbsOrigin() - self:GetParent():GetAbsOrigin()):Length2D() <= self:GetAbility():GetSpecialValueFor("radius") and
		(not keys.unit:IsIllusion() ) and -- IMBAfication: Familiar Flow
		keys.unit ~= keys.attacker and
		keys.damage >= self:GetAbility():GetSpecialValueFor("damage_min") and
		keys.damage <= self:GetAbility():GetSpecialValueFor("damage_max") and
		-- Seems like Soul Assumption damage doesn't feed into its own stacks
		keys.inflictor ~= self:GetAbility() then
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_ghost_soul_assumption_counter",
			{
				duration = self:GetAbility():GetSpecialValueFor("stack_duration"),
				stacks   = keys.damage
			})

		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_ghost_soul_assumption_stacks",
			{
				duration = self:GetAbility():GetSpecialValueFor("stack_duration"),
				stacks   = keys.damage
			})
	end
end

-------------------------------------
-- SOUL ASSUMPTION STACKS MODIFIER --
-------------------------------------

function modifier_ghost_soul_assumption_stacks:IsHidden() return true end

function modifier_ghost_soul_assumption_stacks:IsPurgable() return false end

function modifier_ghost_soul_assumption_stacks:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_ghost_soul_assumption_stacks:OnCreated(params)
	if not IsServer() then return end

	self.damage_limit = self:GetAbility():GetSpecialValueFor("damage_limit")
	self.stack_limit = self:GetAbility():GetSpecialValueFor("stack_limit")

	self:SetStackCount(params.stacks)

	local assumption_modifier         = self:GetParent():FindModifierByNameAndCaster("modifier_ghost_soul_assumption",
		self:GetCaster())
	local assumption_counter_modifier = self:GetParent():FindModifierByNameAndCaster(
		"modifier_ghost_soul_assumption_counter", self:GetCaster())

	if assumption_modifier and assumption_modifier.particle and assumption_counter_modifier then
		assumption_counter_modifier:SetStackCount(assumption_counter_modifier:GetStackCount() + params.stacks)

		for bar = 1, self.stack_limit do
			ParticleManager:SetParticleControl(assumption_modifier.particle, bar,
				Vector(assumption_counter_modifier:GetStackCount() - (self.damage_limit * bar), 0, 0))
		end
	end
end

function modifier_ghost_soul_assumption_stacks:OnDestroy()
	if not IsServer() then return end

	local assumption_modifier         = self:GetParent():FindModifierByNameAndCaster("modifier_ghost_soul_assumption",
		self:GetCaster())
	local assumption_counter_modifier = self:GetParent():FindModifierByNameAndCaster(
		"modifier_ghost_soul_assumption_counter", self:GetCaster())

	if assumption_counter_modifier then
		assumption_counter_modifier:SetStackCount(assumption_counter_modifier:GetStackCount() - self:GetStackCount())

		if assumption_modifier and assumption_modifier.particle then
			for bar = 1, self.stack_limit do
				ParticleManager:SetParticleControl(assumption_modifier.particle, bar,
					Vector(assumption_counter_modifier:GetStackCount() - (self.damage_limit * bar), 0, 0))
			end
		end
	end
end

------------------------------------
-- SOUL ASSUMPTION COUNT MODIFIER --
------------------------------------

function modifier_ghost_soul_assumption_counter:IsHidden() return true end

function modifier_ghost_soul_assumption_counter:IsPurgable() return false end
