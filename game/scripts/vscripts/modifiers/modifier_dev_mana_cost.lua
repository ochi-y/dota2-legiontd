if modifier_dev_mana_cost == nil then
	modifier_dev_mana_cost = class({})
end
function modifier_dev_mana_cost:OnCreated(params)
	if IsServer() then
	end
end
function modifier_dev_mana_cost:OnRefresh(params)
	if IsServer() then
	end
end

function modifier_dev_mana_cost:IsPurgable(params)
	return false
end
function modifier_dev_mana_cost:OnDestroy()
	if IsServer() then
	end
end
function modifier_dev_mana_cost:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_MANACOST_PERCENTAGE_STACKING,
	}
end

function modifier_dev_mana_cost:GetModifierPercentageManacostStacking()
    return 100-self:GetStackCount()
end

