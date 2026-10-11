orc_shapeshift = class({})
LinkLuaModifier("modifier_orc_shapeshift_transform_stun", "ability/orc_shapeshift", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_orc_shapeshift_transform", "ability/orc_shapeshift", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_orc_shapeshift", "ability/orc_shapeshift", LUA_MODIFIER_MOTION_NONE)


function orc_shapeshift:OnSpellStart()
	-- Ability properties
	local caster = self:GetCaster()
	local ability = self

	-- Ability specials
	local transformation_time = 1.2
	local duration = ability:GetSpecialValueFor("duration")
	if caster:HasModifier("modifier_heroTalent_npc_dota_hero_lycan") then
		duration = duration * 2
	end

	-- Start transformation gesture
	caster:StartGesture(ACT_DOTA_OVERRIDE_ABILITY_4)



	local modifier = caster:FindModifierByName(caster.Form_MODIFIER_NAME)
	if modifier then
		modifier:Destroy()
	end
	caster.Form_MODIFIER_NAME = "modifier_orc_shapeshift_transform"

	-- Play cast sound
	EmitSoundOn("Hero_Lycan.Shapeshift.Cast", caster)

	-- Add cast particle effects
	local particle_cast_fx = ParticleManager:CreateParticle(
		"particles/units/heroes/hero_lycan/lycan_shapeshift_cast.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle_cast_fx, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle_cast_fx, 1, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle_cast_fx, 2, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle_cast_fx, 3, caster:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(particle_cast_fx)

	-- Disable Lycan for the transform duration
	caster:AddNewModifier(caster, ability, "modifier_orc_shapeshift_transform_stun", { duration = transformation_time })

	-- Wait the transformation time
	Timers:CreateTimer(transformation_time, function()
		-- Give Lycan transform buff
		caster:AddNewModifier(caster, ability, "modifier_orc_shapeshift_transform", { duration = duration })
	end)
end

modifier_orc_shapeshift_transform_stun = class({})

function modifier_orc_shapeshift_transform_stun:CheckState()
	local state = { [MODIFIER_STATE_STUNNED] = true }
	return state
end

function modifier_orc_shapeshift_transform_stun:IsHidden()
	return true
end

modifier_orc_shapeshift_transform = class({})
function modifier_orc_shapeshift_transform:IsHidden() return false end

function modifier_orc_shapeshift_transform:IsPurgable() return false end

function modifier_orc_shapeshift_transform:IsDebuff() return false end

function modifier_orc_shapeshift_transform:IsAura() return true end

function modifier_orc_shapeshift_transform:GetAuraDuration() return 0.1 end

function modifier_orc_shapeshift_transform:GetModifierAura() return "modifier_orc_shapeshift" end

function modifier_orc_shapeshift_transform:GetAuraRadius() return 1000 end

function modifier_orc_shapeshift_transform:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_INVULNERABLE end

function modifier_orc_shapeshift_transform:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end

function modifier_orc_shapeshift_transform:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end

function modifier_orc_shapeshift_transform:AllowIllusionDuplicate() return false end

function modifier_orc_shapeshift_transform:GetAuraEntityReject(target)
	if IsServer() then
		if target == self:GetParent() then
			return false
		end
		local parent = self:GetParent()

		if parent.wolfList then
			if TableContainsValue(parent.wolfList, target) then
				return false
			end
		end

		-- if target:GetUnitName()=="orc_blood_raider" or target:GetUnitName()=="orc_blood_wolf"  then
		-- 	return false
		-- end

		-- if target:IsRealHero() then
		-- 	if target == self.caster then
		-- 		return false
		-- 	end
		-- end

		-- if target:GetOwnerEntity() then
		-- 	if target:GetOwnerEntity() == self.caster then
		-- 		return false
		-- 	end
		-- end

		return true
	end
end

function modifier_orc_shapeshift_transform:DeclareFunctions()
	local decFuncs = {
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_PROPERTY_ATTACK_RANGE_BASE_OVERRIDE,
		MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND,
		MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS
	}
	return decFuncs
end

function modifier_orc_shapeshift_transform:GetModifierExtraHealthBonus()
	return self.health_bonus
end

function modifier_orc_shapeshift_transform:GetAttackSound()
	return "Lycan_Wolf.Attack"
end

function modifier_orc_shapeshift_transform:GetModifierModelScale()
	return 10
end

function modifier_orc_shapeshift_transform:GetModifierModelChange()
	-- if self:GetParent():HasModifier("modifier_heroTalent_npc_dota_hero_lycan") then
	-- 	return "models/items/lycan/ultimate/thegreatcalamityti4/thegreatcalamityti4.vmdl"
	-- end
	return "models/heroes/lycan/lycan_wolf.vmdl"
end

function modifier_orc_shapeshift_transform:OnCreated()
	if not self:GetAbility() then return end

	local ability = self:GetAbility()
	self.health_bonus = ability:GetSpecialValueFor("health_bonus")

	if IsServer() then
		self.caster = self:GetCaster()
		self.ability = self:GetAbility()
	end
end

function modifier_orc_shapeshift_transform:OnDestroy()
	if IsServer() then
		local particle_revert_fx = ParticleManager:CreateParticle(
			"particles/units/heroes/hero_lycan/lycan_shapeshift_revert.vpcf", PATTACH_ABSORIGIN, self:GetParent())
		ParticleManager:SetParticleControl(particle_revert_fx, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(particle_revert_fx, 3, self:GetParent():GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(particle_revert_fx)
	end
end

function modifier_orc_shapeshift_transform:GetModifierAttackRangeOverride() return 200 end

-- Speed/crit modifier
modifier_orc_shapeshift = class({})
function modifier_orc_shapeshift:IsHidden() return true end

function modifier_orc_shapeshift:IsPurgable() return false end

function modifier_orc_shapeshift:IsDebuff() return false end

function modifier_orc_shapeshift:OnCreated()
	-- Ability properties
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	self.parent = self:GetParent()
	self.certain_crit_buff = "modifier_orc_shapeshift_certain_crit"
	self.transform_buff = "modifier_orc_shapeshift_transform"

	-- Ability specials
	self.night_vision_bonus = self.ability:GetSpecialValueFor("night_vision_bonus")
	self.speed = self.ability:GetSpecialValueFor("speed")
	self.crit_chance = self.ability:GetSpecialValueFor("crit_chance")
	self.crit_damage = self.ability:GetSpecialValueFor("crit_multiplier")
	self.health_bonus = self.ability:GetSpecialValueFor("health_bonus")
end

function modifier_orc_shapeshift:GetEffectName()
	return "particles/units/heroes/hero_lycan/lycan_shapeshift_buff.vpcf"
end

function modifier_orc_shapeshift:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_orc_shapeshift:DeclareFunctions()
	local decFuncs = {
		MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN,
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,

		-- MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,   -- all damage bonus
	}
	return decFuncs
end

function modifier_orc_shapeshift:GetModifierPreAttack_CriticalStrike(params)
	if RandomInt(1, 100) <= self.crit_chance then
		return self.crit_damage
	end
end

function modifier_orc_shapeshift:GetBonusNightVision()
	return self.night_vision_bonus
end

function modifier_orc_shapeshift:GetModifierMoveSpeed_AbsoluteMin()
	return self.speed
end

-- function modifier_orc_shapeshift:GetModifierTotalDamageOutgoing_Percentage(keys)
-- 	if IsServer() then
-- 		if keys.attacker == self.parent and self.crit_chance >= RandomInt(1, 100) then
-- 			if keys.damage_category == DOTA_DAMAGE_CATEGORY_SPELL then
-- 				return
-- 			end
-- 			local particle = ParticleManager:CreateParticle(
-- 			"particles/units/heroes/hero_lycan/lycan_shapeshift_cast_e.vpcf", PATTACH_POINT_FOLLOW, keys.target)
-- 			local pos = keys.target:GetAbsOrigin()
-- 			pos.z = pos.z + 64
-- 			ParticleManager:SetParticleControl(particle, 3, pos)
-- 			ParticleManager:ReleaseParticleIndex(particle)
-- 			return self.crit_damage
-- 		end
-- 	end
-- 	return 0
-- end
