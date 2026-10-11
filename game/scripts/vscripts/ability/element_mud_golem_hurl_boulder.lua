LinkLuaModifier("modifier_element_mud_golem_hurl_boulder_tag", "ability/element_mud_golem_hurl_boulder",
    LUA_MODIFIER_MOTION_NONE)

element_mud_golem_hurl_boulder = class({})
--------------------------------------------------------------------------------



function element_mud_golem_hurl_boulder:OnSpellStart()
    local bolt_speed = self:GetSpecialValueFor("speed")
    local target=self:GetCursorTarget()
    local count=1

    local units=FindAbilityTarget(self,target:GetAbsOrigin(),500,{})
    for i = 1, count, 1 do
        if units[i] then
            local info = {
                EffectName = "particles/neutral_fx/mud_golem_hurl_boulder.vpcf",
                Ability = self,
                iMoveSpeed = bolt_speed,
                Source = self:GetCaster(),
                Target = units[i],
                bDodgeable = true,
                bProvidesVision = true,
                iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
                iVisionRadius = 100,
                iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2
            }
            ProjectileManager:CreateTrackingProjectile(info)
        end
    end

    EmitSoundOn("n_mud_golem.Boulder.Cast", self:GetCaster())
end

--------------------------------------------------------------------------------
function element_mud_golem_hurl_boulder:OnProjectileHit(hTarget, vLocation)
    if not self:IsNull() and not self:GetCaster():IsNull() and hTarget ~= nil and (not hTarget:IsInvulnerable()) and
        (not hTarget:TriggerSpellAbsorb(self)) then
        EmitSoundOn("n_mud_golem.Boulder.Target", hTarget)
        local damage = self:GetSpecialValueFor("damage")
        local duration = self:GetSpecialValueFor("duration")

        duration = duration * (1 - CalUnitStatusResistance(hTarget))

        local vDamage = {
            victim = hTarget,
            attacker = self:GetCaster(),
            damage = damage,
            damage_type = DAMAGE_TYPE_MAGICAL
        }
        ApplyDamage(vDamage)
        if self and hTarget and not hTarget:IsNull() then
            hTarget:AddNewModifier(self:GetCaster(), self, "modifier_stunned", {
                duration = duration
            })
        end
    end
    return true
end
--------------------------------------------------------------------------------

modifier_element_mud_golem_hurl_boulder_tag = class({
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
