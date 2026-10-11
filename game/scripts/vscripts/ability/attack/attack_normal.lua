LinkLuaModifier("modifier_attack_normal", "ability/attack/attack_normal.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_attack_type_debuff", "ability/attack/attack_normal.lua", LUA_MODIFIER_MOTION_NONE)
-- Abilities
if attack_normal == nil then
    attack_normal = class({})
end
function attack_normal:GetIntrinsicModifierName()
    return "modifier_attack_normal"
end
---------------------------------------------------------------------
-- Modifiers
modifier_attack_normal = class({
	IsHidden                = function(self) return false end,
	IsPurgable              = function(self) return false end,
	IsDebuff                = function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath           = function(self) return true end,
	GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
	})

    function modifier_attack_normal:GetTexture()
		return "attack/attack_normal"
	end	


function modifier_attack_normal:OnCreated(params)
    if IsServer() then
		local caster=self:GetParent()
		caster.attackType="normal"
    end
end
function modifier_attack_normal:OnRefresh(params)
    if IsServer() then
    end
end
function modifier_attack_normal:OnDestroy()
    if IsServer() then
    end
end
function modifier_attack_normal:DeclareFunctions()
    return {
		MODIFIER_EVENT_ON_ATTACK_LANDED, 
	}
end

function modifier_attack_normal:OnAttackLanded(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	local target = params.target

	handleAttackType(params.attacker,target)

	
end
---------------------------------------------------------------------
-- Modifiers
modifier_attack_type_debuff = class({
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
        return false
    end,
    RemoveOnDeath = function(self)
        return true
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_NONE
    end
})
function modifier_attack_type_debuff:OnCreated(params)
    if IsServer() then
		self.attackBonus=params.attackBonus
    end
end
function modifier_attack_type_debuff:OnRefresh(params)
	self:OnCreated(params)
end
function modifier_attack_type_debuff:OnDestroy()
    if IsServer() then
    end
end
function modifier_attack_type_debuff:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_PERCENTAGE
	}
end
function modifier_attack_type_debuff	:GetModifierIncomingPhysicalDamage_Percentage()
	return self.attackBonus or 0
end

