LinkLuaModifier("modifier_ability_overload", "ability/ability_overload", 0)
LinkLuaModifier("modifier_ability_overload_buff", "ability/ability_overload", 0)
LinkLuaModifier("modifier_ability_overload_debuff", "ability/ability_overload", 0)

ability_overload = class({
	GetIntrinsicModifierName = function() return "modifier_ability_overload" end
})


wave_25_champion_overload = ability_overload

radiant_overload = ability_overload

radiant_overload_less=ability_overload

modifier_ability_overload = class({
	IsHidden = function() return false end,
	DeclareFunctions = function()
		return {
			-- MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
			MODIFIER_EVENT_ON_ATTACK_LANDED 
		}
	end
})
function modifier_ability_overload:OnCreated(keys)
	local ability = self:GetAbility()
	self.hit_count = ability:GetSpecialValueFor("hit_count")
end

function modifier_ability_overload:OnRefresh(keys)
	local ability = self:GetAbility()
	self.hit_count = ability:GetSpecialValueFor("hit_count")
end

function modifier_ability_overload:OnAttackLanded(keys)
	if IsServer() then
		local parent = self:GetParent()
		local target = keys.target
		if keys.attacker == parent and target:GetTeam() ~= keys.attacker:GetTeam() and not target:IsBuilding() then
			self:IncrementStackCount()

			if self:GetStackCount() >= self.hit_count then
				parent:AddNewModifier(parent, self:GetAbility(), "modifier_ability_overload_buff", nil)
				-- parent:AddNewModifier(parent, self:GetAbility(), "modifier_ability_overload_buff", nil)
				self:SetStackCount(0)
			end
			-- if RandomInt(1, 100) <= self.chance then
			-- 	parent:AddNewModifier(parent, self:GetAbility(), "modifier_ability_overload_buff", nil)
			-- end
		end
	end
end

-- function modifier_ability_overload:OnAbilityFullyCast(keys)
-- 	if IsServer() then
-- 		local ability = keys.ability
-- 		if ability and ability:GetName() ~= "ability_capture" then
-- 			local parent = self:GetParent()

-- 			if keys.unit == parent and not parent:PassivesDisabled() then
-- 				if not (ability:IsItem() or ability:IsToggle()) then
-- 					if not parent:HasModifier("modifier_ability_overload_buff") then
-- 						parent:AddNewModifier(parent, self:GetAbility(), "modifier_ability_overload_buff", nil)
-- 					end
-- 				end
-- 			end
-- 		end
-- 	end
-- end

modifier_ability_overload_buff = class({
	IsPurgable = function() return false end,
	IsDebuff = function() return false end,
	IsBuff = function() return true end,
	RemoveOnDeath = function() return true end,
	DeclareFunctions = function()
		return {
			MODIFIER_EVENT_ON_ATTACK_LANDED,
			MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
			MODIFIER_PROPERTY_OVERRIDE_ANIMATION  
		}
	end,
	GetOverrideAnimation = function() return ACT_STORM_SPIRIT_OVERLOAD_RUN_OVERRIDE end
})

function modifier_ability_overload_buff:OnCreated()
	self.radius = self:GetAbility():GetSpecialValueFor("overload_aoe")
	self.damage = self:GetAbility():GetSpecialValueFor("overload_damage")
	self.max_units = self:GetAbility():GetSpecialValueFor("max_units")
	self.duration = self:GetAbility():GetSpecialValueFor("duration")


	if IsServer() then
		local parent = self:GetParent()
		local particle = "particles/units/heroes/hero_stormspirit/stormspirit_overload_ambient.vpcf"
		self.fx = ParticleManager:CreateParticle(particle, PATTACH_CUSTOMORIGIN, parent)
		ParticleManager:SetParticleControlEnt(self.fx, 0, parent, PATTACH_POINT_FOLLOW, "attach_attack1",
			parent:GetAbsOrigin(), true)
	end
end

function modifier_ability_overload_buff:OnDestroy()
	if IsServer() then
		ParticleManager:DestroyParticle(self.fx, false)
		ParticleManager:ReleaseParticleIndex(self.fx)
	end
end

function modifier_ability_overload_buff:OnAttackLanded(keys)
	if IsServer() then
		local parent = self:GetParent()
		local target = keys.target

		if keys.attacker == parent and target:GetTeam() ~= keys.attacker:GetTeam() and not target:IsBuilding() then
			local particle = "particles/units/heroes/hero_stormspirit/stormspirit_overload_discharge.vpcf"
			local fx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, parent)
			ParticleManager:SetParticleControl(fx, 0, target:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(fx)

			local enemies = FindUnitsInRadius(
				parent:GetTeamNumber(),
				target:GetAbsOrigin(),
				nil,
				self.radius,
				DOTA_UNIT_TARGET_TEAM_ENEMY,
				DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
				0,
				0,
				false
			)
			enemies=subrange(enemies,1,self.max_units)
			for _, enemy in pairs(enemies) do
				ApplyDamage({
					victim = enemy,
					attacker = keys.attacker,
					ability = self:GetAbility(),
					damage = self.damage,
					damage_type = self:GetAbility():GetAbilityDamageType()
				})

				enemy:AddNewModifier(parent, self:GetAbility(), "modifier_ability_overload_debuff", { duration = self.duration })
			end

			target:EmitSound("Hero_StormSpirit.Overload")

			self:Destroy()
		end
	end
end

function modifier_ability_overload_buff:GetActivityTranslationModifiers()
	if self:GetParent():GetName() == "npc_dota_hero_storm_spirit" then
		return "overload"
	end
	return 0
end

modifier_ability_overload_debuff = class({
	IsPurgable = function() return true end,
	IsDebuff = function() return true end,
	IsBuff = function() return false end,
	DeclareFunctions = function()
		return {
			MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
			MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE
		}
	end
})

function modifier_ability_overload_debuff:OnCreated()
	self.movespeed_slow = self:GetAbility():GetSpecialValueFor("overload_move_slow")
	self.attack_speed_slow = self:GetAbility():GetSpecialValueFor("overload_attack_slow")
end

function modifier_ability_overload_debuff:OnRefresh()
	self.movespeed_slow = self:GetAbility():GetSpecialValueFor("overload_move_slow")
	self.attack_speed_slow = self:GetAbility():GetSpecialValueFor("overload_attack_slow")
end

function modifier_ability_overload_debuff:GetModifierMoveSpeedBonus_Percentage()
	return -self.movespeed_slow
end

function modifier_ability_overload_debuff:GetModifierAttackSpeedPercentage()
	return -self.attack_speed_slow
end
