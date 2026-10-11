LinkLuaModifier("modifier_ability_gravekeepers_cloak", "ability/ability_gravekeepers_cloak", LUA_MODIFIER_MOTION_NONE)


ability_gravekeepers_cloak = class({})

wave_21_champion_gravekeepers_cloak=ability_gravekeepers_cloak


function ability_gravekeepers_cloak:GetIntrinsicModifierName()
	return "modifier_ability_gravekeepers_cloak"
end

function ability_gravekeepers_cloak:GetBehavior()
	return DOTA_ABILITY_BEHAVIOR_PASSIVE
end

modifier_ability_gravekeepers_cloak = class({})

function modifier_ability_gravekeepers_cloak:IsHidden() return false end

function modifier_ability_gravekeepers_cloak:IsDebuff() return false end

function modifier_ability_gravekeepers_cloak:IsPurgable() return false end

function modifier_ability_gravekeepers_cloak:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

function modifier_ability_gravekeepers_cloak:IsAura() return false end

function modifier_ability_gravekeepers_cloak:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("radius") end

function modifier_ability_gravekeepers_cloak:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end

function modifier_ability_gravekeepers_cloak:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end

function modifier_ability_gravekeepers_cloak:GetAuraSearchType() return DOTA_UNIT_TARGET_ALL end

function modifier_ability_gravekeepers_cloak:GetModifierAura() return "modifier_visage_gravekeepers_cloak_secondary_lua" end

function modifier_ability_gravekeepers_cloak:GetAuraEntityReject(hEntity)
	if not IsServer() then return false end
	-- reject if it's not familiar
	if hEntity:GetUnitName():find("npc_dota_visage_familiar") then
		return false
	end
	return true
end


function modifier_ability_gravekeepers_cloak:updateShieldParticle(isReduce)
	if not IsServer() then return end

	local parent = self:GetParent()
	if not parent or parent:IsNull() then return end

	local new_stack_count = self:GetStackCount()
	if new_stack_count and new_stack_count >= 0 then
		if isReduce then
			local cloak_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_visage/visage_cloak_lyr4.vpcf",
			PATTACH_ABSORIGIN_FOLLOW, parent)
			ParticleManager:ReleaseParticleIndex(cloak_pfx)
		end

		if not self.barrier_pfx then
			self.barrier_pfx = ParticleManager:CreateParticle(
			"particles/units/heroes/hero_visage/visage_cloak_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
		end

		if self.barrier_pfx then
			for i = 2, 5 do -- control points for rocks go from 2 to 5
				if new_stack_count >= (i - 1) then
					ParticleManager:SetParticleControl(self.barrier_pfx, i, Vector(1, 0, 0))
				else
					ParticleManager:SetParticleControl(self.barrier_pfx, i, Vector(0, 0, 0))
				end
			end
		end
	end
end
-- not working  
function modifier_ability_gravekeepers_cloak:OnStackCountChanged(old_stack_count)
	if IsServer() then return end
	-- local parent = self:GetParent()
	-- if not parent or parent:IsNull() then return end

	-- local new_stack_count = self:GetStackCount()
	-- if new_stack_count and new_stack_count > 0 then
	-- 	-- local cloak_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_visage/visage_cloak_lyr4.vpcf",
	-- 	-- 	PATTACH_ABSORIGIN_FOLLOW, parent)
	-- 	-- ParticleManager:ReleaseParticleIndex(cloak_pfx)

	-- 	if not self.barrier_pfx then
	-- 		self.barrier_pfx = ParticleManager:CreateParticle(
	-- 		"particles/units/heroes/hero_visage/visage_cloak_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
	-- 	end

	-- 	if self.barrier_pfx then
	-- 		for i = 2, 5 do -- control points for rocks go from 2 to 5
	-- 			if new_stack_count >= (i - 1) then
	-- 				ParticleManager:SetParticleControl(self.barrier_pfx, i, Vector(1, 0, 0))
	-- 			else
	-- 				ParticleManager:SetParticleControl(self.barrier_pfx, i, Vector(0, 0, 0))
	-- 			end
	-- 		end
	-- 	end
	-- end
end

function modifier_ability_gravekeepers_cloak:OnCreated()



	-- Unit identifier
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	if not caster or caster:IsNull() then return end
	if not ability or ability:IsNull() then return end
	local ability_level = ability:GetLevel() - 1

	-- Precache data
	self.max_layers = ability:GetSpecialValueFor("max_layers")
	self.damage_reduction = ability:GetLevelSpecialValueFor("damage_reduction", ability_level)
	self.recovery_time = ability:GetLevelSpecialValueFor("recovery_time", ability_level)
	self.minimum_damage = ability:GetSpecialValueFor("minimum_damage")
	self.radius = ability:GetSpecialValueFor("radius")

	self.bonus_armor = ability:GetSpecialValueFor("bonus_armor")

	self.bonus_magic_resistance = ability:GetSpecialValueFor("bonus_magic_resistance")


	if not IsServer() then return end


	-- Set to max stacks when ability is first learned
	if not self.initialize_stacks then
		self.initialize_stacks = true
		-- without timer OnStackCountChanged() doesn't get called
		Timers:CreateTimer(0.1, function()
			if self and not self:IsNull() then
				self:SetStackCount(self.max_layers)
				self:updateShieldParticle(false)
			end
		end)
	end

	if not self.listener then
		self.listener = ListenToGameEvent(
			"dota_player_learned_ability",
			Dynamic_Wrap(modifier_ability_gravekeepers_cloak, "OnPlayerLearnedAbility"),
			self
		)
	end
end

function modifier_ability_gravekeepers_cloak:OnRefresh()
	self:OnCreated()
end

function modifier_ability_gravekeepers_cloak:OnDestroy()
	if self.listener then
		StopListeningToGameEvent(self.listener)
	end
	self.initialize_stacks = nil

	if self.barrier_pfx then
		ParticleManager:DestroyParticle(self.barrier_pfx, false)
		ParticleManager:ReleaseParticleIndex(self.barrier_pfx)
		self.barrier_pfx = nil
	end
end

function modifier_ability_gravekeepers_cloak:OnPlayerLearnedAbility(keys)
	local caster = self:GetCaster()
	if not caster or caster:IsNull() then return end
	if keys.PlayerID ~= caster:GetPlayerOwnerID() then return end
end

function modifier_ability_gravekeepers_cloak:DeclareFunctions()
	return {
		-- MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}
end

function modifier_ability_gravekeepers_cloak:OnTakeDamage(k)
	local target = k.unit
	local caster = self:GetParent()
	local original_damage = k.original_damage
	local damage_type = k.damage_type
	if target == caster and k.damage > self.minimum_damage and self:GetStackCount() > 0 then
		self:DecrementStackCount()
		self:updateShieldParticle(true)
		Timers:CreateTimer(self.recovery_time, function()
			if self and not self:IsNull() then
				if self:GetStackCount() < self.max_layers then
					self:IncrementStackCount()
					self:updateShieldParticle(false)
				end
			end
		end)
	end
end

function modifier_ability_gravekeepers_cloak:GetModifierPhysicalArmorBonus()
	return self:GetStackCount() * self.bonus_armor
end

function modifier_ability_gravekeepers_cloak:GetModifierMagicalResistanceBonus()
	return self:GetStackCount() * self.bonus_magic_resistance
end

function modifier_ability_gravekeepers_cloak:GetModifierIncomingDamage_Percentage(keys)
	if not keys.target or keys.target:IsNull() then return end
	if not keys.attacker or keys.attacker:IsNull() then return end

	-- "Only reacts on damage instances that are greater than 40 (after all other reductions)."
	if keys.attacker == keys.target or keys.damage <= self.minimum_damage then return end

	if bit:_and(keys.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) == DOTA_DAMAGE_FLAG_HPLOSS then return end

	local stacks = self:GetStackCount()
	if stacks > 0 then
		self:DecrementStackCount()
		Timers:CreateTimer(self.recovery_time, function()
			if self and not self:IsNull() then
				if self:GetStackCount() < self.max_layers then
					self:IncrementStackCount()
				end
			end
		end)
	end
	return -(math.min(self.max_damage_reduction, self.damage_reduction * self:GetStackCount()))
end
