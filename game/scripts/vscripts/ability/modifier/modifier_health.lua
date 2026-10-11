if modifier_health == nil then
	modifier_health = class({})
end
function modifier_health:OnCreated(params)
	-- 
	local parent=self:GetParent()
	if IsServer() then
		SimpleAddHealth(parent,params.health)
	end
	-- 
end
function modifier_health:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_health:OnDestroy()
	if IsServer() then
	end
end
function modifier_health:DeclareFunctions()
	return {
	}
end

function modifier_health:GetModifierPreAttack_BonusDamage()
    return self:GetStackCount()
end

function modifier_health:GetModifierPhysicalArmorBonus()
    return 0
end
