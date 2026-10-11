LinkLuaModifier("modifier_radiant_monkey_king_boundless_strike", "ability/radiant_monkey_king_boundless_strike.lua",
	LUA_MODIFIER_MOTION_NONE)
--Abilities
if radiant_monkey_king_boundless_strike == nil then
	radiant_monkey_king_boundless_strike = class({})
end

function radiant_monkey_king_boundless_strike:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	EmitSoundOn("Hero_MonkeyKing.Strike.Cast", caster)

	local effect = ParticleManager:CreateParticle("particles/units/heroes/hero_monkey_king/monkey_king_strike_cast.vpcf",
		PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(effect, 0, caster, PATTACH_ABSORIGIN_FOLLOW, nil,
		caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(effect, 1, caster, PATTACH_POINT_FOLLOW, "attach_weapon_top",
		caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(effect, 2, caster, PATTACH_POINT_FOLLOW, "attach_weapon_bot",
		caster:GetAbsOrigin(), true)
	--ParticleManager:SetParticleControl(effect, 1, Vector(500,500,500))
	-- ParticleManager:ReleaseParticleIndex(effect)
	--self:AddParticle(effect, false, false, -1, false, false)
	self.castEff = effect
	return true
end

function radiant_monkey_king_boundless_strike:OnAbilityPhaseInterrupted()
	local caster = self:GetCaster()
	ParticleManager:DestroyParticle(self.castEff, true)
	return true
end

function radiant_monkey_king_boundless_strike:OnSpellStart()
	local caster = self:GetCaster()
	local pos = self:GetCursorPosition()

	EmitSoundOnLocationWithCaster(pos, "Hero_MonkeyKing.Strike.Impact", caster)

	local endPos = caster:GetAbsOrigin() + 1100 * caster:GetForwardVector()
	local effect = ParticleManager:CreateParticle("particles/units/heroes/hero_monkey_king/monkey_king_strike.vpcf",
		PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(effect, 0, caster, PATTACH_ABSORIGIN_FOLLOW, nil,
		caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(effect, 1, endPos)
	-- ParticleManager:ReleaseParticleIndex(effect)
	-- self:AddParticle(effect, false, false, -1, false, false)
	local units = SimpleFindEnemyInLine(caster:GetTeamNumber(), caster:GetAbsOrigin(), endPos,
		self:GetSpecialValueFor("strike_radius"))

	-- stableSort	
	stableSortByNumber(units, function(v)
		return (v:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D()
	end)

	local max_units = self:GetSpecialValueFor("max_units")

	caster:AddNewModifier(caster, self, "modifier_radiant_monkey_king_boundless_strike", {
		duration=1
	})
	for i = 1, max_units, 1 do
		local unit = units[i]
		if unit then
			unit:AddNewModifier(caster, self, "modifier_stunned", { duration = self:GetSpecialValueFor("stun_duration") })
			caster:PerformAttack(unit, true, true, true, false, false, false, true)
		end
	end
	caster:RemoveModifierByName("modifier_radiant_monkey_king_boundless_strike")
end

-------------------------------------------------------------------------------------------------------
-- modifier   ---------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
modifier_radiant_monkey_king_boundless_strike = class({
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
function modifier_radiant_monkey_king_boundless_strike:AllowIllusionDuplicate()
	return false
end

function modifier_radiant_monkey_king_boundless_strike:OnCreated(params)
	if not self:GetAbility() then return end
	local ability = self:GetAbility()
	self.strike_crit_mult = ability:GetSpecialValueFor("strike_crit_mult")
	if not IsServer() then return end
end

function modifier_radiant_monkey_king_boundless_strike:OnRefresh(params)
	self:OnCreated(params)
end

function modifier_radiant_monkey_king_boundless_strike:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE
	}
end
function modifier_radiant_monkey_king_boundless_strike:GetModifierPreAttack_CriticalStrike( params )
	return self.strike_crit_mult
end
