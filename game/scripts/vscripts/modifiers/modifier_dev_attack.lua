if modifier_dev_attack == nil then
	modifier_dev_attack = class({})
end
function modifier_dev_attack:OnCreated(params)
	if IsServer() then
	end
end
function modifier_dev_attack:OnRefresh(params)
	if IsServer() then
	end
end

function modifier_dev_attack:IsPurgable(params)
	return false
end
function modifier_dev_attack:OnDestroy()
	if IsServer() then
	end
end
function modifier_dev_attack:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
	}
end

function modifier_dev_attack:GetModifierDamageOutgoing_Percentage()
    return self:GetStackCount()-100
end

