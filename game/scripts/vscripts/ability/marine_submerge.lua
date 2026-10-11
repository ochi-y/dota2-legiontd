marine_submerge = class({})
LinkLuaModifier("modifier_marine_submerge", "ability/marine_submerge", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_marine_submerge_buff", "ability/marine_submerge", LUA_MODIFIER_MOTION_NONE)
--------------------------------------------------------------------------------
-- Abilities
if marine_submerge == nil then
    marine_submerge = class({})
end

function marine_submerge:OnAbilityPhaseStart()
	local caster=self:GetCaster()
    EmitSoundOn("Hero_NyxAssassin.Burrow.In", caster)
    PlayEffOnUnit("particles/units/heroes/hero_nyx_assassin/nyx_assassin_burrow.vpcf",caster)
	return true
end
function marine_submerge:OnSpellStart()
    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor("duration")
    caster:AddNewModifier(caster, self, "modifier_marine_submerge", {duration=1.5})
end

function marine_submerge:GetAbilityTextureName()
    return "war3r/BTNCryptFiendBurrow-Reforged"
end

function marine_submerge:GetCastPoint()
    return 0.1
end

modifier_marine_submerge = class({
IsHidden                = function(self) return false end,
IsPurgable              = function(self) return false end,
IsDebuff                = function(self) return false end,
IsBuff                  = function(self) return false end,
RemoveOnDeath           = function(self) return true end,
AllowIllusionDuplicate           = function(self) return false end,
GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_NONE end,
})
function modifier_marine_submerge:OnCreated(params)
    if not self:GetAbility() then return end
    local ability=self:GetAbility()
    self.buff_duration=ability:GetSpecialValueFor("buff_duration")
end
function modifier_marine_submerge:OnRefresh(params)
    if IsServer() then
    end
end
function modifier_marine_submerge:OnDestroy()
    if IsServer() then
        local caster=self:GetParent()

        EmitSoundOn("Hero_NyxAssassin.Burrow.Out", caster)
		PlayEffOnUnit("particles/units/heroes/hero_nyx_assassin/nyx_assassin_burrow_exit.vpcf",caster)

        caster:AddNewModifier(caster, self:GetAbility(), "modifier_marine_submerge_buff", {
            duration = self.buff_duration
        })


    end
end
function modifier_marine_submerge:CheckState()
    local state = {
        [MODIFIER_STATE_ROOTED] = true,
        [MODIFIER_STATE_INVISIBLE] = true,
        [MODIFIER_STATE_DISARMED] = true,
    }
    return state
end

function modifier_marine_submerge:DeclareFunctions()
    return {MODIFIER_PROPERTY_MODEL_CHANGE, 
	MODIFIER_PROPERTY_IGNORE_CAST_ANGLE,
	MODIFIER_PROPERTY_DISABLE_TURNING,
	MODIFIER_PROPERTY_MOVESPEED_LIMIT
--	MODIFIER_PROPERTY_INVISIBILITY_LEVEL
}
end
function modifier_marine_submerge:GetEffectName()
    return "particles/units/heroes/hero_nyx_assassin/nyx_assassin_burrow_inground.vpcf"
end
function modifier_marine_submerge:GetEffectAttachType()
    return PATTACH_POINT_FOLLOW
end
function modifier_marine_submerge:GetModifierMoveSpeed_Limit()
    return 0
end
function modifier_marine_submerge:GetModifierDisableTurning()
    return 1
end

function modifier_marine_submerge:GetModifierIgnoreCastAngle()
    return 1
end
function modifier_marine_submerge:GetModifierModelChange()
    return "models/heroes/nerubian_assassin/mound.vmdl"
end


modifier_marine_submerge_buff = class({
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
function modifier_marine_submerge_buff:OnCreated()
    if not self:GetAbility() then return end
    local ability=self:GetAbility()
    self.attackspeed_bonus=ability:GetSpecialValueFor("attackspeed_bonus")
end
function modifier_marine_submerge_buff:DeclareFunctions()
    local funcs = {MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE}
    return funcs
end

function modifier_marine_submerge_buff:GetModifierAttackSpeedPercentage()

    return self.attackspeed_bonus
end
