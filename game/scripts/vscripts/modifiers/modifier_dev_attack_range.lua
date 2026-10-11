if modifier_dev_attack_range == nil then
	modifier_dev_attack_range = class({})
end
function modifier_dev_attack_range:OnCreated(params)
	if IsServer() then
	end
end
function modifier_dev_attack_range:OnRefresh(params)
	if IsServer() then
	end
end

function modifier_dev_attack_range:IsPurgable(params)
	return false
end
function modifier_dev_attack_range:OnDestroy()
	if IsServer() then
	end
end
function modifier_dev_attack_range:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
	}
end

function modifier_dev_attack_range:GetModifierAttackRangeBonus()
    return 10*(self:GetStackCount()-100)
end

