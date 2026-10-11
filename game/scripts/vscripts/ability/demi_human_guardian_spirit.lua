LinkLuaModifier("modifier_demi_human_guardian_spirit", "ability/demi_human_guardian_spirit.lua",
    LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_demi_human_guardian_spirit_buff", "ability/demi_human_guardian_spirit.lua",
    LUA_MODIFIER_MOTION_NONE)
-- Abilities
if demi_human_guardian_spirit == nil then
    demi_human_guardian_spirit = class({})
end
function demi_human_guardian_spirit:GetIntrinsicModifierName()
    return "modifier_demi_human_guardian_spirit"
end
---------------------------------------------------------------------
-- Modifiers
modifier_demi_human_guardian_spirit = class({
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
function modifier_demi_human_guardian_spirit:OnCreated(params)
    if not self:GetAbility() then return end
   
    

    if not IsServer() then return end
    -- self:trigger()
end
function modifier_demi_human_guardian_spirit:trigger()

    if not IsServer() then return end
    local ability=self:GetAbility()
    self.radius=ability:GetSpecialValueFor("radius")


    Timers:CreateTimer(0.5, function()
        local eff = "particles/legiontd/demi_human/guardian_spirit.vpcf"
        local caster = self:GetParent()
        if IsActiveUnit(caster) then
            if caster:IsStunned() then
                return 0.1  
            end  
            -- if IsCustomBuilding(caster) then  
            --     return 
            -- end  
            local radius=self.radius

            local friends = SimpleFindFriend(caster:GetTeamNumber(), caster:GetAbsOrigin(), radius)
            PlayEffOnUnit(eff,caster,{
                cps={0,2,3}
            })
            caster:StartGesture(ACT_DOTA_CAST_ABILITY_2)

            EmitSoundOn("Hero_Oracle.FortunesEnd.Target", caster)
            for key, friend in pairs(friends) do
				if friend~=caster then
					friend:AddNewModifier(caster, self:GetAbility(), "modifier_demi_human_guardian_spirit_buff", {})
				end
            end
        end
    end)
end
function modifier_demi_human_guardian_spirit:OnRefresh(params)
    if IsServer() then
    end
end
function modifier_demi_human_guardian_spirit:OnDestroy()
    if IsServer() then
    end
end
function modifier_demi_human_guardian_spirit:DeclareFunctions()
    return {}
end

---------------------------------------------------------------------
-- Modifiers
modifier_demi_human_guardian_spirit_buff = class({
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
function modifier_demi_human_guardian_spirit_buff:OnCreated(params)
    if not self:GetAbility() then return end
    local ability=self:GetAbility()
    self.damage_reduce=ability:GetSpecialValueFor("damage_reduce")
    
end
function modifier_demi_human_guardian_spirit_buff:OnRefresh(params)
    if IsServer() then
    end
end
function modifier_demi_human_guardian_spirit_buff:OnDestroy()
    if IsServer() then
    end
end
function modifier_demi_human_guardian_spirit_buff:DeclareFunctions()
    return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end


function modifier_demi_human_guardian_spirit_buff:GetModifierIncomingDamage_Percentage()
    return -self.damage_reduce
end


function modifier_demi_human_guardian_spirit_buff:GetStatusEffectName()
    return "particles/status_fx/status_effect_shield_rune.vpcf"
end
function modifier_demi_human_guardian_spirit_buff:StatusEffectPriority()
    return 1000
end
