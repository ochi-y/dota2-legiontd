modifier_generic_outgoing_damage = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return false end,
    RemoveOnDeath           = function(self) return true end,
    GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_MULTIPLE end,
    })
    function modifier_generic_outgoing_damage:OnCreated(params)
        self.outgoing_damage=params.outgoing_damage
    end
    --------------------------------------------------------------------------------
    function modifier_generic_outgoing_damage:DeclareFunctions()
        local funcs = {
            MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
        }
        return funcs
    end
    
    function modifier_generic_outgoing_damage:GetModifierDamageOutgoing_Percentage( keys )
        return self.outgoing_damage
    end
    