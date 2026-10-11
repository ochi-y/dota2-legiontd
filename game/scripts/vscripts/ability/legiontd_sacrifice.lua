LinkLuaModifier("modifier_legiontd_sacrifice", "ability/legiontd_sacrifice", LUA_MODIFIER_MOTION_NONE)

-- Ability definition
legiontd_sacrifice = class({})

function legiontd_sacrifice:GetIntrinsicModifierName()
	return "modifier_legiontd_sacrifice"
end

---------------------------------------------------------------------
-- Sacrifice modifier - boosts the damage dealt and reflects part of it back
---------------------------------------------------------------------
modifier_legiontd_sacrifice = class({})

function modifier_legiontd_sacrifice:IsHidden()
	return true
end

function modifier_legiontd_sacrifice:IsDebuff()
	return false
end

function modifier_legiontd_sacrifice:IsPurgable()
	return false
end

function modifier_legiontd_sacrifice:RemoveOnDeath()
	return false
end

function modifier_legiontd_sacrifice:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}
end

function modifier_legiontd_sacrifice:GetModifierTotalDamageOutgoing_Percentage(params)
	if IsServer() then
		-- Physical damage only
		if params.damage_type == DAMAGE_TYPE_PHYSICAL then
			return self:GetAbility():GetSpecialValueFor("damage_increase_pct")
		end
	end
	return 0
end

function modifier_legiontd_sacrifice:OnTakeDamage(params)
	if IsServer() then
		local caster = self:GetParent()  -- the unit that owns the ability
		local ability = self:GetAbility()

		-- Was the damage dealt by the owner?
		if params.attacker ~= caster then
			return
		end

		-- Physical damage only
		if params.damage_type ~= DAMAGE_TYPE_PHYSICAL then
			return
		end

		-- Skip self-inflicted damage
		if params.unit == caster then
			return
		end

		-- Does the victim still exist?
		if not params.unit or not IsValid(params.unit) then
			return
		end

		-- Avoid recursion: reflected damage must not trigger another reflect
		if params.inflictor == ability then
			return
		end

		-- Reflected damage is 50 percent of the damage dealt
		local damage = params.damage
		local self_damage_pct = ability:GetSpecialValueFor("self_damage_pct")
		local feedback_damage = damage * self_damage_pct * 0.01

		-- Never let the reflection kill, always keep 1 health
		local current_health = caster:GetHealth()
		if feedback_damage >= current_health then
			feedback_damage = current_health - 1
		end

		-- Only deal damage when the reflection is positive
		if feedback_damage > 0 then
			-- Deal pure damage to itself
			ApplyDamage({
				victim = caster,
				attacker = caster,
				damage = feedback_damage,
				damage_type = DAMAGE_TYPE_PURE,
				ability = ability,
				damage_flags = DOTA_DAMAGE_FLAG_NONE
			})

			-- Show the reflected damage number
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_DAMAGE, caster, feedback_damage, nil)
		end

		
	end
end
