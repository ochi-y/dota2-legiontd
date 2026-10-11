LinkLuaModifier("modifier_legiontd_septic_shock", "ability/legiontd_septic_shock", LUA_MODIFIER_MOTION_NONE)

-- Ability definition
legiontd_septic_shock = class({})

function legiontd_septic_shock:GetIntrinsicModifierName()
	return "modifier_legiontd_septic_shock"
end

---------------------------------------------------------------------
-- Septic Shock modifier - listens to the global damage event
---------------------------------------------------------------------
modifier_legiontd_septic_shock = class({})

function modifier_legiontd_septic_shock:IsHidden()
	return true
end

function modifier_legiontd_septic_shock:IsDebuff()
	return false
end

function modifier_legiontd_septic_shock:IsPurgable()
	return false
end

function modifier_legiontd_septic_shock:RemoveOnDeath()
	return false
end

function modifier_legiontd_septic_shock:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}
end

function modifier_legiontd_septic_shock:OnTakeDamage(params)
	if IsServer() then
		local caster = self:GetParent()  -- the unit that owns the ability
		local ability = self:GetAbility()

		-- Was the damage dealt by that unit?
		if params.attacker ~= caster then
			return
		end

		-- Does the victim still exist?
		if not params.unit or not IsValid(params.unit) then
			return
		end

		-- Avoid recursion: is the inflictor this ability?
		if params.inflictor == ability then
			return
		end

		local victim = params.unit

		-- Count the debuffs on the victim, each unique debuff once
		local seen = {}
		local debuff_count = 0
		print("[Septic Shock] unit:", victim:GetUnitName(), "total modifiers:", victim:GetModifierCount())
		for i = 0, victim:GetModifierCount() - 1 do
			local name = victim:GetModifierNameByIndex(i)
			if name and not seen[name] then
				seen[name] = true
				local modifier = victim:FindModifierByName(name)
				if modifier and modifier:IsDebuff() then
					debuff_count = debuff_count + 1
					print("[Septic Shock] debuff found:", name)
				else
					print("[Septic Shock] non-debuff modifier:", name)
				end
			end
		end
		print("[Septic Shock] total debuffs:", debuff_count)

		-- With debuffs present, deal extra magic damage
		if debuff_count > 0 then
			local damage = params.damage
			local damage_per_debuff_pct = ability:GetSpecialValueFor("damage_per_debuff_pct")
			local bonus_damage = damage * debuff_count * damage_per_debuff_pct * 0.01

			-- Deal the extra magic damage
			ApplyDamage({
				victim = victim,
				attacker = caster,
				damage = bonus_damage,
				damage_type = DAMAGE_TYPE_MAGICAL,
				ability = ability,
				damage_flags = DOTA_DAMAGE_FLAG_NONE
			})

			-- Show the extra damage number
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, victim, bonus_damage, nil)

		end
	end
end
