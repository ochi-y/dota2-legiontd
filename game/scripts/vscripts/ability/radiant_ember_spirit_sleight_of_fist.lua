LinkLuaModifier("modifier_radiant_ember_spirit_sleight_of_fist", "ability/radiant_ember_spirit_sleight_of_fist",
	LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_radiant_ember_spirit_sleight_of_fist_invulnerability",
	"ability/radiant_ember_spirit_sleight_of_fist", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_radiant_ember_spirit_sleight_of_fist_marker", "ability/radiant_ember_spirit_sleight_of_fist",
	LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_radiant_ember_spirit_sleight_of_fist_disarmed", "ability/radiant_ember_spirit_sleight_of_fist",
	LUA_MODIFIER_MOTION_NONE)



--Abilities
if radiant_ember_spirit_sleight_of_fist == nil then
	radiant_ember_spirit_sleight_of_fist = class({})
end
function radiant_ember_spirit_sleight_of_fist:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function radiant_ember_spirit_sleight_of_fist:OnSpellStart()
	local hCaster = self:GetCaster()

	local vPosition = self:GetCursorPosition()
	local radius = self:GetSpecialValueFor("radius")

	-- local iParticleID = ParticleManager:CreateParticle(
	-- 	ParticleManager:GetParticleReplacement(
	-- 		"particles/units/heroes/hero_ember_spirit/ember_spirit_sleight_of_fist_cast.vpcf", hCaster),
	-- 	PATTACH_CUSTOMORIGIN,
	-- 	nil)
	-- ParticleManager:SetParticleControl(iParticleID, 0, vPosition)
	-- ParticleManager:SetParticleControl(iParticleID, 1, Vector(radius, radius, radius))
	-- ParticleManager:ReleaseParticleIndex(iParticleID)

	hCaster:AddNewModifier(hCaster, self, "modifier_radiant_ember_spirit_sleight_of_fist",
		{ position = vPosition, duration = 10 })

	hCaster:EmitSound("Hero_EmberSpirit.SleightOfFist.Cast")
end

function radiant_ember_spirit_sleight_of_fist:IsHiddenWhenStolen()
	return false
end

---------------------------------------------------------------------
if modifier_radiant_ember_spirit_sleight_of_fist == nil then
	modifier_radiant_ember_spirit_sleight_of_fist = class({})
end
function modifier_radiant_ember_spirit_sleight_of_fist:IsHidden() return false end

function modifier_radiant_ember_spirit_sleight_of_fist:IsDebuff() return false end

function modifier_radiant_ember_spirit_sleight_of_fist:IsPurgable() return false end

function modifier_radiant_ember_spirit_sleight_of_fist:IsPurgeException() return false end

function modifier_radiant_ember_spirit_sleight_of_fist:IsStunDebuff() return false end

function modifier_radiant_ember_spirit_sleight_of_fist:AllowIllusionDuplicate() return false end

function modifier_radiant_ember_spirit_sleight_of_fist:OnCreated(params)
	self.radius = self:GetAbility():GetSpecialValueFor("radius")
	self.bonus_hero_damage = self:GetAbility():GetSpecialValueFor("bonus_hero_damage")
	self.attack_interval = self:GetAbility():GetSpecialValueFor("attack_interval")
	self.creep_damage_penalty = self:GetAbility():GetSpecialValueFor("creep_damage_penalty")
	self.max_units = self:GetAbility():GetSpecialValueFor("max_units")
	-- self.imba_reduce_cooldown = self:GetAbility():GetSpecialValueFor("imba_reduce_cooldown")

	if IsServer() then
		local vPosition = StringToVector(params.position)
		local hCaster = self:GetParent()
		local hAbility = self:GetAbility()

		self.tTargets = FindUnitsInRadius(hCaster:GetTeamNumber(), vPosition, nil, self.radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_HERO,
			DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NO_INVIS +
			DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE, FIND_CLOSEST, false)

		if #self.tTargets > 0 then
			self.tTargets=subrange(self.tTargets,1,self.max_units)
			self.vStartPosition = hCaster:GetAbsOrigin()
			hAbility:SetActivated(false)

			hCaster:InterruptMotionControllers(true)
			hCaster:AddNewModifier(hCaster, hAbility, "modifier_radiant_ember_spirit_sleight_of_fist_invulnerability",
				nil)
			hCaster:AddNewModifier(hCaster, hAbility, "modifier_radiant_ember_spirit_sleight_of_fist_disarmed", nil)

			local iParticleID = ParticleManager:CreateParticle(
				"particles/units/heroes/hero_ember_spirit/ember_spirit_sleight_of_fist_caster.vpcf",
				PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControl(iParticleID, 0, self.vStartPosition)
			ParticleManager:SetParticleControlEnt(iParticleID, 1, hCaster, PATTACH_CUSTOMORIGIN_FOLLOW, nil,
				self.vStartPosition, true)
			ParticleManager:SetParticleControlForward(iParticleID, 1, hCaster:GetForwardVector())
			self:AddParticle(iParticleID, false, false, -1, false, false)



			for _, hTarget in pairs(self.tTargets) do
				hTarget:AddNewModifier(hCaster, hAbility, "modifier_radiant_ember_spirit_sleight_of_fist_marker", {})
			end

			self:OnIntervalThink()
			self:StartIntervalThink(self.attack_interval)
		else
			self:Destroy()
		end
	end
end

function modifier_radiant_ember_spirit_sleight_of_fist:OnRefresh(params)
	self.radius = self:GetAbility():GetSpecialValueFor("radius")
	self.bonus_hero_damage = self:GetAbility():GetSpecialValueFor("bonus_hero_damage")
	self.attack_interval = self:GetAbility():GetSpecialValueFor("attack_interval")
	-- self.imba_reduce_cooldown = self:GetAbility():GetSpecialValueFor("imba_reduce_cooldown")
end

function modifier_radiant_ember_spirit_sleight_of_fist:OnDestroy()
	if IsServer() then
		local hCaster = self:GetParent()
		local hAbility = self:GetAbility()


		if self.vStartPosition then
			local iParticleID = ParticleManager:CreateParticle(
				ParticleManager:GetParticleReplacement(
					"particles/units/heroes/hero_ember_spirit/ember_spirit_sleightoffist_trail.vpcf", hCaster),
				PATTACH_WORLDORIGIN, nil)
			ParticleManager:SetParticleControl(iParticleID, 0, hCaster:GetAbsOrigin())
			ParticleManager:SetParticleControl(iParticleID, 1, self.vStartPosition)
			ParticleManager:ReleaseParticleIndex(iParticleID)
			FindClearSpaceForUnit(hCaster, self.vStartPosition, true)
		end

		hCaster:RemoveModifierByName("modifier_radiant_ember_spirit_sleight_of_fist_disarmed")
		hCaster:RemoveModifierByName("modifier_radiant_ember_spirit_sleight_of_fist_invulnerability")

		for i = #self.tTargets, 1, -1 do
			local _hTarget = self.tTargets[i]
			table.remove(self.tTargets, i)
			if IsValid(_hTarget) then
				_hTarget:RemoveModifierByName("modifier_radiant_ember_spirit_sleight_of_fist_marker")
			end
		end
		if IsValid(hAbility) then
			hAbility:SetActivated(true)
		end
	end
end

function modifier_radiant_ember_spirit_sleight_of_fist:OnIntervalThink()
	if IsServer() then
		local hCaster = self:GetParent()
		local hAbility = self:GetAbility()
		local vCasterPosition = hCaster:GetAbsOrigin()

		if not IsValid(hAbility) then
			self:Destroy()
			return
		end

		local hTarget
		-- the commented out version attacks several times, not needed for now
		-- for i = #self.tTargets, 1, -1 do
		-- 	local _hTarget = self.tTargets[i]
		-- 	if IsValid(_hTarget) then
		-- 		if UnitFilter(_hTarget, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES+DOTA_UNIT_TARGET_FLAG_NO_INVIS+DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE, hCaster:GetTeamNumber()) == UF_SUCCESS then
		-- 			hTarget = _hTarget
		-- 			if self.imba_chance > RandomInt(0,100)  then
		-- 				_hTarget:RemoveModifierByName("modifier_radiant_ember_spirit_sleight_of_fist_marker")
		-- 				table.remove(self.tTargets, i)
		-- 			end
		-- 			break
		-- 		else
		-- 			_hTarget:RemoveModifierByName("modifier_radiant_ember_spirit_sleight_of_fist_marker")
		-- 		end
		-- 	end
		-- 	table.remove(self.tTargets, i)
		-- end

		for i = #self.tTargets, 1, -1 do
			local _hTarget = self.tTargets[i]
			-- pick a unit through the filter; break the loop on success, otherwise drop its modifier and entry
			if IsValid(_hTarget) then
				if UnitFilter(_hTarget, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE, hCaster:GetTeamNumber()) == UF_SUCCESS then
					hTarget = _hTarget
					_hTarget:RemoveModifierByName("modifier_radiant_ember_spirit_sleight_of_fist_marker")
					table.remove(self.tTargets, i)
					break
				else
					_hTarget:RemoveModifierByName("modifier_radiant_ember_spirit_sleight_of_fist_marker")
				end
			end
			table.remove(self.tTargets, i)
		end

		if not IsValid(hTarget) then
			self:Destroy()
			return
		end

		EmitSoundOnLocationWithCaster(hTarget:GetAbsOrigin(), "Hero_EmberSpirit.SleightOfFist.Damage", hCaster)

		local vTargetPosition = hTarget:GetAbsOrigin()
		local vDirection = vTargetPosition - self.vStartPosition
		vDirection.z = 0

		local vPosition = vTargetPosition - vDirection:Normalized() * 50

		hCaster:SetAbsOrigin(vPosition)

		local iParticleID = ParticleManager:CreateParticle(
			ParticleManager:GetParticleReplacement(
				"particles/units/heroes/hero_ember_spirit/ember_spirit_sleightoffist_trail.vpcf", hCaster),
			PATTACH_WORLDORIGIN,
			nil)
		ParticleManager:SetParticleControl(iParticleID, 0, vCasterPosition)
		ParticleManager:SetParticleControl(iParticleID, 1, vPosition)
		ParticleManager:ReleaseParticleIndex(iParticleID)

		local iParticleID = ParticleManager:CreateParticle(
			ParticleManager:GetParticleReplacement(
				"particles/units/heroes/hero_ember_spirit/ember_spirit_sleightoffist_tgt.vpcf", hCaster),
			PATTACH_CUSTOMORIGIN,
			hTarget)
		ParticleManager:SetParticleControlEnt(iParticleID, 0, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc",
			hTarget:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(iParticleID)

		hCaster:RemoveModifierByName("modifier_radiant_ember_spirit_sleight_of_fist_disarmed")
		if not hCaster:IsDisarmed() then
			self.bIsHero = hTarget:IsConsideredHero()
			hCaster:PerformAttack(hTarget, false, true, true, true, false, false, true)
			self.bIsHero = false
			local ability = self:GetCaster():FindAbilityByName("creeps_spell_Fire_Remnant")
			if hCaster.pattern_2 and hTarget:IsRealHero() then
				hCaster:SetCursorPosition(hTarget:GetAbsOrigin())
				ability:OnSpellStart()
			end
		end
		hCaster:AddNewModifier(hCaster, hAbility, "modifier_radiant_ember_spirit_sleight_of_fist_disarmed", nil)
	end
end

function modifier_radiant_ember_spirit_sleight_of_fist:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE
	}
end

function modifier_radiant_ember_spirit_sleight_of_fist:GetModifierTotalDamageOutgoing_Percentage(params)
	return self.creep_damage_penalty
end

function modifier_radiant_ember_spirit_sleight_of_fist:GetModifierPreAttack_BonusDamage(params)
	if IsServer() then
		if self.bIsHero == true then
			return self.bonus_hero_damage
		end
	end
	return 0
end

---------------------------------------------------------------------
if modifier_radiant_ember_spirit_sleight_of_fist_invulnerability == nil then
	modifier_radiant_ember_spirit_sleight_of_fist_invulnerability = class({})
end
function modifier_radiant_ember_spirit_sleight_of_fist_invulnerability:IsHidden() return true end

function modifier_radiant_ember_spirit_sleight_of_fist_invulnerability:IsDebuff() return false end

function modifier_radiant_ember_spirit_sleight_of_fist_invulnerability:IsPurgable() return false end

function modifier_radiant_ember_spirit_sleight_of_fist_invulnerability:IsPurgeException() return false end

function modifier_radiant_ember_spirit_sleight_of_fist_invulnerability:IsStunDebuff() return false end

function modifier_radiant_ember_spirit_sleight_of_fist_invulnerability:AllowIllusionDuplicate() return false end

function modifier_radiant_ember_spirit_sleight_of_fist_invulnerability:OnCreated(params)
	if IsServer() then
		self:GetParent():AddNoDraw() -- do not draw the model
	end
end

function modifier_radiant_ember_spirit_sleight_of_fist_invulnerability:OnDestroy()
	if IsServer() then
		self:GetParent():RemoveNoDraw()
		-- local ability = self:GetCaster():FindAbilityByName("creeps_spell_Activate_Fire_Remnant")
		-- self:GetCaster():SetCursorPosition(self:GetCaster():GetAbsOrigin())
		-- ability:OnSpellStart()
	end
end

function modifier_radiant_ember_spirit_sleight_of_fist_invulnerability:CheckState()
	return {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,          -- no collision
		[MODIFIER_STATE_INVULNERABLE] = true,               -- invulnerable
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,              -- do not draw the health bar
		[MODIFIER_STATE_UNSELECTABLE] = true,               -- not selectable
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true, -- flying
		[MODIFIER_STATE_SILENCED] = true,
	}
end

---------------------------------------------------------------------
if modifier_radiant_ember_spirit_sleight_of_fist_marker == nil then
	modifier_radiant_ember_spirit_sleight_of_fist_marker = class({})
end
function modifier_radiant_ember_spirit_sleight_of_fist_marker:IsHidden() return true end

function modifier_radiant_ember_spirit_sleight_of_fist_marker:IsDebuff() return false end

function modifier_radiant_ember_spirit_sleight_of_fist_marker:IsPurgable() return false end

function modifier_radiant_ember_spirit_sleight_of_fist_marker:IsPurgeException() return false end

function modifier_radiant_ember_spirit_sleight_of_fist_marker:IsStunDebuff() return false end

function modifier_radiant_ember_spirit_sleight_of_fist_marker:AllowIllusionDuplicate() return false end

function modifier_radiant_ember_spirit_sleight_of_fist_marker:GetEffectName()
	return "particles/units/heroes/hero_ember_spirit/ember_spirit_sleight_of_fist_targetted_marker.vpcf"
end

function modifier_radiant_ember_spirit_sleight_of_fist_marker:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

---------------------------------------------------------------------
if modifier_radiant_ember_spirit_sleight_of_fist_disarmed == nil then
	modifier_radiant_ember_spirit_sleight_of_fist_disarmed = class({})
end
function modifier_radiant_ember_spirit_sleight_of_fist_disarmed:IsHidden() return true end

function modifier_radiant_ember_spirit_sleight_of_fist_disarmed:IsDebuff() return false end

function modifier_radiant_ember_spirit_sleight_of_fist_disarmed:IsPurgable() return false end

function modifier_radiant_ember_spirit_sleight_of_fist_disarmed:IsPurgeException() return false end

function modifier_radiant_ember_spirit_sleight_of_fist_disarmed:IsStunDebuff() return false end

function modifier_radiant_ember_spirit_sleight_of_fist_disarmed:AllowIllusionDuplicate() return false end

function modifier_radiant_ember_spirit_sleight_of_fist_disarmed:CheckState()
	return {
		[MODIFIER_STATE_DISARMED] = true, -- disarmed
	}
end
