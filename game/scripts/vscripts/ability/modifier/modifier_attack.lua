if modifier_attack == nil then
	modifier_attack = class({})
end
function modifier_attack:OnCreated(params)
	if IsServer() then
	end
end
function modifier_attack:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_attack:OnDestroy()
	if IsServer() then
	end
end
function modifier_attack:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
	}
end

function modifier_attack:GetModifierPreAttack_BonusDamage()
    return self:GetStackCount()
end

function modifier_attack:GetModifierPhysicalArmorBonus()
    return 0
end
