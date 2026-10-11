LinkLuaModifier("modifier_beast_deadly_poison", "ability/beast_deadly_poison.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_beast_deadly_poison_debuff", "ability/beast_deadly_poison.lua", LUA_MODIFIER_MOTION_NONE)
-- Abilities
if beast_deadly_poison == nil then
    beast_deadly_poison = class({})
end
function beast_deadly_poison:GetIntrinsicModifierName()
    return "modifier_beast_deadly_poison"
end
---------------------------------------------------------------------
-- Modifiers
modifier_beast_deadly_poison = class({
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
function modifier_beast_deadly_poison:OnCreated(params)
    local ability=self:GetAbility()
    if not ability then
        return
    end    
    self.duration=ability:GetSpecialValueFor("duration")
    if IsServer() then
    end
end
function modifier_beast_deadly_poison:OnRefresh(params)
    self:OnCreated(params)
end
function modifier_beast_deadly_poison:OnDestroy()
    if IsServer() then
    end
end
function modifier_beast_deadly_poison:DeclareFunctions()
    return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end
function modifier_beast_deadly_poison:OnAttackLanded(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	local target = params.target
	--EmitSoundOn("Hero_Dazzle.Poison_Touch", target)
    
    if target:IsMagicImmune() then
        return
    end

	SimplePlayEffOnUnit(target,"particles/units/heroes/hero_beastmaster/beastmaster_boar_attack_explosion.vpcf")

    local duration=self.duration
    duration = duration * (1 - CalUnitStatusResistance(target))

	target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_beast_deadly_poison_debuff", {duration = duration})
end
--
--
modifier_beast_deadly_poison_debuff = class({
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
function modifier_beast_deadly_poison_debuff:OnCreated(params)
    if not self:GetAbility() then return end

	self.parent = self:GetParent()
	self.caster = self:GetCaster()
	-- references
	-- precache damage

    local ability=self:GetAbility()
    self.damage=ability:GetSpecialValueFor("damage")
    self.move_slow=ability:GetSpecialValueFor("move_slow")
    self.attack_slow=ability:GetSpecialValueFor("attack_slow")


    if not IsServer() then return end
	self.damageTable = {
		victim = self:GetParent(),
		attacker = self:GetCaster(),
		damage = self.damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self:GetAbility(), --Optional.
		damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL
	}
	self:StartIntervalThink( 1 )
    -- would be lethal in the same frame
	Timers:CreateTimer(FrameTime(),function ()
        if IsActiveUnit(self.parent) then
            self:OnIntervalThink()
        end
    end)
    
end
function modifier_beast_deadly_poison_debuff:OnRefresh(params)
    self:OnCreated( params )
end
function modifier_beast_deadly_poison_debuff:OnDestroy()
    if IsServer() then
    end
end
function modifier_beast_deadly_poison_debuff:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE
	}

end
function modifier_beast_deadly_poison_debuff:GetModifierMoveSpeedBonus_Percentage()
	return -self.move_slow
end

function modifier_beast_deadly_poison_debuff:GetModifierAttackSpeedPercentage( params )
    if self:GetParent():IsAncient() then
        return -self.attack_slow*(100-BOSS_ATTACK_SPEED_REDUCTION_RESISTANCE)/100
    end
    return -self.attack_slow
end 

function modifier_beast_deadly_poison_debuff:OnIntervalThink()
	if not IsServer() then return end
	
	ApplyDamage( self.damageTable )
	-- overhead damage info
	SendOverheadEventMessage(
		nil,
		OVERHEAD_ALERT_BONUS_SPELL_DAMAGE,
		self.parent,
		self.damageTable.damage,
		nil
	)
end
