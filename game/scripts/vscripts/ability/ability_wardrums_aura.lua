LinkLuaModifier("modifier_ability_wardrums_aura", "ability/ability_wardrums_aura", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_wardrums_aura_buff", "ability/ability_wardrums_aura", LUA_MODIFIER_MOTION_NONE)
-- Abilities

ability_wardrums_aura = class({})

wave_16_champion_wardrums_aura=ability_wardrums_aura


function ability_wardrums_aura:GetIntrinsicModifierName()
    return "modifier_ability_wardrums_aura"
end
---------------------------------------------------------------------
-- Modifiers

modifier_ability_wardrums_aura = class({
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
        return true
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_NONE
    end
})

function modifier_ability_wardrums_aura:OnCreated(params)
    local ability=self:GetAbility()
	self.speed_bonus=ability:GetSpecialValueFor("speed_bonus")
	self.accuracy=ability:GetSpecialValueFor("accuracy")
	self.radius=ability:GetSpecialValueFor("radius")
end
function modifier_ability_wardrums_aura:OnRefresh(params)
	local ability=self:GetAbility()
	self.speed_bonus=ability:GetSpecialValueFor("speed_bonus")
	self.accuracy=ability:GetSpecialValueFor("accuracy")
	self.radius=ability:GetSpecialValueFor("radius")
end
function modifier_ability_wardrums_aura:OnDestroy()
    if IsServer() then
    end
end
function modifier_ability_wardrums_aura:DeclareFunctions()
    return {}
end
function modifier_ability_wardrums_aura:IsAura()
    return true
end
function modifier_ability_wardrums_aura:GetModifierAura()
    return "modifier_ability_wardrums_aura_buff"
end
function modifier_ability_wardrums_aura:GetAuraRadius()
    return self.radius
end

function modifier_ability_wardrums_aura:GetAuraDuration()
    return 0.3
end

function modifier_ability_wardrums_aura:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_ability_wardrums_aura:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_ability_wardrums_aura:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

function modifier_ability_wardrums_aura:GetAuraEntityReject(hEntity)
    return false
end
--
modifier_ability_wardrums_aura_buff = class({
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

function modifier_ability_wardrums_aura_buff:OnCreated()
	local ability=self:GetAbility()
	self.speed_bonus=ability:GetSpecialValueFor("speed_bonus")
	self.accuracy=ability:GetSpecialValueFor("accuracy")
	self.radius=ability:GetSpecialValueFor("radius")

	if not IsServer() then return end
	self.pierce_records = {}

end
function modifier_ability_wardrums_aura_buff:OnRefresh()
	local ability=self:GetAbility()
	self.speed_bonus=ability:GetSpecialValueFor("speed_bonus")
	self.accuracy=ability:GetSpecialValueFor("accuracy")
	self.radius=ability:GetSpecialValueFor("radius")
end
function modifier_ability_wardrums_aura_buff:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE,
		MODIFIER_EVENT_ON_ATTACK_RECORD
	}
end

function modifier_ability_wardrums_aura_buff:GetModifierAttackSpeedPercentage()
    return self.speed_bonus
end

function modifier_ability_wardrums_aura_buff:CheckState()
	local state = {}
	if self.pierce_proc then   
		state = {[MODIFIER_STATE_CANNOT_MISS] = true}
	end
	return state
end
function modifier_ability_wardrums_aura_buff:OnAttackRecord(keys)
	if not IsServer() then return end

	if keys.attacker == self:GetParent() then
		if self.pierce_proc then
			table.insert(self.pierce_records, keys.record)
			self.pierce_proc = false
		end
		if RandomInt(1, 100)<=self.accuracy then 
			self.pierce_proc = true
		end
	end
end


