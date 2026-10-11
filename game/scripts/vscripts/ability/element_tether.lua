element_tether = class({})
-- This modifier applies on Wisp and deals with giving the target heal and mana amp
LinkLuaModifier("modifier_element_tether", "ability/element_tether", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_element_tether_target", "ability/element_tether", LUA_MODIFIER_MOTION_NONE)

function element_tether:GetCustomCastErrorTarget(target)
	local caster = self:GetCaster()
	if target == caster then
		return "#Spells_CustomCastError_NOT_SELF"
	end
	return "#Spells_CustomCastError"
end

function element_tether:CastFilterResultTarget(target)
	local caster = self:GetCaster()
	if target == caster or target:GetTeamNumber() ~= caster:GetTeamNumber() then
		return UF_FAIL_CUSTOM
	end

	if target:HasModifier("modifier_element_tether_target") then
		return UF_FAIL_CUSTOM
	end
	return UF_SUCCESS
end

function element_tether:OnSpellStart()
	local ability = self
	local caster  = self:GetCaster()


	self.tether_ally = self:GetCursorTarget()
	self.target      = self:GetCursorTarget()

	self.range       = self:GetCastRangeBonus(caster, 0) + self:GetSpecialValueFor("radius") + 150

	-- local NetTable_key = self:GetCaster():GetEntityIndex().."_element_tether_cast_range"
	-- -- print(NetTable_key)
	-- CustomNetTables:SetTableValue( "spell_info", NetTable_key, {range =self.range-150 } )  -- update the net table


	caster:RemoveModifierByName("modifier_element_tether")

	caster:AddNewModifier(self.target, self, "modifier_element_tether", {})

	self.target:AddNewModifier(caster, self, "modifier_element_tether_target", {})


	-- local ability = caster:FindAbilityByName("element_tether_break")
	-- ability:SetLevel(1)
	-- ability:StartCooldown(0.25)
	-- ability.father_spell = self
end

---------------------
-- TETHER MODIFIER --
---------------------

modifier_element_tether = class({})

function modifier_element_tether:IsHidden() return false end

function modifier_element_tether:IsPurgable() return false end

function modifier_element_tether:GetPriority() return MODIFIER_PRIORITY_SUPER_ULTRA end

function modifier_element_tether:OnCreated(params)
	if not self:GetAbility() then return end

	self.target = self:GetCaster()

	if IsServer() then
		self.radius          = self:GetAbility().range
		self.tether_heal_amp = self:GetAbility():GetSpecialValueFor("tether_heal_amp")

		self.update_timer    = 0
		self.time_to_send    = 1 -- interval between restore messages
		self:GetCaster():EmitSound("Hero_Wisp.Tether")

		self.pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_wisp/wisp_tether.vpcf",
			PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
		ParticleManager:SetParticleControlEnt(self.pfx, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc",
			self:GetCaster():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(self.pfx, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc",
			self:GetParent():GetAbsOrigin(), true)

		EmitSoundOn("Hero_Wisp.Tether.Target", self:GetParent())
	end

	self:StartIntervalThink(FrameTime())
end

function modifier_element_tether:OnIntervalThink()
	self.difference = 0

	self.bonus_move_speed = self:GetAbility():GetSpecialValueFor("bonus_move_speed")
	if not IsServer() then return end
	local caster = self:GetAbility():GetCaster()
	-- print(self:GetAbility():GetCastRangeBonus(caster))
	-- Drop the state when the ability or the target is gone
	if not self:GetAbility() or not self:GetAbility().tether_ally then
		self:Destroy()
		return
	end

	self.update_timer = self.update_timer + FrameTime()



	-- Report the restore bonus once per second
	if self.update_timer > self.time_to_send then
		local heal = caster:GetHealthRegen() * self.tether_heal_amp
		local mana_gain = caster:GetManaRegen() * self.tether_heal_amp
		-- print(caster:GetHealthRegen())
		-- print(mana_gain)

		-- local healing = HealWithGain(heal, caster, self.target, self:GetAbility())
		self.target:HealWithParams(heal, self:GetAbility(), false, true, caster, false)
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, self.target, heal, nil)
		-- SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, self.target, self.total_gained_health, nil)	
		self.target:GiveMana(mana_gain)
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_MANA_ADD, self.target, mana_gain, nil)

		self.update_timer = 0
	end


	if (self:GetParent():IsOutOfGame()) or not self.target:IsAlive() or not self:GetParent():IsAlive() then -- interrupt
		self:GetParent():RemoveModifierByName("modifier_element_tether")
		return
	end

	if (self:GetAbility().tether_ally:GetAbsOrigin() - self:GetParent():GetAbsOrigin()):Length2D() <= self.radius then
		return
	end

	self:GetParent():RemoveModifierByName("modifier_element_tether")
end

function modifier_element_tether:DeclareFunctions()
	local decFuncs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		-- MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,
		MODIFIER_EVENT_ON_HEAL_RECEIVED,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}

	return decFuncs
end

function modifier_element_tether:GetModifierMoveSpeedBonus_Percentage()
	return self.movespeed
end

function modifier_element_tether:GetModifierMoveSpeedBonus_Constant()
	return self.bonus_move_speed
end

-- function modifier_element_tether:GetModifierMoveSpeed_Limit()
-- 	return self.target_speed
-- end

-- function modifier_element_tether:GetModifierIgnoreMovespeedLimit()
-- 	return 1
-- end
function modifier_element_tether:OnHealReceived(keys)
	if keys.unit == self:GetParent() then
		local inflictor = keys.inflictor

		local parent = self:GetParent()
		local caster = self:GetCaster()

		if inflictor and inflictor:GetAbilityName() ~= "element_tether" then
			local gain = keys.gain
			caster:HealWithParams(gain, self:GetAbility(), false, true, parent, false)
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, self.target, gain, nil)
		end

		-- local parent=self:GetParent()

		-- print("-------------------",self:GetRemainingTime())
		-- if inflictor then
		-- 	print(inflictor:GetAbilityName())
		-- end
		-- PrintTable(keys)	

		-- PrintTable(keys)
	end
end

function modifier_element_tether:OnRemoved()
	if IsServer() then
		ParticleManager:DestroyParticle(self.pfx, false)
		self:GetCaster():EmitSound("Hero_Wisp.Tether.Stop")
		self:GetCaster():StopSound("Hero_Wisp.Tether")
		self:GetCaster():RemoveModifierByName("modifier_element_tether_target")
	end
end

-------------------------------------------------------------------------------------------------------
modifier_element_tether_target = class({
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
function modifier_element_tether_target:AllowIllusionDuplicate()
	return false
end

function modifier_element_tether_target:OnCreated(params)
	if not self:GetAbility() then return end
	local ability = self:GetAbility()
	self.movespeed = ability:GetSpecialValueFor("movespeed")
	if not IsServer() then return end
	-- self.damage = params.damage
	-- self:SetHasCustomTransmitterData(true)
end

function modifier_element_tether_target:OnRefresh(params)
	self:OnCreated(params)
end

function modifier_element_tether_target:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
end

function modifier_element_tether_target:GetModifierMoveSpeedBonus_Percentage()
	return self.movespeed
end

-- element_tether_break = class({})

-- function element_tether_break:OnSpellStart()
-- 	self:GetCaster():RemoveModifierByName("modifier_element_tether")
-- end

-- function element_tether_break:GetCastRange()
-- 	-- grab the cast range at cast time
-- 	local NetTable_key = self:GetCaster():GetEntityIndex() .. "_element_tether_cast_range"
-- 	local range = CustomNetTables:GetTableValue("spell_info", NetTable_key).range
-- 	local caster = self:GetCaster()
-- 	return range - caster:GetCastRangeBonus()
-- end

-- the style above works better
-- function element_tether_break:GetCastRangeBonus(caster)
-- 	return 0
-- end
