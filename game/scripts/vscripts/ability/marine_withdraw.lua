LinkLuaModifier('modifier_marine_withdraw_active', 'ability/marine_withdraw', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_marine_withdraw_passive', 'ability/marine_withdraw', LUA_MODIFIER_MOTION_NONE)
marine_withdraw = class({})

-- function marine_withdraw:OnSpellStart()
--     self:GetCaster():AddNewModifier(self:GetCaster(), self, 'modifier_marine_withdraw_active', {
--         duration = self:GetSpecialValueFor('duration')
--     })
--     self:GetCaster():EmitSound('Hero_Abaddon.BorrowedTime')
-- end

function marine_withdraw:GetIntrinsicModifierName()
    return 'modifier_marine_withdraw_passive'
end

modifier_marine_withdraw_passive = class({
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
    IsPermanent = function(self)
        return true
    end,
    DeclareFunctions = function(self)
        return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
    end
})


function modifier_marine_withdraw_passive:OnCreated(data)
    if not self:GetAbility() then return end
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

    local ability=self:GetAbility()
    self.duration=ability:GetSpecialValueFor("duration")
end

function modifier_marine_withdraw_passive:OnRefresh(data)
    self:OnCreated()
end

function modifier_marine_withdraw_passive:GetModifierIncomingDamage_Percentage(data)
    local health = self.parent:GetHealth()
	if health - data.damage <0 then
		return 0
	end
	if self.ability:IsCooldownReady() and (health - data.damage <=26) then
		-- data.target:CastAbilityNoTarget(self.ability, self.parent:GetPlayerOwnerID())
        self:GetCaster():AddNewModifier(self:GetCaster(), self, 'modifier_marine_withdraw_active', {
            duration = self.duration
        })
		self.ability:StartCooldown(90)
        self:GetCaster():EmitSound('Hero_Abaddon.BorrowedTime')
        return -100
	end

    return 0
end

modifier_marine_withdraw_active = class({
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
    GetStatusEffectName = function(self)
        return 'particles/status_fx/status_effect_abaddon_borrowed_time.vpcf'
    end,
    GetEffectName = function(self)
        return 'particles/units/heroes/hero_abaddon/abaddon_borrowed_time.vpcf'
    end,
    GetEffectAttachType = function(self)
        return PATTACH_ABSORIGIN_FOLLOW
    end,
    StatusEffectPriority = function(self)
        return MODIFIER_PRIORITY_HIGH
    end,
    DeclareFunctions = function(self)
        return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE}
    end
})

function modifier_marine_withdraw_active:GetModifierIncomingDamage_Percentage(data)
    return -100
end

function modifier_marine_withdraw_active:OnCreated()
    if IsClient() then
        return
    end
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.caster:Purge(false, true, true, true, false)
end

function modifier_marine_withdraw_active:GetModifierAttackSpeedPercentage(data)
    return -90
end
