LinkLuaModifier("modifier_arctic_tuskarr_spearman_walrus_kick", "ability/arctic_tuskarr_spearman_walrus_kick.lua",
	LUA_MODIFIER_MOTION_NONE)
--Abilities
arctic_tuskarr_spearman_walrus_kick = class({})


function arctic_tuskarr_spearman_walrus_kick:OnSpellStart()
	local air_time = self:GetSpecialValueFor("air_time")
	local push_length = self:GetSpecialValueFor("push_length")
	local slow_duration = self:GetSpecialValueFor("slow_duration")
	local damage = self:GetSpecialValueFor("damage")
	local caster = self:GetCaster()

	local target = self:GetCursorTarget()



	local dir=(target:GetAbsOrigin()-caster:GetAbsOrigin()):Normalized()

	local targetPos = dir * push_length + target:GetAbsOrigin()

	-- print(push_length,caster:GetForwardVector())

	push_length = push_length * (1 - CalUnitStatusResistance(target))

	EmitSoundOn("Hero_Tusk.WalrusKick.Target", caster)

	PlayEffOnUnit("particles/units/heroes/hero_tusk/tusk_walruskick_txt_ult.vpcf", target, {
		cps = { 0, 1, 2 }
	})

	self.arc = target:AddNewModifier(self.caster, -- player source
		self,                                  -- ability source
		"modifier_generic_arc_lua",            -- modifier name
		{
			target_x = targetPos.x,
			target_y = targetPos.y,
			--speed = speed,
			duration = air_time,
			distance = push_length,
			 height = 200,
			fix_end = false,
			fix_duration = true,
			isStun = false,
			isRestricted = true,
			--isForward = true,
			--activity = ACT_DOTA_OVERRIDE_ABILITY_1,
			stoppedByTerrain = true
		} -- kv
	)
	PlayEffOnUnit("particles/econ/items/tuskarr/tusk_ti9_immortal/tusk_ti9_walruskick_tgt.vpcf",
		target, {
			mod = self.arc
		})

	self.arc:SetEndCallback(function()

		print("SetEndCallback")
		if IsActiveUnit(target) then
			Timers:CreateTimer(FrameTime(), function()
				local effect_cast = ParticleManager:CreateParticle(
					"particles/units/heroes/hero_crystalmaiden/maiden_crystal_nova.vpcf", PATTACH_WORLDORIGIN, nil)
				ParticleManager:SetParticleControl(effect_cast, 0, target:GetAbsOrigin())
				ParticleManager:SetParticleControl(effect_cast, 1, Vector(300, 4, 300))
				ParticleManager:ReleaseParticleIndex(effect_cast)

				slow_duration = slow_duration * (1 - CalUnitStatusResistance(target))

				target:AddNewModifier(caster, self, "modifier_arctic_tuskarr_spearman_walrus_kick", {
					duration = slow_duration
				})
				target:RemoveGesture(ACT_DOTA_FLAIL)
			end)
			UTIL:SetXAngle(target,0)
		end
	end)

	local angleSpeed=360/air_time

	self.arc:SetUpdateback(function(time)
		if IsActiveUnit(target) then
			UTIL:SetXAngle(target,time*angleSpeed)
		end
	end)
	target:StartGesture(ACT_DOTA_FLAIL)

	SimpleApplyDamage(self, caster, target, damage)
end

-------------------------------------------------------------------------------------------------------
modifier_arctic_tuskarr_spearman_walrus_kick = class({
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
function modifier_arctic_tuskarr_spearman_walrus_kick:AllowIllusionDuplicate()
	return false
end

function modifier_arctic_tuskarr_spearman_walrus_kick:OnCreated(params)

	local ability=self:GetAbility()
	self.move_slow=ability:GetSpecialValueFor("move_slow")
end

function modifier_arctic_tuskarr_spearman_walrus_kick:OnRefresh(params)
	self:OnCreated(params)
end

function modifier_arctic_tuskarr_spearman_walrus_kick:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
end

function modifier_arctic_tuskarr_spearman_walrus_kick:CheckState()
	local state = {
	}
	return state
end

function modifier_arctic_tuskarr_spearman_walrus_kick:GetEffectName()
	return "particles/units/heroes/hero_drow/drow_frost_arrow_debuff.vpcf"
end

function modifier_arctic_tuskarr_spearman_walrus_kick:GetEffectAttachType()
	return PATTACH_POINT_FOLLOW
end
function modifier_arctic_tuskarr_spearman_walrus_kick:GetModifierMoveSpeedBonus_Percentage()
    return -self.move_slow
end
