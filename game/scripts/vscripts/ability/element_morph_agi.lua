element_morph_agi = class({})
LinkLuaModifier("modifier_element_morph_agi", "ability/element_morph_agi", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_element_morph_agi_passive", "ability/element_morph_agi", LUA_MODIFIER_MOTION_NONE)


function element_morph_agi:OnToggle()
	-- Determine if the toggle is on or off and act on it
	if self:GetToggleState() then
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_element_morph_agi", {})
		self:GetCaster():EmitSound("Hero_Morphling.MorphAgility")

		-- Toggle the oppositie off
		if self:GetCaster():HasAbility("element_morph_str") and self:GetCaster():FindAbilityByName("element_morph_str"):GetToggleState() then
			self:GetCaster():FindAbilityByName("element_morph_str"):ToggleAbility()
		end
	else
		self:GetCaster():RemoveModifierByName("modifier_element_morph_agi")
		self:GetCaster():StopSound("Hero_Morphling.MorphAgility")
	end
end

function element_morph_agi:GetIntrinsicModifierName()
	return "modifier_element_morph_agi_passive"
end

modifier_element_morph_agi_passive = class({})

function modifier_element_morph_agi_passive:IsPermanent()
	return true
end

function modifier_element_morph_agi_passive:OnCreated()
	if not self:GetAbility() then return end
	local ability = self:GetAbility()
	self.points_per_tick = ability:GetSpecialValueFor("points_per_tick")

	if not IsServer() then return end
	self:SetStackCount(100)

	local caster = self:GetCaster()

	Timers:CreateTimer(FrameTime(), function()
		local meta = GamePlay:FighterGetMeta(caster.fighterId)
		local mod = caster:FindModifierByName("modifier_element_morph_agi_passive")
		if meta and mod then
			if meta.modifierStack["modifier_element_morph_agi_passive"] then
				mod:SetStackCount(meta.modifierStack["modifier_element_morph_agi_passive"])
			end
		end
	end)

	Timers:CreateTimer(1, function()
		caster:CalculateGenericBonuses()
	end)
	-- self:StartIntervalThink(1)
end

function modifier_element_morph_agi_passive:OnIntervalThink()
	if not IsServer() then return end

	if GamePlay.state~="in-round" then
		return
	end

	local ability = self:GetAbility()
	local caster = self:GetCaster()

	if self:GetStackCount() >= 170 then
		return
	end

	if not UTIL:checkUnitTag(caster, "modifier_element_morph_str_passive") then
		if not ability:GetToggleState() then
			ability:ToggleAbility()
		end
	end
end

function modifier_element_morph_agi_passive:OnRefresh()
	if not self:GetAbility() then return end
	local ability = self:GetAbility()
	self.points_per_tick = ability:GetSpecialValueFor("points_per_tick")
end

function modifier_element_morph_agi_passive:IsHidden()
	return true
end

function modifier_element_morph_agi_passive:DeclareFunctions()
	local funcs = {
		-- MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
		MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE,
	}
	return funcs
end

function modifier_element_morph_agi_passive:GetModifierAttackSpeedPercentage(params)
	return 1 * (self:GetStackCount() - 100)
end

function modifier_element_morph_agi_passive:GetModifierAttackSpeedBonus_Constant()
	return 1 * (self:GetStackCount() - 100)
	-- return self.points_per_tick * (self:GetStackCount() - 100)
	-- return -180
end

modifier_element_morph_agi = class({})

function modifier_element_morph_agi:OnCreated()
	if not self:GetAbility() then return end
	local ability = self:GetAbility()
	self.max_stack = ability:GetSpecialValueFor("max_stack")
	self.points_per_tick = ability:GetSpecialValueFor("points_per_tick")

	if IsServer() then
		local ability = self:GetAbility()
		local interval = ability:GetSpecialValueFor("morph_cooldown")
		self:StartIntervalThink(interval)
	end
end

function modifier_element_morph_agi:OnIntervalThink()
	-- Cancel if dead

	if not self:GetCaster():IsAlive() then
		self:GetAbility():ToggleAbility()
		return
	end

	local caster = self:GetCaster()
	local mana_per_tick = self:GetAbility():GetSpecialValueFor("mana_per_second") *
		self:GetAbility():GetSpecialValueFor("morph_cooldown")
	-- Check if the caster has mana
	if self:GetCaster():GetMana() < mana_per_tick then
		--self:GetAbility():ToggleAbility()
		return
	end
	local mod = caster:FindModifierByName("modifier_element_morph_agi_passive")

	if mod:GetStackCount() >= self.max_stack then
		self:GetAbility():ToggleAbility()
		return
	end
	-- Check if base stats are bigger than 1
	-- if self:GetCaster():GetBaseIntellect() <= 1 then
	-- 	--self:GetAbility():ToggleAbility() -- In the game it doesn't go off
	-- 	return
	-- end
	local ability = self:GetAbility()
	local interval = ability:GetSpecialValueFor("morph_cooldown")
	self:GetCaster():SpendMana(mana_per_tick, self:GetAbility())

	local oldHealth = caster:GetHealth()

	-- mod:IncrementStackCount()

	mod:SetStackCount(mod:GetStackCount() + self.points_per_tick)

	local strMod = caster:FindModifierByName("modifier_element_morph_str_passive")
	-- strMod:DecrementStackCount()
	strMod:SetStackCount(strMod:GetStackCount() - self.points_per_tick)
	caster:CalculateGenericBonuses()
	caster:ModifyHealth(math.max(1, oldHealth - 12 * self.points_per_tick), ability, false,
		DOTA_DAMAGE_FLAG_NO_DIRECTOR_EVENT + DOTA_DAMAGE_FLAG_HPLOSS)

	-- self:GetCaster():ModifyIntellect(-1)
	-- self:GetCaster():ModifyAgility(1)
	--self:GetCaster():ReduceMana(12) -- Reduce 12 mana ( Not sure if the % from the int reduction should be refunded)
end

function modifier_element_morph_agi:GetEffectName()
	return "particles/units/heroes/hero_morphling/morphling_morph_agi.vpcf"
end

function modifier_element_morph_agi:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

-- element_morph_str = class({})
-- LinkLuaModifier("modifier_morph_agi_int", "abilities/morphling_morph_agi_int", LUA_MODIFIER_MOTION_NONE)
-- LinkLuaModifier("modifier_morph_agi_int_passive", "abilities/morphling_morph_agi_int", LUA_MODIFIER_MOTION_NONE)

-- --[[function element_morph_str:OnUpgrade()
--   if self:GetCaster():HasAbility("element_morph_agi") then
--     self:GetCaster():FindAbilityByName("element_morph_agi"):SetLevel(self:GetLevel())
--   end
-- end]]

-- function element_morph_str:OnToggle()
-- 	-- Determine if the toggle is on or off and act on it
-- 	if self:GetToggleState() then
-- 		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_morph_agi_int", {})
-- 		self:GetCaster():EmitSound("Hero_Morphling.MorphStrength")
-- 	else
-- 		self:GetCaster():RemoveModifierByName("modifier_morph_agi_int")
-- 		self:GetCaster():StopSound("Hero_Morphling.MorphStrength")
-- 	end

-- 	-- Toggle the oppositie off
-- 	if self:GetCaster():HasAbility("element_morph_agi") and self:GetCaster():FindAbilityByName("element_morph_agi"):GetToggleState() then
-- 		self:GetCaster():FindAbilityByName("element_morph_agi"):ToggleAbility()
-- 	end
-- end

-- function element_morph_str:GetIntrinsicModifierName()
-- 	return "modifier_morph_agi_int_passive"
-- end

-- modifier_morph_agi_int_passive = class({})

-- function modifier_morph_agi_int_passive:IsPermanent()
-- 	return true
-- end

-- function modifier_morph_agi_int_passive:IsHidden()
-- 	return true
-- end

-- function modifier_morph_agi_int_passive:DeclareFunctions()
-- 	local funcs = {
-- 		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS
-- 	}
-- 	return funcs
-- end

-- function modifier_morph_agi_int_passive:GetModifierBonusStats_Intellect()
-- 	return self:GetAbility():GetSpecialValueFor("bonus_int")
-- end

-- modifier_morph_agi_int = class({})

-- function modifier_morph_agi_int:OnCreated()
-- 	if IsServer() then
-- 		local ability = self:GetAbility()
-- 		local interval = ability:GetSpecialValueFor("stats_per_second")

-- 		self:StartIntervalThink(interval)
-- 	end
-- end

-- function modifier_morph_agi_int:OnIntervalThink()
-- 	-- Cancel if dead
-- 	if not self:GetCaster():IsAlive() then
-- 		self:GetAbility():ToggleAbility()
-- 		return
-- 	end

-- 	local mana_per_tick = self:GetAbility():GetSpecialValueFor("mana_per_second") *
-- 	self:GetAbility():GetSpecialValueFor("stats_per_second")

-- 	-- Check if the caster has mana
-- 	if self:GetCaster():GetMana() < mana_per_tick then
-- 		--self:GetAbility():ToggleAbility()
-- 		return
-- 	end

-- 	-- Check if base stats are bigger than 1
-- 	if self:GetCaster():GetBaseAgility() <= 1 then
-- 		--self:GetAbility():ToggleAbility() -- In the game it doesn't go off
-- 		return
-- 	end

-- 	local ability = self:GetAbility()
-- 	local interval = ability:GetSpecialValueFor("stats_per_second")
-- 	self:GetCaster():SpendMana(mana_per_tick, self:GetAbility())
-- 	self:GetCaster():ModifyIntellect(1)
-- 	self:GetCaster():ModifyAgility(-1)
-- 	--self:GetCaster():GiveMana(12) -- Add 12 mana ( Not sure if the % from the int addition should be refunded)
-- end

-- function modifier_morph_agi_int:GetEffectName()
-- 	return "particles/morphling_morph_int.vpcf"
-- end

-- function modifier_morph_agi_int:GetEffectAttachType()
-- 	return PATTACH_ABSORIGIN_FOLLOW
-- end
