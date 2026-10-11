LinkLuaModifier("modifier_boss_strong", "ability/boss_strong.lua", LUA_MODIFIER_MOTION_NONE)
-- Abilities
if boss_strong == nil then
    boss_strong = class({})
end
function boss_strong:GetIntrinsicModifierName()
    if self:GetLevel() > 0 then
        return "modifier_boss_strong"
    end
end

---------------------------------------------------------------------
-- Modifiers
if modifier_boss_strong == nil then
    modifier_boss_strong = class({})
end
function modifier_boss_strong:IsHidden(params)
    return true
end

function modifier_boss_strong:OnCreated(params)
    local ability = self:GetAbility()
    if not ability then
        return
    end
    self.attackspeed_reduction_percentage = ability:GetSpecialValueFor("attackspeed_reduction_percentage")
    self.movespeed_reduction_percentage = ability:GetSpecialValueFor("movespeed_reduction_percentage")
    self.status_resistance = ability:GetSpecialValueFor("status_resistance")
end

function modifier_boss_strong:IsPurgable(params)
    return false
end

function modifier_boss_strong:OnRefresh(params)
    local ability = self:GetAbility()
    if not ability then
        return
    end
    self.attackspeed_reduction_percentage = ability:GetSpecialValueFor("attackspeed_reduction_percentage")
    self.movespeed_reduction_percentage = ability:GetSpecialValueFor("movespeed_reduction_percentage")
    self.status_resistance = ability:GetSpecialValueFor("status_resistance")
end

function modifier_boss_strong:OnDestroy()
    if IsServer() then
    end
end

function modifier_boss_strong:DeclareFunctions()
    return { 
        -- MODIFIER_PROPERTY_ATTACKSPEED_REDUCTION_PERCENTAGE,
        -- MODIFIER_PROPERTY_MOVESPEED_REDUCTION_PERCENTAGE,
        MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING 
    }
end


function modifier_boss_strong:CheckState()
	local state =
	{
		-- [MODIFIER_STATE_CANNOT_BE_MOTION_CONTROLLED] = true,
	}
	return state
end

function modifier_boss_strong:GetModifierStatusResistanceStacking()
    return self.status_resistance
end

function modifier_boss_strong:GetModifierAttackSpeedReductionPercentage()
    return self.attackspeed_reduction_percentage
end

function modifier_boss_strong:GetModifierMoveSpeedReductionPercentage()
    return self.movespeed_reduction_percentage
end
