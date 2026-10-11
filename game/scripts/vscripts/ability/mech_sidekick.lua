--------------------------------------------------------------------------------
mech_sidekick = class({})
LinkLuaModifier("modifier_mech_sidekick", "ability/mech_sidekick", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------
-- Init Abilities
function mech_sidekick:Precache(context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_marci.vsndevts", context)
	PrecacheResource("particle", "particles/units/heroes/hero_marci/marci_sidekick_self_buff.vpcf", context)
	PrecacheResource("particle", "particles/status_fx/status_effect_marci_sidekick.vpcf", context)
end

function mech_sidekick:Spawn()
	if not IsServer() then return end
end

--------------------------------------------------------------------------------
-- Ability Start
function mech_sidekick:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	if IsCustomBuilding(caster) then
		GamePlay:FighterSetAbilityTarget(caster.fighterId, self:GetAbilityName(), target.fighterId)
	end
	-- load data
	-- check secondary target
	if target == caster then
		-- find allies
		local allies = FindUnitsInRadius(
			caster:GetTeamNumber(),                -- int, your team number
			caster:GetOrigin(),                    -- point, center point
			nil,                                   -- handle, cacheUnit. (not known)
			self:GetCastRange(target:GetOrigin(), target), -- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_FRIENDLY,        -- int, team filter
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, -- int, type filter
			0,                                     -- int, flag filter
			FIND_CLOSEST,                          -- int, order filter
			false                                  -- bool, can grow cache
		)

		-- get nearest ally
		local closest = nil
		for _, ally in pairs(allies) do
			if ally ~= caster and not ally:HasModifier("modifier_mech_sidekick") then
				closest = ally
				break
			end
		end
		-- set target as closest (or nil if not found)
		target = closest
	end


	local friendId = nil
	if target then
		friendId = target:entindex()
	end

	-- add modifier
	local selfMod = caster:AddNewModifier(
		target or caster,   -- player source
		self,               -- ability source
		"modifier_mech_sidekick", -- modifier name
		{
			friendId = friendId
		} -- kv
	)
	selfMod:SetStackCount(1)

	if not target then return end

	if self.lastCastTarget and IsActiveUnit(self.lastCastTarget) then
		local mod = self.lastCastTarget:FindModifierByNameAndCaster("modifier_mech_sidekick", caster)
		if mod then
			self.lastCastTarget:RemoveModifierByName("modifier_mech_sidekick")
			self.lastCastTarget = nil
		end
	end


	local targetMod = target:AddNewModifier(
		caster,             -- player source
		self,               -- ability source
		"modifier_mech_sidekick", -- modifier name
		{
			friendId = caster:entindex()
		} -- kv
	)
	targetMod:SetStackCount(2)

	self.lastCastTarget = target
end

--------------------------------------------------------------------------------
modifier_mech_sidekick = class({
	GetAttributes = function(self)
		return MODIFIER_ATTRIBUTE_NONE
	end
})

--------------------------------------------------------------------------------
-- Classifications
function modifier_mech_sidekick:IsHidden()
	return false
end

function modifier_mech_sidekick:IsDebuff()
	return false
end

function modifier_mech_sidekick:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_mech_sidekick:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.lifesteal_pct = self:GetAbility():GetSpecialValueFor("lifesteal_pct") / 100
	self.bonus_damage = self:GetAbility():GetSpecialValueFor("bonus_damage")

	self.self_lifesteal_pct = self:GetAbility():GetSpecialValueFor("self_lifesteal_pct") / 100
	self.self_bonus_damage = self:GetAbility():GetSpecialValueFor("self_bonus_damage")

	if not IsServer() then return end
	-- play effects
	self:PlayEffects1()
	if kv.friendId then
		self.friend = EntIndexToHScript(kv.friendId)
	end
end

function modifier_mech_sidekick:OnRefresh(kv)
	self:OnCreated(kv)
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_mech_sidekick:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		-- MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE
	}
	return funcs
end

function modifier_mech_sidekick:GetModifierProcAttack_Feedback(params)
	if not IsServer() then return end

	if params.target:GetTeamNumber() == self.parent:GetTeamNumber() then return end
	if params.target:IsBuilding() or params.target:IsOther() then return end

	self.attack_record = params.record
end

function modifier_mech_sidekick:OnTakeDamage(params)
	if not IsServer() then return end
	if self.attack_record ~= params.record then return end

	-- get heal value
	-- local heal = params.damage * self.lifesteal
	-- self.parent:Heal(heal, self.ability)
	-- self:PlayEffects2()

	local parent = self:GetParent()

	local lifesteal = 0
	if self:GetStackCount() == 1 then
		lifesteal = self.self_lifesteal_pct
	else
		lifesteal = self.lifesteal_pct
	end
	local heal = params.damage * lifesteal
	self:GetParent():HealWithParams(heal, self, true, true, self:GetParent(), false)
	self:PlayEffects2(self:GetParent())

	if self.friend and IsActiveUnit(self.friend) and self.friend:FindModifierByNameAndCaster("modifier_mech_sidekick", parent) then
		self.friend:HealWithParams(heal, self, true, true, self:GetParent(), false)
		self:PlayEffects2(self.friend)
	end
end

function modifier_mech_sidekick:GetModifierDamageOutgoing_Percentage()
	if self:GetStackCount() == 1 then
		return self.self_bonus_damage
	else
		return self.bonus_damage
	end
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_mech_sidekick:ShouldUseOverheadOffset()
	return true
end

function modifier_mech_sidekick:GetStatusEffectName()
	return "particles/status_fx/status_effect_marci_sidekick.vpcf"
end

function modifier_mech_sidekick:StatusEffectPriority()
	return MODIFIER_PRIORITY_NORMAL
end

function modifier_mech_sidekick:PlayEffects2(unit)
	-- Get Resources
	local particle_cast = "particles/generic_gameplay/generic_lifesteal.vpcf"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, unit)
	ParticleManager:ReleaseParticleIndex(effect_cast)
end

function modifier_mech_sidekick:PlayEffects1()
	if self.effect_cast then
		ParticleManager:DestroyParticle(self.effect_cast, false)
		self.effect_cast = nil
	end
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_marci/marci_sidekick_self_buff.vpcf"
	if self.parent ~= self.caster then
		particle_cast = "particles/units/heroes/hero_marci/marci_sidekick_buff.vpcf"
	end

	local sound_target = "Hero_Marci.Guardian.Applied"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_OVERHEAD_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 1, self.parent:GetOrigin())

	-- buff particle
	self:AddParticle(
		effect_cast,
		false, -- bDestroyImmediately
		false, -- bStatusEffect
		1, -- iPriority
		false, -- bHeroEffect
		true -- bOverheadEffect
	)

	self.effect_cast = effect_cast

	-- Create Sound
	EmitSoundOn(sound_target, self.parent)
end
