-------------------------------------------------------------------------------------------------------
modifier_hc = class({
    IsHidden = function(self)
        return false
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
        return true
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_NONE
    end
})
function modifier_hc:AllowIllusionDuplicate()
    return false
end


function modifier_hc:GetTexture()
	return "alpha_wolf_command_aura"
end


function modifier_hc:OnCreated(params)
    -- self.damage = params.damage
    -- self:SetHasCustomTransmitterData(true) 
end

function modifier_hc:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
        MODIFIER_PROPERTY_MODEL_SCALE
    }
    return funcs
end

function modifier_hc:GetModifierModelScale()
    
    local parent=self:GetParent()
    local res=0
    if parent:GetHealthPercent()<50 then
        return 0
    end
	return 30
end

function modifier_hc:CheckState()
    return {
    }
end

function modifier_hc:GetModifierBaseAttack_BonusDamage()
    local parent=self:GetParent()
    local res=0
    if self.flag then
        return 0
    end
    
    if parent:GetHealthPercent()<50 then
        self.flag=true
        res=math.floor(-0.5*(parent:GetBaseDamageMin()+parent:GetBaseDamageMax())/2)
        self.flag=false
    end
	return res
end

