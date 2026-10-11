if modifier_dev_attack_speed == nil then
	modifier_dev_attack_speed = class({})
end
function modifier_dev_attack_speed:OnCreated(params)
	if IsServer() then
	end
end
function modifier_dev_attack_speed:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_dev_attack_speed:OnDestroy()
	if IsServer() then
	end
end
function modifier_dev_attack_speed:IsPurgable(params)
	return false
end
function modifier_dev_attack_speed:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
end

function modifier_dev_attack_speed:GetModifierAttackSpeedBonus_Constant()
    return self:GetStackCount()-100
end
