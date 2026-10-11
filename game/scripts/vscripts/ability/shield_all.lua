LinkLuaModifier("modifier_shield_all", "ability/shield_all.lua", LUA_MODIFIER_MOTION_NONE)
-- Abilities
if shield_all == nil then
    shield_all = class({})
end
function shield_all:GetIntrinsicModifierName()
    return "modifier_shield_all"
end
---------------------------------------------------------------------
-- Modifiers
-------------------------------------------------------------------------------------------------------
modifier_shield_all = class({
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

function modifier_shield_all:AllowIllusionDuplicate()
    return false
end
function modifier_shield_all:OnCreated(params)
    if not IsServer() then
        return
    end
    self:SetStackCount(1000)
end
function modifier_shield_all:OnRefresh(params)
    self:OnCreated(params)
end

function modifier_shield_all:DeclareFunctions()
    return {MODIFIER_PROPERTY_INCOMING_DAMAGE_CONSTANT,MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_CONSTANT ,MODIFIER_PROPERTY_INCOMING_SPELL_DAMAGE_CONSTANT }
end

function modifier_shield_all:CheckState()
    local state = {}
    return state
end

function modifier_shield_all:GetModifierIncomingPhysicalDamageConstant(event)

	return self:GetModifierIncomingDamageConstant(event)
end
function modifier_shield_all:GetModifierIncomingSpellDamageConstant(event)
	return self:GetModifierIncomingDamageConstant(event)

end
function modifier_shield_all:GetModifierIncomingDamageConstant(event)
    if not IsServer() then
        return self:GetStackCount()
    end
    local shield = self:GetStackCount()
    if event.damage - shield >= 0 then
        shield = 0
        self:SetStackCount(shield)
        self:Destroy()
        return -shield
    else
        shield = shield - event.damage
        self:SetStackCount(shield)
        return -event.damage
    end
end

