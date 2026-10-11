if modifier_center_zone == nil then
	modifier_center_zone = class({})
end
function modifier_center_zone:OnCreated(params)
	if IsServer() then
	end
end
function modifier_center_zone:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_center_zone:OnDestroy()
	if IsServer() then
	end
end
function modifier_center_zone:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
	}
end

function modifier_center_zone:GetModifierPhysicalArmorBonus()
	return 2
end

function modifier_center_zone:GetTexture()
	return "tower_armor_aura"
end
