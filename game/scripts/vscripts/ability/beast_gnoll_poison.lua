LinkLuaModifier("modifier_beast_gnoll_poison", "ability/beast_gnoll_poison.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_beast_gnoll_poison_debuff", "ability/beast_gnoll_poison.lua", LUA_MODIFIER_MOTION_NONE)
-- Abilities
if beast_gnoll_poison == nil then
    beast_gnoll_poison = class({})
end
function beast_gnoll_poison:GetIntrinsicModifierName()
    return "modifier_beast_gnoll_poison"
end
---------------------------------------------------------------------
-- Modifiers
modifier_beast_gnoll_poison = class({
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
function modifier_beast_gnoll_poison:OnCreated(params)
    local ability=self:GetAbility()

    if not ability then
        return
    end
    self.duration=ability:GetSpecialValueFor("duration")
    if IsServer() then
    end
end
function modifier_beast_gnoll_poison:OnRefresh(params)
    if IsServer() then
    end
end
function modifier_beast_gnoll_poison:OnDestroy()
    if IsServer() then
    end
end
function modifier_beast_gnoll_poison:DeclareFunctions()
    return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end
function modifier_beast_gnoll_poison:OnAttackLanded(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	local target = params.target
    if target:IsMagicImmune() then
        return
    end
	--EmitSoundOn("Hero_Dazzle.Poison_Touch", target)
	SimplePlayEffOnUnit(target,"particles/units/heroes/hero_beastmaster/beastmaster_boar_attack_explosion.vpcf")

    local duration=self.duration
    duration = duration * (1 - CalUnitStatusResistance(target))
	target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_beast_gnoll_poison_debuff", {duration = duration})
end
--
--
modifier_beast_gnoll_poison_debuff = class({
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
function modifier_beast_gnoll_poison_debuff:OnCreated(params)
    if not self:GetAbility() then return end
    local ability=self:GetAbility()
    self.move_slow=ability:GetSpecialValueFor("move_slow")
    self.attack_slow=ability:GetSpecialValueFor("attack_slow")
    
    if IsServer() then
    end
end
function modifier_beast_gnoll_poison_debuff:OnRefresh(params)
    if IsServer() then
    end
end
function modifier_beast_gnoll_poison_debuff:OnDestroy()
    if IsServer() then
    end
end
function modifier_beast_gnoll_poison_debuff:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE
	}

end
function modifier_beast_gnoll_poison_debuff:GetModifierMoveSpeedBonus_Percentage()
	return -self.move_slow
end

function modifier_beast_gnoll_poison_debuff:GetModifierAttackSpeedPercentage( params )
	if self:GetParent():IsAncient() then
        return -self.attack_slow*(100-BOSS_ATTACK_SPEED_REDUCTION_RESISTANCE)/100
    end
    return -self.attack_slow
end 

