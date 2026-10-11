LinkLuaModifier("modifier_undead_ancient_apparition_ice_blast", "ability/undead_ancient_apparition_ice_blast.lua",
	LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_undead_ancient_apparition_ice_blast_stun", "ability/undead_ancient_apparition_ice_blast.lua",
	LUA_MODIFIER_MOTION_NONE)
--Abilities
if undead_ancient_apparition_ice_blast == nil then
	undead_ancient_apparition_ice_blast = class({})
end
function undead_ancient_apparition_ice_blast:OnSpellStart()
	local pos = self:GetCursorPosition()
	local caster = self:GetCaster()

	local vector = pos - self:GetCaster():GetAbsOrigin()

	-- "The ice blast travels at a speed of 750, or reaches the targeted point in 2 seconds, whichever is faster."
	local velocity = vector:Normalized() * math.max(vector:Length2D() / 2, 750)

	-- "The explosion radius starts at 275 and increases by 50 for every second the tracer has traveled, capped at 1000 radius."
	local final_radius = math.min(
		self:GetSpecialValueFor("radius_min") +
		((vector:Length2D() / self:GetSpecialValueFor("speed")) * self:GetSpecialValueFor("radius_grow")),
		self:GetSpecialValueFor("radius_max"))

	--EmitSoundOnClient("Hero_Ancient_Apparition.IceBlastRelease.Cast.Self", self:GetCaster():GetPlayerOwner())
	self:GetCaster():EmitSound("Hero_Ancient_Apparition.IceBlastRelease.Cast")

	local ice_blast_particle = ParticleManager:CreateParticle(
		"particles/units/heroes/hero_ancient_apparition/ancient_apparition_ice_blast_final.vpcf", PATTACH_WORLDORIGIN,
		self:GetCaster())
	ParticleManager:SetParticleControl(ice_blast_particle, 0, self:GetCaster():GetAbsOrigin())
	-- CP1: Direction Vector
	ParticleManager:SetParticleControl(ice_blast_particle, 1, velocity)
	-- CP5: Duration
	ParticleManager:SetParticleControl(ice_blast_particle, 5,
		Vector(math.min(vector:Length2D() / velocity:Length2D(), 2), 0, 0))
	ParticleManager:ReleaseParticleIndex(ice_blast_particle)

	local marker_particle = ParticleManager:CreateParticleForTeam(
		"particles/units/heroes/hero_ancient_apparition/ancient_apparition_ice_blast_marker.vpcf", PATTACH_WORLDORIGIN,
		self:GetCaster(), self:GetCaster():GetTeamNumber())
	ParticleManager:SetParticleControl(marker_particle, 0, pos)
	ParticleManager:SetParticleControl(marker_particle, 1, Vector(final_radius, 1, 1))
	-- AddFOWViewer(self:GetCaster():GetTeamNumber(), pos, 650, 4, false)

	local linear_projectile = {
		Ability           = self,
		--EffectName			= "particles/units/heroes/hero_ancient_apparition/ancient_apparition_ice_blast_final.vpcf",
		vSpawnOrigin      = self:GetCaster():GetAbsOrigin(),
		fDistance         = vector:Length2D(),
		fStartRadius      = self:GetSpecialValueFor("path_radius"),
		fEndRadius        = self:GetSpecialValueFor("path_radius"),
		Source            = self:GetCaster(),
		bHasFrontalCone   = false,
		bReplaceExisting  = false,
		iUnitTargetTeam   = DOTA_UNIT_TARGET_TEAM_NONE,
		iUnitTargetFlags  = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
		iUnitTargetType   = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		fExpireTime       = GameRules:GetGameTime() + 10.0,
		bDeleteOnHit      = true,
		vVelocity         = velocity,
		bProvidesVision   = false,
		iVisionRadius     = self:GetSpecialValueFor("target_sight_radius"),
		iVisionTeamNumber = self:GetCaster():GetTeamNumber(),

		ExtraData         =
		{
			marker_particle = marker_particle,
			final_radius = final_radius
		}
	}

	self.initial_projectile = ProjectileManager:CreateLinearProjectile(linear_projectile)
end

function undead_ancient_apparition_ice_blast:OnProjectileThink_ExtraData(location, data)
	-- "The ice blast has 500 flying vision, lasting 3 seconds."
	-- AddFOWViewer(self:GetCaster():GetTeamNumber(), location, self:GetSpecialValueFor("target_sight_radius"), 3, false)

	-- "The debuff can also be placed on spell immune or invulnerable, but not on hidden units."
	local enemies  = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), location, nil,
		self:GetSpecialValueFor("path_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)

	local duration = self:GetSpecialValueFor("frostbite_duration")

	for _, enemy in pairs(enemies) do
		enemy:AddNewModifier(self:GetCaster(), self, "modifier_undead_ancient_apparition_ice_blast",
			{
				duration   = duration * (1 - enemy:GetStatusResistance()),
				dot_damage = self:GetSpecialValueFor("dot_damage"),
				kill_pct   = self:GetSpecialValueFor("kill_pct"),
			}
		)
	end
end

function undead_ancient_apparition_ice_blast:OnProjectileHit_ExtraData(target, location, data)
	if not target then
		EmitSoundOnLocationWithCaster(location, "Hero_Ancient_Apparition.IceBlast.Target", self:GetCaster())

		if data.marker_particle then
			ParticleManager:DestroyParticle(data.marker_particle, false)
			ParticleManager:ReleaseParticleIndex(data.marker_particle)
		end

		-- "The debuff can also be placed on spell immune or invulnerable, but not on hidden units."
		local enemies     = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), location, nil, data.final_radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
			DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
		-- local vanilla_ability_name = string.gsub(self:GetAbilityName(), "imba_", "")
		-- local damage = GetAbilityKV(vanilla_ability_name, "AbilityDamage", self.ice_blast_ability:GetLevel())

		local damage      = self:GetSpecialValueFor("damage")
		local damageTable = {
			victim       = nil,
			damage       = damage,
			damage_type  = self:GetAbilityDamageType(),
			damage_flags = DOTA_DAMAGE_FLAG_NONE,
			attacker     = self:GetCaster(),
			ability      = self
		}

		local duration    = self:GetSpecialValueFor("frostbite_duration")

		for _, enemy in pairs(enemies) do
			enemy:AddNewModifier(self:GetCaster(), self, "modifier_undead_ancient_apparition_ice_blast",
				{
					duration   = duration,
					dot_damage = self:GetSpecialValueFor("dot_damage"),
					kill_pct   = self:GetSpecialValueFor("kill_pct")
				}
			)

			enemy:AddNewModifier(self:GetCaster(), self, "modifier_undead_ancient_apparition_ice_blast_stun",
				{
					duration = self:GetSpecialValueFor("cold_feet_stun_duration_pct"),
				}
			)
			if not enemy:IsMagicImmune() then
				damageTable.victim = enemy
				ApplyDamage(damageTable)
			end
			-- IMBAfication: Cold-Hearted
			-- self:GetCaster():AddNewModifier(self:GetCaster(), self.ice_blast_ability, "modifier_undead_ancient_apparition_ice_blast_cold_hearted", {duration = duration, regen = enemy:GetHealthRegen()})
		end

		-- -- IMBAfication: Global Cooling
		-- -- Something something lag? IDK
		-- local all_enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), location, nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD, FIND_ANY_ORDER, false)

		-- local global_cooling_modifier = nil

		-- for _, enemy in pairs(all_enemies) do
		-- global_cooling_modifier = enemy:AddNewModifier(self:GetCaster(), self.ice_blast_ability, "modifier_undead_ancient_apparition_ice_blast_global_cooling", {duration = duration})

		-- if global_cooling_modifier then
		-- global_cooling_modifier:SetDuration(duration * (1 - enemy:GetStatusResistance()), true)
		-- end
		-- end
	end
end

modifier_undead_ancient_apparition_ice_blast = class({})
function modifier_undead_ancient_apparition_ice_blast:IsDebuff() return true end

function modifier_undead_ancient_apparition_ice_blast:IsPurgable() return false end

function modifier_undead_ancient_apparition_ice_blast:GetEffectName()
	return "particles/units/heroes/hero_ancient_apparition/ancient_apparition_ice_blast_debuff.vpcf"
end

function modifier_undead_ancient_apparition_ice_blast:GetStatusEffectName()
	return "particles/status_fx/status_effect_iceblast.vpcf"
end

function modifier_undead_ancient_apparition_ice_blast:StatusEffectPriority()
	return 3
end

function modifier_undead_ancient_apparition_ice_blast:OnCreated(params)
	local ability = self:GetAbility()
	self.boss_kill_pct = ability:GetSpecialValueFor("boss_kill_pct")

	if not IsServer() then return end

	self.dot_damage = params.dot_damage
	self.kill_pct   = params.kill_pct

	if params.caster_entindex then
		self.caster = EntIndexToHScript(params.caster_entindex)
	else
		self.caster = self:GetCaster()
	end

	self.damage_table = {
		victim       = self:GetParent(),
		damage       = self.dot_damage,
		damage_type  = DAMAGE_TYPE_MAGICAL,
		damage_flags = DOTA_DAMAGE_FLAG_NONE,
		attacker     = self.caster,
		ability      = self:GetAbility()
	}

	self:StartIntervalThink(1 - self:GetParent():GetStatusResistance())
end

function modifier_undead_ancient_apparition_ice_blast:OnRefresh(params)
	self:OnCreated(params)
end

function modifier_undead_ancient_apparition_ice_blast:OnIntervalThink()
	self:GetParent():EmitSound("Hero_Ancient_Apparition.IceBlastRelease.Tick")

	ApplyDamage(self.damage_table)

	SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, self:GetParent(), self.dot_damage, nil)
end

function modifier_undead_ancient_apparition_ice_blast:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_DISABLE_HEALING,
		MODIFIER_EVENT_ON_TAKEDAMAGE_KILLCREDIT
	}
end

function modifier_undead_ancient_apparition_ice_blast:GetDisableHealing()
	return 1
end

function modifier_undead_ancient_apparition_ice_blast:OnTakeDamageKillCredit(keys)
	local kill_pct = self.kill_pct
	if keys.target:IsAncient() then
		kill_pct = self.boss_kill_pct
	end
	if keys.target == self:GetParent() and (self:GetParent():GetHealth() / self:GetParent():GetMaxHealth()) * 100 <= kill_pct then
		if keys.attacker == self:GetParent() and not self:GetParent():IsInvulnerable() then
			self:GetParent():Kill(self:GetAbility(), self.caster)
		else
			self:GetParent():Kill(self:GetAbility(), keys.attacker)
		end

		if not self:GetParent():IsAlive() then
			local ice_blast_particle = ParticleManager:CreateParticle(
				"particles/units/heroes/hero_ancient_apparition/ancient_apparition_ice_blast_death.vpcf",
				PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
			ParticleManager:ReleaseParticleIndex(ice_blast_particle)
		end
	end
end

-------------------------------------------------------------------------------------------------------
modifier_undead_ancient_apparition_ice_blast_stun = class({
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
function modifier_undead_ancient_apparition_ice_blast_stun:AllowIllusionDuplicate()
	return false
end

function modifier_undead_ancient_apparition_ice_blast_stun:OnCreated(params)
	if not self:GetAbility() then return end
	local ability = self:GetAbility()
	if not IsServer() then return end
	-- self.damage = params.damage
	-- self:SetHasCustomTransmitterData(true)
end

function modifier_undead_ancient_apparition_ice_blast_stun:OnRefresh(params)
	self:OnCreated(params)
end

function modifier_undead_ancient_apparition_ice_blast_stun:DeclareFunctions()
	return {

	}
end

function modifier_undead_ancient_apparition_ice_blast_stun:CheckState()
	local state = {
		[MODIFIER_STATE_FROZEN] = true,
		[MODIFIER_STATE_STUNNED] = true,
	}
	return state
end

function modifier_undead_ancient_apparition_ice_blast_stun:GetEffectName()
	return "particles/units/heroes/hero_ancient_apparition/ancient_apparition_cold_feet_frozen.vpcf"
end

function modifier_undead_ancient_apparition_ice_blast_stun:GetEffectAttachType()
	return PATTACH_POINT_FOLLOW
end
