LinkLuaModifier("modifier_king_bouns", "ability/king_bouns.lua", LUA_MODIFIER_MOTION_NONE)
-- Abilities
if king_bouns == nil then
    king_bouns = class({})
end
function king_bouns:GetIntrinsicModifierName()
    return "modifier_king_bouns"
end

function king_bouns:Spawn()
    if not IsServer() then
        return
    end
    self:SetLevel(0)
end

function king_bouns:updateBonusLevel()
    if not IsServer() then
        return
    end
    local MaxLevel = GetAbilityKV("king_bouns", "MaxLevel")
    local LevelsBetweenUpgrades = GetAbilityKV("king_bouns", "LevelsBetweenUpgrades")
    local RequiredLevel = GetAbilityKV("king_bouns", "RequiredLevel")
    local level = 0
    local caster = self:GetCaster()
    local casterLevel = caster:GetLevel()

    casterLevel = GamePlay.round

    if casterLevel < RequiredLevel then
        level = 0
    else
        level = 1 + math.floor((casterLevel - RequiredLevel) / LevelsBetweenUpgrades)
    end
    self:SetLevel(level)
end

---------------------------------------------------------------------
-- Modifiers
modifier_king_bouns = class({
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

function modifier_king_bouns:OnCreated(params)
    local ability = self:GetAbility()

    if ability then
        self.armor = ability:GetSpecialValueFor("armor")
        self.attack_speed = ability:GetSpecialValueFor("attack_speed")    
    end
    
end

function modifier_king_bouns:OnRefresh(params)
    self:OnCreated(params)
end

function modifier_king_bouns:OnDestroy()
    if IsServer() then
    end
end

function modifier_king_bouns:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
     }
end

function modifier_king_bouns:GetModifierProvidesFOWVision(params)
    return 1
end

function modifier_king_bouns:GetModifierAttackSpeedPercentage(params)
    return self.attack_speed
end

function modifier_king_bouns:GetModifierPhysicalArmorBonus()
    return self.armor
end

function modifier_king_bouns:CheckState()
	local state =
	{
		-- [MODIFIER_STATE_HEXED] = false,
		-- [MODIFIER_STATE_ROOTED] = false,
		-- [MODIFIER_STATE_SILENCED] = false,
		-- [MODIFIER_STATE_STUNNED] = false,
		-- [MODIFIER_STATE_FROZEN] = false,
		-- [MODIFIER_STATE_FEARED] = false,
		-- [MODIFIER_STATE_TAUNTED] = false,
		-- [MODIFIER_STATE_DISARMED] = false,
		[MODIFIER_STATE_CANNOT_BE_MOTION_CONTROLLED] = true,
	}

	return state
end
-- function modifier_king_bouns:GetEffectName()
--     return "particles/econ/events/anniversary_10th/anniversary_10th_hat_ambient_npc_dota_hero_razor.vpcf"
-- end
-- function modifier_king_bouns:GetEffectAttachType()
--     return PATTACH_OVERHEAD_FOLLOW
-- end