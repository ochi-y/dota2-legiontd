LinkLuaModifier("modifier_legiontd_vanquisher", "ability/legiontd_vanquisher", LUA_MODIFIER_MOTION_NONE)

-- Ability definition
legiontd_vanquisher = class({})

function legiontd_vanquisher:GetIntrinsicModifierName()
	return "modifier_legiontd_vanquisher"
end

---------------------------------------------------------------------
-- Vanquisher modifier - extra damage against stunned units
---------------------------------------------------------------------
modifier_legiontd_vanquisher = class({})

function modifier_legiontd_vanquisher:IsHidden()
	return true
end

function modifier_legiontd_vanquisher:IsDebuff()
	return false
end

function modifier_legiontd_vanquisher:IsPurgable()
	return false
end

function modifier_legiontd_vanquisher:RemoveOnDeath()
	return false
end

function modifier_legiontd_vanquisher:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE
	}
end

function modifier_legiontd_vanquisher:GetModifierTotalDamageOutgoing_Percentage(params)
	if IsServer() then
		-- Is the target alive and stunned?
		if params.target and IsValid(params.target) and params.target:IsStunned() then
			-- Return the extra damage percentage
			return self:GetAbility():GetSpecialValueFor("bonus_damage_pct")
		end
	end
	return 0
end
