LinkLuaModifier("modifier_mech_headshot", "ability/mech_headshot", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mech_headshot_slow", "ability/mech_headshot", LUA_MODIFIER_MOTION_NONE)

if mech_headshot == nil then
	mech_headshot = class({})
end

--------------------------------------------------------------------------------
function mech_headshot:GetIntrinsicModifierName()
	return "modifier_mech_headshot"
end
--------------------------------------------------------------------------------


modifier_mech_headshot = class({
	IsHidden         = function(self) return true end,
	IsPurgable       = function(self) return false end,
	IsPurgeException = function(self) return false end,
	IsDebuff         = function(self) return false end,
	IsBuff           = function(self) return true end,
	RemoveOnDeath    = function(self) return true end,
	DeclareFunctions = function(self)
		return {
			MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL
		}
	end,
})


--------------------------------------------------------------------------------

function modifier_mech_headshot:OnRefresh()
	self:OnCreated()
end

function modifier_mech_headshot:OnCreated()
	if not self:GetAbility() then return end
	self.proc_chance = self:GetAbility():GetSpecialValueFor("proc_chance")
	self.boss_proc_chance = self:GetAbility():GetSpecialValueFor("boss_proc_chance")
	self.knockback_distance = self:GetAbility():GetSpecialValueFor("knockback_distance")
	self.slow_duration = self:GetAbility():GetSpecialValueFor("slow_duration")
	self.damage = self:GetAbility():GetSpecialValueFor("damage")


end

function modifier_mech_headshot:GetModifierProcAttack_BonusDamage_Physical(k)

	if not IsServer() then return end

	local target = k.target
	local attacker = k.attacker
	local caster = self:GetCaster()


	local chance=self.proc_chance
	if target:IsAncient() then
		chance=self.boss_proc_chance
	end
	-- RollPseudoRandomPercentage(self.proc_chance, 1, caster)
	if attacker == caster and not caster:PassivesDisabled() and RandomInt(1, 100) <= self.proc_chance
		and not target:IsOther() and not target:IsBuilding() then
		local duration=0.1
		--duration = duration * (1 - CalUnitStatusResistance(target))	
		local knockbackProperties =
		{
			center_x = caster:GetAbsOrigin().x,
			center_y = caster:GetAbsOrigin().y,
			center_z = caster:GetAbsOrigin().z,
			duration = duration,
			knockback_duration = duration,
			knockback_distance = self.knockback_distance,
			knockback_height = 0
		}

		target:AddNewModifier(caster, self:GetAbility(), "modifier_knockback", knockbackProperties)
		local slow_duration = self.slow_duration * (1 - CalUnitStatusResistance(target))
		if slow_duration and slow_duration>0 then
			target:AddNewModifier(caster, self:GetAbility(), "modifier_mech_headshot_slow", { duration = slow_duration })
		end
		return self.damage
	end
	return
end

--------------------------------------------------------------------------------


modifier_mech_headshot_slow = class({
	IsHidden         = function(self) return false end,
	IsPurgable       = function(self) return true end,
	IsPurgeException = function(self) return true end,
	IsDebuff         = function(self) return true end,
	IsBuff           = function(self) return false end,
	RemoveOnDeath    = function(self) return true end,
	DeclareFunctions = function(self)
		return {
			MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
			MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
		}
	end,
})


--------------------------------------------------------------------------------

function modifier_mech_headshot_slow:OnCreated()
	self.slow = self:GetAbility():GetSpecialValueFor("slow")

	if IsServer() then
		local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_sniper/sniper_headshot_slow.vpcf",
			PATTACH_OVERHEAD_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(fx, 0, self:GetParent():GetAbsOrigin())
		self:AddParticle(fx, false, false, -1, false, true)
	end
end

function modifier_mech_headshot_slow:GetModifierMoveSpeedBonus_Percentage() return -self.slow end

function modifier_mech_headshot_slow:GetModifierAttackSpeedBonus_Constant()
	if self:GetParent():IsAncient() then
		return -self.slow * (100 - BOSS_ATTACK_SPEED_REDUCTION_RESISTANCE) / 100
	end
	return -self.slow
end
