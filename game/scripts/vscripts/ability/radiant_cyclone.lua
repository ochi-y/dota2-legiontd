LinkLuaModifier("modifier_radiant_cyclone", "ability/radiant_cyclone.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_radiant_cyclone_effect", "ability/radiant_cyclone.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_radiant_cyclone_cooldown", "ability/radiant_cyclone.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if radiant_cyclone == nil then
	radiant_cyclone = class({})
end
function radiant_cyclone:GetIntrinsicModifierName()
	return "modifier_radiant_cyclone"
end

function radiant_cyclone:OnSpellStart()
	local hCaster = self:GetCaster()
	local hTarget = self:GetCursorTarget()

	if hTarget:GetTeam() ~= hCaster:GetTeam() then
		if hTarget:TriggerSpellAbsorb(self) then
			return nil
		end
	end
	if hCaster:GetTeamNumber() ~= hTarget:GetTeamNumber() then
		hTarget:Purge(true, false, false, false, false)
	else
		hCaster:Purge(false, true, false, false, false)
	end

	hTarget:InterruptMotionControllers(true)
	-- hTarget:AddNewModifier(hCaster, self, "modifier_radiant_cyclone_effect",
	-- 	{ duration = self:GetSpecialValueFor("cyclone_duration") })

	EmitSoundOn("DOTA_Item.Cyclone.Activate", hTarget)

	hTarget:AddNewModifier(hCaster, self, "modifier_radiant_cyclone_effect",
		{ duration = self:GetSpecialValueFor("duration_unit") })

	hTarget:AddNewModifier(hCaster, self, "modifier_radiant_cyclone_cooldown",
		{ duration = self:GetSpecialValueFor("buff_cooldown") })
end

function radiant_cyclone:CastFilterResultTarget(target)
	local default_result = self.BaseClass.CastFilterResultTarget(self, target)
	if default_result ~= UF_SUCCESS then
		return default_result
	end

	if target:GetTeamNumber() == self:GetCaster():GetTeamNumber() then
		if target == self:GetCaster() then
			return UF_SUCCESS
		else
			return UF_FAIL_FRIENDLY
		end
	end
	return UF_SUCCESS
end

-------------------------------------------------------------------------------------------------------
-- modifier   ---------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
modifier_radiant_cyclone = class({
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
		return MODIFIER_ATTRIBUTE_MULTIPLE
	end
})
function modifier_radiant_cyclone:AllowIllusionDuplicate()
	return false
end

function modifier_radiant_cyclone:OnCreated(params)
	if not self:GetAbility() then return end
	local ability = self:GetAbility()
	self.bonus_intellect = ability:GetSpecialValueFor("bonus_intellect")
	self.bonus_mana_regen = ability:GetSpecialValueFor("bonus_mana_regen")
	self.bonus_movement_speed = ability:GetSpecialValueFor("bonus_movement_speed")
	if not IsServer() then return end
	self.parent = self:GetParent()
	addManaRegenPct(self.parent, self.bonus_mana_regen)
end

function modifier_radiant_cyclone:OnDestroy(params)
	if not IsServer() then return end
	removeManaRegenPct(self.parent, self.bonus_mana_regen)
end

function modifier_radiant_cyclone:OnRefresh(params)

end

function modifier_radiant_cyclone:DeclareFunctions()
	return {
		-- MODIFIER_PROPERTY_MP_REGEN_AMPLIFY_PERCENTAGE,
		-- MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		-- MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT
	}
end

function modifier_radiant_cyclone:GetModifierBonusStats_Intellect()
	return self.bonus_intellect
end

function modifier_radiant_cyclone:GetModifierMPRegenAmplify_Percentage()
	return self.bonus_mana_regen
end

function modifier_radiant_cyclone:GetModifierMoveSpeedBonus_Constant()
	return self.bonus_movement_speed
end

modifier_radiant_cyclone_effect = class({})

function modifier_radiant_cyclone_effect:IsDebuff()
	return self:GetCaster():GetTeamNumber() ~=
		self:GetParent():GetTeamNumber()
end

function modifier_radiant_cyclone_effect:IsHidden() return false end

function modifier_radiant_cyclone_effect:IsPurgable() return true end

function modifier_radiant_cyclone_effect:IsStunDebuff() return false end

function modifier_radiant_cyclone_effect:IsMotionController() return true end

function modifier_radiant_cyclone_effect:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_HIGH end

function modifier_radiant_cyclone_effect:OnCreated()
	self:StartIntervalThink(FrameTime())

	if IsServer() then
		-- self:GetParent():StartGesture(ACT_DOTA_FLAIL)
		self.angle = self:GetParent():GetAngles()
		self.abs = self:GetParent():GetAbsOrigin()
		self.cyc_pos = self:GetParent():GetAbsOrigin()

		self.pfx_name = "particles/items_fx/cyclone.vpcf"
		self.pfx_name = "particles/units/heroes/hero_brewmaster/brewmaster_cyclone.vpcf"
		self.pfx = ParticleManager:CreateParticle(self.pfx_name, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		-- ParticleManager:SetParticleControl(effect, 0, self:GetParent():GetAbsOrigin())

		ParticleManager:SetParticleControlEnt(self.pfx, 0, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, nil,
			self:GetParent():GetAbsOrigin(), true)
	end
end

function modifier_radiant_cyclone_effect:OnIntervalThink()
	self:HorizontalMotion(self:GetParent(), FrameTime())
end

function modifier_radiant_cyclone_effect:HorizontalMotion(unit, time)
	if not IsServer() then return end
	-- Change the Face Angle

	local upTime = 1
	local height = 300
	local upSpeed = height / upTime

	local angle = self:GetParent():GetAngles()
	local new_angle = RotateOrientation(angle, QAngle(0, 20, 0))
	self:GetParent():SetLocalAngles(new_angle[1], new_angle[2], new_angle[3])
	if self:GetElapsedTime() <= upTime then
		self.cyc_pos.z = self.cyc_pos.z + height * time
	elseif self:GetDuration() - self:GetElapsedTime() < upTime then
		self.step = self.step or
			(self.cyc_pos.z - self.abs.z) / ((self:GetDuration() - self:GetElapsedTime()) / FrameTime())
		self.cyc_pos.z = self.cyc_pos.z - self.step
	else
		local t = self:GetElapsedTime() - upTime
		local off = 5
		local block = t / 0.2
		off = math.sin(block) * off
		self.cyc_pos.z = self.cyc_pos.z + off
	end

	local t = self:GetElapsedTime()

	local moveRadius = 36
	self.cyc_pos.x = self.abs.x + math.sin(t * 5 * math.pi / 2.5) * moveRadius
	-- print(t,t*2*math.pi/2.5,math.sin(t*2*math.pi/2.5),self.cyc_pos.x-self.abs.x)
	self.cyc_pos.y = self.abs.y + math.sin(t * 6 * math.pi / 2.5) * moveRadius
	self:GetParent():SetAbsOrigin(self.cyc_pos)
end

function modifier_radiant_cyclone_effect:OnDestroy()
	StopSoundOn("DOTA_Item.Cyclone.Activate", self:GetParent())
	if not IsServer() then return end
	if self.pfx then
		ParticleManager:DestroyParticle(self.pfx, false)
		ParticleManager:ReleaseParticleIndex(self.pfx)
	end


	--self:GetParent():FadeGesture(ACT_DOTA_FLAIL)
	self:GetParent():SetAbsOrigin(self.abs)
	ResolveNPCPositions(self:GetParent():GetAbsOrigin(), 128)
	self:GetParent():SetAngles(self.angle[1], self.angle[2], self.angle[3])

	if self:GetCaster():GetTeamNumber() ~= self:GetParent():GetTeamNumber() then
		SimpleApplyDamage(self:GetAbility(), self:GetCaster(), self:GetParent(), 50)
	end
end

function modifier_radiant_cyclone_effect:CheckState()
	local state =
	{
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
	}
	return state
end

-------------------------------------------------------------------------------------------------------
-- modifier   ---------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
modifier_radiant_cyclone_cooldown = class({
	IsHidden = function(self)
		return false
	end,
	IsPurgable = function(self)
		return false
	end,
	IsDebuff = function(self)
		return true
	end,
	IsBuff = function(self)
		return false
	end,
	RemoveOnDeath = function(self)
		return true
	end,
	GetAttributes = function(self)
		return MODIFIER_ATTRIBUTE_NONE
	end
})
function modifier_radiant_cyclone_cooldown:AllowIllusionDuplicate()
	return false
end

function modifier_radiant_cyclone_cooldown:OnCreated(params)
	if not self:GetAbility() then return end
	local ability = self:GetAbility()
	if not IsServer() then return end
end

function modifier_radiant_cyclone_cooldown:OnRefresh(params)
	self:OnCreated(params)
end

function modifier_radiant_cyclone_cooldown:DeclareFunctions()
	return {

	}
end

function modifier_radiant_cyclone_cooldown:CheckState()
	local state = {
	}

	return state
end
