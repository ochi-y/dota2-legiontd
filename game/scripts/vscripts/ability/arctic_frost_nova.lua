LinkLuaModifier("modifier_arctic_frost_nova", "ability/arctic_frost_nova.lua", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_arctic_frost_nova_tag", "ability/arctic_frost_nova.lua", LUA_MODIFIER_MOTION_NONE)


-- Abilities
if arctic_frost_nova == nil then
    arctic_frost_nova = class({})
end

function arctic_frost_nova:GetAOERadius()
    local radius = self:GetSpecialValueFor("radius")
    return radius
end

function arctic_frost_nova:OnSpellStart()
    if not IsServer() then
        return
    end

    
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    local radius = self:GetSpecialValueFor("radius")
    local duration = self:GetSpecialValueFor("duration")
    local aoe_damage = self:GetSpecialValueFor("aoe_damage")
    local damage = self:GetAbilityDamage()

    local enemies = SimpleFindEnemy(caster:GetTeam(), target:GetAbsOrigin(), radius, nil)

	SimplePlayEffOnUnit(target,"particles/units/heroes/hero_lich/lich_frost_nova.vpcf")

    SimpleApplyDamage(self, caster, target, damage)

    EmitSoundOn("Ability.FrostNova", target)
    for _, enemy in pairs(enemies) do
        SimpleApplyDamage(self, caster, enemy, aoe_damage)
        enemy:AddNewModifier(caster, self, "modifier_arctic_frost_nova", {
            duration = duration
        })
    end
end

-------------------------------------------------------------------------------------------------------
modifier_arctic_frost_nova = class({
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return true
    end,
    IsDebuff = function(self)
        return true
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
function modifier_arctic_frost_nova:AllowIllusionDuplicate()
    return false
end
function modifier_arctic_frost_nova:OnCreated(params)
	local ability=self:GetAbility()
	self.slow_movement_speed=ability:GetSpecialValueFor("slow_movement_speed")
	self.slow_attack_speed_primary=ability:GetSpecialValueFor("slow_attack_speed_primary")
    -- self.damage = params.damage
    -- self:SetHasCustomTransmitterData(true) 
end

function modifier_arctic_frost_nova:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE
	}
	return funcs
end

function modifier_arctic_frost_nova:GetModifierMoveSpeedBonus_Percentage()
	return self.slow_movement_speed
end
function modifier_arctic_frost_nova:GetModifierAttackSpeedPercentage( params )
    if self:GetParent():IsAncient() then
        return self.slow_attack_speed_primary*(100-BOSS_ATTACK_SPEED_REDUCTION_RESISTANCE)/100
    end
	return self.slow_attack_speed_primary
end 

function modifier_arctic_frost_nova:GetStatusEffectName()
    return "particles/generic_gameplay/generic_slowed_cold.vpcf"
end
function modifier_arctic_frost_nova:StatusEffectPriority()
    return 100
end

modifier_arctic_frost_nova_tag = class({
IsHidden                = function(self) return true end,
IsPurgable              = function(self) return false end,
IsDebuff                = function(self) return false end,
IsBuff                  = function(self) return true end,
RemoveOnDeath           = function(self) return true end,
AllowIllusionDuplicate           = function(self) return false end,
GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})