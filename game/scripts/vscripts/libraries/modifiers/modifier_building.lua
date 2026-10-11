modifier_building = class({
    IsHidden = function(self)
        return true
    end,
    IsPurgable = function(self)
        return false
    end,
    IsDebuff = function(self)
        return false
    end,
    IsBuff = function(self)
        return true
    end,
    RemoveOnDeath = function(self)
        return false
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end
})

function modifier_building:OnCreated(event)
    if not IsServer() then return end
    self.disable_turning = event.disable_turning
    self.magic_immune = event.magic_immune == 1
    self.deniable = event.deniable == 1
    self.disarmed = event.disarmed == 1
    self.noHealthBar = event.noHealthBar == 1
    self.invulnerable = event.invulnerable == 1
end

function modifier_building:GetModifierDisableTurning()
    if not IsServer() then return end
    return self.disable_turning
end

function modifier_building:GetModifierIgnoreCastAngle()
    if not IsServer() then return end
    return self.disable_turning
end

function modifier_building:CheckState() 
    if not IsServer() then return end
    return { 
            [MODIFIER_STATE_MAGIC_IMMUNE] = self.magic_immune,
             [MODIFIER_STATE_SPECIALLY_DENIABLE] = self.deniable,
             [MODIFIER_STATE_ROOTED] = true,
             [MODIFIER_STATE_LOW_ATTACK_PRIORITY] = true,
             [MODIFIER_STATE_DISARMED]=self.disarmed,
             [MODIFIER_STATE_NO_HEALTH_BAR]=self.noHealthBar,

              --[MODIFIER_STATE_FROZEN] = true,
             --[MODIFIER_STATE_NO_UNIT_COLLISION] = false,
             --[MODIFIER_STATE_INVULNERABLE] =self.invulnerable,
             }
end

function modifier_building:DeclareFunctions() 
  return { 
           MODIFIER_PROPERTY_DISABLE_TURNING,
           MODIFIER_PROPERTY_IGNORE_CAST_ANGLE,
           MODIFIER_PROPERTY_MOVESPEED_LIMIT, 
        }
end
function modifier_building:GetModifierMoveSpeed_Limit()
    return 0
end
