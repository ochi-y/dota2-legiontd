undead_arctic_burn = class({})
LinkLuaModifier("modifier_undead_arctic_burn", "ability/undead_arctic_burn", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_undead_arctic_burn_debuff", "ability/undead_arctic_burn", LUA_MODIFIER_MOTION_NONE)

----------------------------------------------------------------------------------------

function undead_arctic_burn:Precache(context)
	PrecacheResource("particle", "particles/units/heroes/hero_winter_wyvern/wyvern_arctic_burn_start.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_winter_wyvern/wyvern_arctic_burn_hero_effect.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_winter_wyvern/wyvern_splinter_blast_slow.vpcf", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_winter_wyvern.vsndevts", context)
end

-----------------------------------------------------------------------

-- function undead_arctic_burn:ProcsMagicStick()
-- 	return false
-- end

--------------------------------------------------------------------------------

function undead_arctic_burn:OnSpellStart()
	if IsServer() then
		self:GetCaster():Purge(false, true, false, true, false)

		EmitSoundOn("Hero_Winter_Wyvern.ArcticBurn.Cast", self:GetCaster())

		local nFXIndex = ParticleManager:CreateParticle(
			"particles/units/heroes/hero_winter_wyvern/wyvern_arctic_burn_start.vpcf", PATTACH_CUSTOMORIGIN,
			self:GetCaster())
		ParticleManager:SetParticleControlEnt(nFXIndex, 0, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, nil,
			self:GetCaster():GetOrigin(), true)
		ParticleManager:ReleaseParticleIndex(nFXIndex)

		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_undead_arctic_burn", {
			duration = self:GetSpecialValueFor("duration")
		})
	end
end

-----------------------------------------------------------------------
modifier_undead_arctic_burn = class({})

-----------------------------------------------------------------------

function modifier_undead_arctic_burn:IsHidden()
	return false
end

-----------------------------------------------------------------------

function modifier_undead_arctic_burn:IsPurgable()
	return false
end

-----------------------------------------------------------------------

function modifier_undead_arctic_burn:OnCreated(kv)
	if not self:GetAbility() then return end

	self.attack_range_bonus = self:GetAbility():GetSpecialValueFor("attack_range_bonus")
	self.projectile_speed_bonus = self:GetAbility():GetSpecialValueFor("projectile_speed_bonus")
	self.attack_point = self:GetAbility():GetSpecialValueFor("attack_point")
	self.damage_duration = self:GetAbility():GetSpecialValueFor("damage_duration")
	self.attack_point = self:GetAbility():GetSpecialValueFor("attack_point")



	if IsServer() then
		self:GetParent():StartGesture(ACT_DOTA_CAST_ABILITY_1)

		local nFXIndex = ParticleManager:CreateParticle(
			"particles/units/heroes/hero_winter_wyvern/wyvern_arctic_burn_buff.vpcf", PATTACH_CUSTOMORIGIN,
			self:GetParent());
		ParticleManager:SetParticleControlEnt(nFXIndex, 0, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, nil,
			self:GetParent():GetOrigin(), true);
		ParticleManager:SetParticleControlEnt(nFXIndex, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc",
			self:GetParent():GetOrigin(), true);
		ParticleManager:SetParticleControlEnt(nFXIndex, 2, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1",
			self:GetParent():GetOrigin(), true);
		ParticleManager:SetParticleControlEnt(nFXIndex, 3, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_eye_l",
			self:GetParent():GetOrigin(), true);
		ParticleManager:SetParticleControlEnt(nFXIndex, 4, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_eye_r",
			self:GetParent():GetOrigin(), true);
		self:AddParticle(nFXIndex, false, false, -1, false, false);

		if self:GetCaster() == self:GetParent() then
			local nFXIndexB = ParticleManager:CreateParticle(
				"particles/units/heroes/hero_winter_wyvern/wyvern_arctic_burn_flying.vpcf", PATTACH_CUSTOMORIGIN,
				self:GetParent());
			ParticleManager:SetParticleControlEnt(nFXIndexB, 0, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, nil,
				self:GetParent():GetOrigin(), true);
			ParticleManager:SetParticleControlEnt(nFXIndexB, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_spine_1",
				self:GetParent():GetOrigin(), true);
			ParticleManager:SetParticleControlEnt(nFXIndexB, 2, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_spine_2",
				self:GetParent():GetOrigin(), true);
			ParticleManager:SetParticleControlEnt(nFXIndexB, 3, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_spine_3",
				self:GetParent():GetOrigin(), true);
			ParticleManager:SetParticleControlEnt(nFXIndexB, 4, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_spine_4",
				self:GetParent():GetOrigin(), true);
			ParticleManager:SetParticleControlEnt(nFXIndexB, 5, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_spine_5",
				self:GetParent():GetOrigin(), true);
			self:AddParticle(nFXIndexB, false, false, -1, false, false);
		end
	end
end

-----------------------------------------------------------------------

-- function modifier_undead_arctic_burn:GetModifierMoveSpeed_Absolute( params )
-- 	if IsServer() then
-- 		if self:GetParent().numEggsKilled ~= nil then
-- 			return self.flight_speed + ( self:GetParent().numEggsKilled * self.per_egg_speed )
-- 		end
-- 	end
-- 	return self.flight_speed
-- end

-----------------------------------------------------------------------

-- function modifier_undead_arctic_burn:GetModifierMoveSpeed_Max( params )
-- 	if IsServer() then
-- 		if self:GetParent().numEggsKilled ~= nil then
-- 			return self.flight_speed + ( self:GetParent().numEggsKilled * self.per_egg_speed )
-- 		end
-- 	end
-- 	return self.flight_speed
-- end

-----------------------------------------------------------------------

function modifier_undead_arctic_burn:GetVisualZDelta(params)
	return 300
end

--------------------------------------------------------------------------------

function modifier_undead_arctic_burn:GetActivityTranslationModifiers(params)
	return "flying"
end

-----------------------------------------------------------------------

function modifier_undead_arctic_burn:DeclareFunctions()
	local funcs =
	{
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
		--	MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
		--	MODIFIER_PROPERTY_MOVESPEED_MAX,
		MODIFIER_PROPERTY_VISUAL_Z_DELTA,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_PROPERTY_PROJECTILE_SPEED_BONUS,
		MODIFIER_PROPERTY_PROJECTILE_NAME,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_ATTACK_POINT_CONSTANT

	}
	return funcs
end

function modifier_undead_arctic_burn:OnAttackLanded(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	local target = params.target
	if SimpleUnitFilter(self:GetAbility(),target) then
		target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_undead_arctic_burn_debuff", {
			duration = self.damage_duration
		})	
	end
end

-----------------------------------------------------------------------
function modifier_undead_arctic_burn:GetModifierAttackRangeBonus()
	return self.attack_range_bonus
end

function modifier_undead_arctic_burn:GetModifierAttackPointConstant()
	return self.attack_point
end

-----------------------------------------------------------------------
function modifier_undead_arctic_burn:GetModifierProjectileSpeedBonus()
	return self.projectile_speed_bonus
end

function modifier_undead_arctic_burn:GetHeroEffectName()
	return "particles/units/heroes/hero_winter_wyvern/wyvern_arctic_burn_hero_effect.vpcf"
end

function modifier_undead_arctic_burn:GetModifierProjectileName()
	return "particles/units/heroes/hero_winter_wyvern/winter_wyvern_arctic_attack.vpcf"
end

-----------------------------------------------------------------------

function modifier_undead_arctic_burn:CheckState()
	local state =
	{
		--	[MODIFIER_STATE_FLYING] = true,
		--	[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		--	[MODIFIER_STATE_DISARMED] = true,
		--	[MODIFIER_STATE_UNSELECTABLE] = true,
		--	[MODIFIER_STATE_INVULNERABLE] = true,
	}
	return state
end

-------------------------------------------------------------------------------------------------------
modifier_undead_arctic_burn_debuff = class({
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
function modifier_undead_arctic_burn_debuff:AllowIllusionDuplicate()
	return false
end

function modifier_undead_arctic_burn_debuff:OnCreated(params)
	if not self:GetAbility() then return end
	local ability = self:GetAbility()
	self.tick_rate = ability:GetSpecialValueFor("tick_rate")
	self.percent_damage = ability:GetSpecialValueFor("percent_damage")
	self.boss_percent_damage = ability:GetSpecialValueFor("boss_percent_damage")
	
	self.move_slow = ability:GetSpecialValueFor("move_slow")
	if not IsServer() then return end
	self:StartIntervalThink(self.tick_rate)

	
	self.damageTable = {
		victim = self:GetParent(),
		attacker = self:GetCaster(),
		damage = 0,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self:GetAbility(), --Optional.
		damage_flags = 0,      --Optional.
	}
	self:OnIntervalThink()
end

function modifier_undead_arctic_burn_debuff:OnRefresh(params)
	self:OnCreated(params)
end

function modifier_undead_arctic_burn_debuff:OnIntervalThink(params)
	local caster = self:GetCaster()
	local parent = self:GetParent()


	local damage = math.floor(parent:GetHealth() * self.percent_damage / 100)

	if parent:IsAncient() then
		damage = math.floor(parent:GetHealth() * self.boss_percent_damage / 100)
	end


	self.damageTable.damage = damage
	ApplyDamage(self.damageTable)

	SendOverheadEventMessage(
		nil,
		OVERHEAD_ALERT_BONUS_SPELL_DAMAGE,
		parent,
		damage,
		caster:GetPlayerOwner()
	)
end

function modifier_undead_arctic_burn_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
end

function modifier_undead_arctic_burn_debuff:GetModifierMoveSpeedBonus_Percentage()
	return -self.move_slow
end

function modifier_undead_arctic_burn_debuff:GetEffectName()
	return "particles/units/heroes/hero_winter_wyvern/wyvern_arctic_burn_slow.vpcf"
end
function modifier_undead_arctic_burn_debuff:GetEffectAttachType()
	return PATTACH_POINT_FOLLOW
end
function modifier_undead_arctic_burn_debuff:GetStatusEffectName()
	return "particles/status_fx/status_effect_wyvern_arctic_burn.vpcf"
end
function modifier_undead_arctic_burn_debuff:StatusEffectPriority()
	return 3
end