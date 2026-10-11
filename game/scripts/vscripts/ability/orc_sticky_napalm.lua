LinkLuaModifier("modifier_orc_sticky_napalm_handler", "ability/orc_sticky_napalm", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_orc_sticky_napalm", "ability/orc_sticky_napalm", LUA_MODIFIER_MOTION_NONE)


orc_sticky_napalm                  = class({})
modifier_orc_sticky_napalm_handler = class({})
modifier_orc_sticky_napalm         = class({})


function orc_sticky_napalm:GetIntrinsicModifierName()
	return "modifier_orc_sticky_napalm_handler"
end

function orc_sticky_napalm:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function orc_sticky_napalm:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()

	self:GetCaster():EmitSound("Hero_Batrider.StickyNapalm.Cast")
	EmitSoundOnLocationWithCaster(self:GetCursorPosition(), "Hero_Batrider.StickyNapalm.Impact", self:GetCaster())

	self.napalm_impact_particle = ParticleManager:CreateParticle(
		"particles/units/heroes/hero_batrider/batrider_stickynapalm_impact.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(self.napalm_impact_particle, 0, self:GetCursorPosition())
	ParticleManager:SetParticleControl(self.napalm_impact_particle, 1, Vector(self:GetSpecialValueFor("radius"), 0, 0))
	-- ParticleManager:SetParticleControl(self.napalm_impact_particle, 2, self:GetCaster():GetAbsOrigin())

	ParticleManager:SetParticleControlEnt(self.napalm_impact_particle, 2, caster, PATTACH_POINT_FOLLOW, "attach_attack1",
		caster:GetAbsOrigin(), true)


	ParticleManager:ReleaseParticleIndex(self.napalm_impact_particle)
	self.napalm_impact_particle = nil

	self.enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetCursorPosition(), nil,
		self:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
		DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

	local unit_count = self:GetSpecialValueFor("unit_count")

	self.enemies = subrange(self.enemies, 1, unit_count)



	for _, enemy in pairs(self.enemies) do
		local duration = self:GetSpecialValueFor("duration")
		duration = duration * (1 - CalUnitStatusResistance(enemy))

		enemy:AddNewModifier(self:GetCaster(), self, "modifier_orc_sticky_napalm",
			{ duration = duration })
	end

	-- "Provides 400 radius flying vision at the targeted point upon cast for 2 seconds."
	AddFOWViewer(self:GetCaster():GetTeamNumber(), self:GetCursorPosition(), 400, 2, false)

	self.napalm_impact_particle = nil
	self.enemies                = nil
end

--------------------------------------------------
-- MODIFIER_orc_sticky_napalm_HANDLER --
--------------------------------------------------

function modifier_orc_sticky_napalm_handler:IsHidden() return true end

function modifier_orc_sticky_napalm_handler:OnIntervalThink()
	if not IsServer() then return end

	if self:GetAbility():GetAutoCastState() and self:GetAbility():IsFullyCastable() and not self:GetAbility():IsInAbilityPhase() and not self:GetCaster():IsHexed() and not self:GetCaster():IsNightmared() and not self:GetCaster():IsOutOfGame() and not self:GetCaster():IsSilenced() and not self:GetCaster():IsStunned() and not self:GetCaster():IsChanneling() then
		self:GetCaster():SetCursorPosition(self:GetCaster():GetAbsOrigin())
		self:GetAbility():CastAbility()
	end
end

function modifier_orc_sticky_napalm_handler:DeclareFunctions()
	local decFuncs = {
		-- MODIFIER_EVENT_ON_ORDER,
		-- MODIFIER_PROPERTY_IGNORE_CAST_ANGLE,
		-- MODIFIER_PROPERTY_DISABLE_TURNING
	}

	return decFuncs
end

function modifier_orc_sticky_napalm_handler:OnOrder(keys)
	if not IsServer() or keys.unit ~= self:GetParent() then return end

	if keys.ability == self:GetAbility() then
		-- IMBAfication: Oil Slick
		if keys.order_type == DOTA_UNIT_ORDER_CAST_POSITION and (keys.new_pos - self:GetCaster():GetAbsOrigin()):Length2D() <= self:GetAbility():GetCastRange(self:GetCaster():GetCursorPosition(), self:GetCaster()) + self:GetCaster():GetCastRangeBonus() then
			self.bActive = true
		else
			self.bActive = false
		end

		-- IMBAfication: Oil Leak
		if keys.order_type == DOTA_UNIT_ORDER_CAST_TOGGLE_AUTO then
			-- Due to logic order, this is actually reversed
			if self:GetAbility():GetAutoCastState() then
				self:SetStackCount(0)
				self:StartIntervalThink(-1)
			else
				self:StartIntervalThink(0.1)
				self:SetStackCount(1)
			end
		end
	else
		self.bActive = false
	end
end

function modifier_orc_sticky_napalm_handler:GetModifierIgnoreCastAngle()
	if not IsServer() or self.bActive == false then return end
	return 1
end

function modifier_orc_sticky_napalm_handler:GetModifierDisableTurning()
	if not IsServer() or self.bActive == false then return end
	return 1
end

------------------------------------------
-- MODIFIER_orc_sticky_napalm --
------------------------------------------

-- TODO: Get this particle to work?
function modifier_orc_sticky_napalm:GetEffectName()
	return "particles/units/heroes/hero_batrider/batrider_napalm_damage_debuff.vpcf"
end

function modifier_orc_sticky_napalm:GetStatusEffectName()
	return "particles/status_fx/status_effect_stickynapalm.vpcf"
end

function modifier_orc_sticky_napalm:StatusEffectPriority()
	return 3
end

function modifier_orc_sticky_napalm:OnCreated()
	self.max_stacks         = self:GetAbility():GetSpecialValueFor("max_stacks")
	self.movement_speed_pct = self:GetAbility():GetSpecialValueFor("movement_speed_pct")
	self.turn_rate_pct      = self:GetAbility():GetSpecialValueFor("turn_rate_pct")
	self.damage             = self:GetAbility():GetSpecialValueFor("damage")

	if not IsServer() then return end

	self.damage_table = {
		victim       = self:GetParent(),
		damage       = nil,
		damage_type  = DAMAGE_TYPE_MAGICAL,
		damage_flags = DOTA_DAMAGE_FLAG_NONE,
		attacker     = self:GetCaster(),
		ability      = self:GetAbility()
	}

	-- "Sticky Napalm triggers on any damage instance caused by Batrider, except from Orb of Venom, Radiance, Spirit Vessel, Urn of Shadows and damage with the no-reflection flag."
	-- Orb of Venom seems to already be taken care of innately so it doesn't have to be added to this list
	self.non_trigger_inflictors = {
		["orc_sticky_napalm"] = true,

		-- ["item_imba_cloak_of_flames"]	= true,
		-- ["item_imba_radiance"]			= true,

		-- ["item_imba_urn_of_shadows"]	= true,
		-- ["item_imba_spirit_vessel"]		= true,
	}

	self:SetStackCount(1)

	self.stack_particle = ParticleManager:CreateParticleForTeam(
		"particles/units/heroes/hero_batrider/batrider_stickynapalm_stack.vpcf", PATTACH_OVERHEAD_FOLLOW,
		self:GetParent(),
		self:GetCaster():GetTeamNumber())
	ParticleManager:SetParticleControl(self.stack_particle, 1,
		Vector(math.floor(self:GetStackCount() / 10), self:GetStackCount() % 10, 0))
	self:AddParticle(self.stack_particle, false, false, -1, false, false)
end

function modifier_orc_sticky_napalm:OnRefresh()
	self.max_stacks         = self:GetAbility():GetSpecialValueFor("max_stacks")
	self.movement_speed_pct = self:GetAbility():GetSpecialValueFor("movement_speed_pct")
	self.turn_rate_pct      = self:GetAbility():GetSpecialValueFor("turn_rate_pct")
	self.damage             = self:GetAbility():GetSpecialValueFor("damage")

	if not IsServer() then return end

	if self:GetStackCount() < self.max_stacks then
		self:IncrementStackCount()
	end

	if self.stack_particle then
		ParticleManager:SetParticleControl(self.stack_particle, 1,
			Vector(math.floor(self:GetStackCount() / 10), self:GetStackCount() % 10, 0))
	end
end

function modifier_orc_sticky_napalm:DeclareFunctions()
	return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE,
		MODIFIER_EVENT_ON_TAKEDAMAGE }
end

function modifier_orc_sticky_napalm:GetModifierMoveSpeedBonus_Percentage()
	return math.min(self:GetStackCount(), self.max_stacks) * self.movement_speed_pct
end

function modifier_orc_sticky_napalm:GetModifierTurnRate_Percentage()
	return self.turn_rate_pct
end

function modifier_orc_sticky_napalm:OnTakeDamage(keys)
	local attacker = keys.attacker

	if attacker:GetUnitName() == "orc_wind_rider" and attacker:HasAbility("orc_sticky_napalm") then
		if keys.unit == self:GetParent() and (not keys.inflictor or not self.non_trigger_inflictors[keys.inflictor:GetName()]) and bit.band(keys.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then
			self.damage_debuff_particle = ParticleManager:CreateParticle(
				"particles/units/heroes/hero_batrider/batrider_napalm_damage_debuff.vpcf", PATTACH_ABSORIGIN,
				self:GetParent())
			ParticleManager:ReleaseParticleIndex(self.damage_debuff_particle)
			self.damage_debuff_particle = nil

			-- The wikis don't say anything about creep-heroes so I'll just assume they'll be treated as creeps
			-- if self:GetParent():IsHero() then
			-- 	self.damage_table.damage = self.damage * self:GetStackCount()
			-- else
			-- 	self.damage_table.damage = self.damage * 0.5 * self:GetStackCount()
			-- end

			self.damage_table.damage = self.damage * self:GetStackCount()

			ApplyDamage(self.damage_table)
		end
	end
end
