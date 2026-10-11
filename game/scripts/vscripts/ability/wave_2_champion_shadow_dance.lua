wave_2_champion_shadow_dance = class({})
LinkLuaModifier("modifier_wave_2_champion_shadow_dance", "ability/wave_2_champion_shadow_dance", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_wave_2_champion_shadow_dance_passive", "ability/wave_2_champion_shadow_dance",
	LUA_MODIFIER_MOTION_NONE)


ability_shadow_dance = wave_2_champion_shadow_dance

--------------------------------------------------------------------------------
-- Passive Modifier
function wave_2_champion_shadow_dance:GetIntrinsicModifierName()
	return "modifier_wave_2_champion_shadow_dance_passive"
end

--------------------------------------------------------------------------------
-- Custom KV
function wave_2_champion_shadow_dance:GetCooldown(level)
	return self.BaseClass.GetCooldown(self, level)
end

--------------------------------------------------------------------------------
-- Ability Start
function wave_2_champion_shadow_dance:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()

	-- load data
	local bDuration = self:GetSpecialValueFor("duration")

	-- Add modifier
	caster:AddNewModifier(
		caster,                            -- player source
		self,                              -- ability source
		"modifier_wave_2_champion_shadow_dance", -- modifier name
		{ duration = bDuration }           -- kv
	)
end

modifier_wave_2_champion_shadow_dance = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_wave_2_champion_shadow_dance:IsHidden()
	return false
end

function modifier_wave_2_champion_shadow_dance:IsDebuff()
	return false
end

function modifier_wave_2_champion_shadow_dance:IsPurgable()
	return false
end

function modifier_wave_2_champion_shadow_dance:GetPriority()
	return MODIFIER_PRIORITY_HIGH
end

--------------------------------------------------------------------------------
-- Aura
function modifier_wave_2_champion_shadow_dance:IsAura()
	return false
end

function modifier_wave_2_champion_shadow_dance:GetModifierAura()
	return "modifier_wave_2_champion_shadow_dance"
end

function modifier_wave_2_champion_shadow_dance:GetAuraRadius()
	return self.radius
end

function modifier_wave_2_champion_shadow_dance:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_wave_2_champion_shadow_dance:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO
end

function modifier_wave_2_champion_shadow_dance:GetAuraDuration()
	return 0.5
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_wave_2_champion_shadow_dance:OnCreated(kv)
	-- references

	-- generate data
	self.parent = self:GetParent() == self:GetCaster()

	if not IsServer() then return end
	self:PlayEffects1()
	self:PlayEffects2()

	self:StartIntervalThink(FrameTime())
end

function modifier_wave_2_champion_shadow_dance:OnRefresh(kv)
	-- references

	-- generate data
	self.parent = self:GetParent() == self:GetCaster()
end

function modifier_wave_2_champion_shadow_dance:OnDestroy(kv)
	if IsServer() then
		local sound_cast = "Hero_Slark.ShadowDance"
		StopSoundOn(sound_cast, self:GetParent())
	end
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_wave_2_champion_shadow_dance:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
	}
	return funcs
end

function modifier_wave_2_champion_shadow_dance:GetModifierInvisibilityLevel()
	return 2
end

--------------------------------------------------------------------------------
-- Status Effects
function modifier_wave_2_champion_shadow_dance:CheckState()
	local state = {
		[MODIFIER_STATE_INVISIBLE] = true,
		[MODIFIER_STATE_TRUESIGHT_IMMUNE] = true,
	}

	return state
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_wave_2_champion_shadow_dance:OnIntervalThink()
	ParticleManager:SetParticleControl(self.effect_cast, 1, self:GetParent():GetOrigin())
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_wave_2_champion_shadow_dance:GetStatusEffectName()
	return "particles/status_fx/status_effect_slark_shadow_dance.vpcf"
end

function modifier_wave_2_champion_shadow_dance:StatusEffectPriority()
	return MODIFIER_PRIORITY_NORMAL
end

function modifier_wave_2_champion_shadow_dance:PlayEffects1()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_slark/slark_shadow_dance.vpcf"
	local sound_cast = "Hero_Slark.ShadowDance"

	-- Get Data
	local parent = self:GetParent()

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticleForTeam(particle_cast, PATTACH_ABSORIGIN_FOLLOW, parent,
		parent:GetTeamNumber())
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		1,
		parent,
		PATTACH_ABSORIGIN_FOLLOW,
		"attach_hitloc",
		Vector(0, 0, 0), -- unknown
		true       -- unknown, true
	)
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		3,
		parent,
		PATTACH_POINT_FOLLOW,
		"attach_eyeR",
		Vector(0, 0, 0), -- unknown
		true       -- unknown, true
	)
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		4,
		parent,
		PATTACH_POINT_FOLLOW,
		"attach_eyeL",
		Vector(0, 0, 0), -- unknown
		true       -- unknown, true
	)

	-- buff particle
	self:AddParticle(
		effect_cast,
		false, -- bDestroyImmediately
		false, -- bStatusEffect
		-1, -- iPriority
		false, -- bHeroEffect
		false -- bOverheadEffect
	)

	EmitSoundOn(sound_cast, parent)
	-- self.effect_cast = effect_cast
end

function modifier_wave_2_champion_shadow_dance:PlayEffects2()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_slark/slark_shadow_dance_dummy.vpcf"

	-- Get Data
	local parent = self:GetParent()

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, parent)
	ParticleManager:SetParticleControl(effect_cast, 0, parent:GetOrigin())
	ParticleManager:SetParticleControl(effect_cast, 1, parent:GetOrigin())

	-- buff particle
	self:AddParticle(
		effect_cast,
		false, -- bDestroyImmediately
		false, -- bStatusEffect
		-1, -- iPriority
		false, -- bHeroEffect
		false -- bOverheadEffect
	)

	self.effect_cast = effect_cast
end

modifier_wave_2_champion_shadow_dance_passive = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_wave_2_champion_shadow_dance_passive:IsHidden()
	return self:GetStackCount() == 1
end

function modifier_wave_2_champion_shadow_dance_passive:IsDebuff()
	return false
end

function modifier_wave_2_champion_shadow_dance_passive:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_wave_2_champion_shadow_dance_passive:OnCreated(kv)
	-- references
	self.interval = self:GetAbility():GetSpecialValueFor("activation_delay")         -- special value
	self.neutral_disable = self:GetAbility():GetSpecialValueFor("neutral_disable")   -- special value
	self.bonus_regen = self:GetAbility():GetSpecialValueFor("bonus_regen_pct")       -- special value
	self.bonus_movespeed = self:GetAbility():GetSpecialValueFor("bonus_movement_speed") -- special value

	if not IsServer() then return end
	-- find enemy fountain
	local caster = self:GetCaster()
	-- local fountains = Entities:FindAllByClassname( 'ent_dota_fountain' )

	-- for _,foun in pairs(fountains) do
	-- 	if foun:GetTeamNumber()~=self:GetParent():GetTeamNumber() then
	-- 		self.fountain = foun
	-- 	end
	-- end

	-- self.fountain=GamePlay:GetEnemyKing(caster:GetTeamNumber())

	--	self.fountains={GamePlay.kingGood,GamePlay.GetBad}

	-- in a case where no fountain, just do self. thus inactive all the time
	--if not self.fountain then self.fountain = self:GetParent() end

	-- Start interval
	self:StartIntervalThink(self.interval)
	self:OnIntervalThink()
end

function modifier_wave_2_champion_shadow_dance_passive:OnRefresh(kv)
	-- references
	self.interval = self:GetAbility():GetSpecialValueFor("activation_delay")    -- special value
	self.neutral_disable = self:GetAbility():GetSpecialValueFor("neutral_disable") -- special value
end

function modifier_wave_2_champion_shadow_dance_passive:OnDestroy(kv)
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_wave_2_champion_shadow_dance_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE,

		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}

	return funcs
end

function modifier_wave_2_champion_shadow_dance_passive:OnTakeDamage(params)
	if not IsServer() then return end
	if params.unit ~= self:GetParent() then return end
	if not params.attacker:IsNeutralUnitType() then return end

	-- set disable
	self.disable = true
	self:SetStackCount(1)
	self:StartIntervalThink(self.neutral_disable)
end

function modifier_wave_2_champion_shadow_dance_passive:GetModifierHealthRegenPercentage()
	return self.bonus_regen * (1 - self:GetStackCount())
end

function modifier_wave_2_champion_shadow_dance_passive:GetModifierMoveSpeedBonus_Percentage()
	return self.bonus_movespeed * (1 - self:GetStackCount())
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_wave_2_champion_shadow_dance_passive:OnIntervalThink()
	-- stack: 1 is seen, 0 unseen

	local flag = false
	-- for _, fountain in ipairs(self.fountains) do
	-- 	if fountain:CanEntityBeSeenByMyTeam( self:GetParent() ) then
	-- 		flag=true
	-- 	end
	-- end

	flag = not self:GetParent():HasModifier("modifier_wave_2_champion_shadow_dance")

	if flag then
		self:SetStackCount(1)
	else
		self:SetStackCount(0)
	end

	--self:SetStackCount( 0 )
end

--------------------------------------------------------------------------------
-- Stack Effects
function modifier_wave_2_champion_shadow_dance_passive:OnStackCountChanged(prev)
	if not IsServer() then return end
	if prev == self:GetStackCount() then return end

	if self:GetStackCount() == 0 then
		self:PlayEffects()
	elseif self:GetStackCount() == 1 then
		self:StopEffects()
	end
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_wave_2_champion_shadow_dance_passive:PlayEffects()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_slark/slark_regen.vpcf"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	self.effect_cast = effect_cast
end

function modifier_wave_2_champion_shadow_dance_passive:StopEffects()
	if not self.effect_cast then return end
	ParticleManager:DestroyParticle(self.effect_cast, false)
	ParticleManager:ReleaseParticleIndex(self.effect_cast)
	self.effect_cast = nil
end
