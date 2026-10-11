if modifier_dev_health == nil then
	modifier_dev_health = class({})
end
function modifier_dev_health:OnCreated(params)
	if IsServer() then
	end
end
function modifier_dev_health:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_dev_health:OnDestroy()
	if IsServer() then
	end
end
function modifier_dev_health:IsPurgable(params)
	return false
end
function modifier_dev_health:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE,
	}
end

function modifier_dev_health:GetModifierExtraHealthPercentage()
    return self:GetStackCount()-100
end

