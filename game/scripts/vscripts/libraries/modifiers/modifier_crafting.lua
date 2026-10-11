modifier_crafting = class({})

function modifier_crafting:OnCreated(event)
    self.disable_turning = event.disable_turning == 1 and 1 or 0
    self.magic_immune = event.magic_immune == 1
    self.deniable = event.deniable == 1
end


function modifier_crafting:CheckState() 
    return { [MODIFIER_STATE_SILENCED] = true,
             [MODIFIER_STATE_PASSIVES_DISABLED] = true,
             [MODIFIER_STATE_MUTED] = true,
             }
end

function modifier_crafting:DeclareFunctions() 
  return { MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS }
end

function modifier_crafting:GetAttributes()
    return MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_crafting:IsHidden()
    return true
end

function modifier_crafting:IsPurgable()
    return false
end
function modifier_crafting:GetModifierPhysicalArmorBonus()
	return 1000
end