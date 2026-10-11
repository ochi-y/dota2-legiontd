war3_reincarnation = {}

LinkLuaModifier("modifier_war3_reincarnation", "ability/war3_reincarnation", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_war3_reincarnation_active", "ability/war3_reincarnation", LUA_MODIFIER_MOTION_NONE)

function war3_reincarnation:GetIntrinsicModifierName()
    return "modifier_war3_reincarnation"
end

modifier_war3_reincarnation = {}

function modifier_war3_reincarnation:IsHidden()
    return true
end

function modifier_war3_reincarnation:DeclareFunctions()
    return {MODIFIER_PROPERTY_REINCARNATION, MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_war3_reincarnation:GetModifierIncomingDamage_Percentage(data)
    if not IsServer() then
        return
    end
    local parent = self:GetParent()
    local ability = self:GetAbility()
    local reincarnate_time = self:GetAbility():GetSpecialValueFor("reincarnate_time")
    if parent:IsHero() then
        return 0
    end
    local health = self:GetParent():GetHealth()
    if (health - data.damage <= 0) then
        if self:GetAbility():IsFullyCastable() then
            parent:StartGestureWithPlaybackRate(ACT_DOTA_DIE, 0.5)
            parent:AddNewModifier(parent, ability, "modifier_war3_reincarnation_active", {
                duration = reincarnate_time
            })

            -- EmitSoundOn("Hero_SkeletonKing.Death", parent)

			EmitSoundOn("Hero_SkeletonKing.Reincarnate", parent)
            PlayEffOnUnit("particles/units/heroes/hero_skeletonking/wraith_king_death.vpcf", parent)

			PlayEffOnUnit("particles/units/heroes/hero_skeletonking/wraith_king_reincarnate.vpcf", parent)
            return -100
        end
    end
    return 0
end

function modifier_war3_reincarnation:ReincarnateTime(params)
    if IsServer() then
        if self:GetAbility():IsFullyCastable() then
            self:Reincarnate()
            return self:GetAbility():GetSpecialValueFor("reincarnate_time")
        end
        return 0
    end
end

function modifier_war3_reincarnation:Reincarnate()
    self:GetAbility():UseResources(true, false, true)

    local effect_cast = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_skeletonking/wraith_king_reincarnate.vpcf", PATTACH_ABSORIGIN, self:GetParent())
    ParticleManager:SetParticleControl(effect_cast, 0, self:GetParent():GetOrigin())
    ParticleManager:SetParticleControl(effect_cast, 1,
        Vector(self:GetAbility():GetSpecialValueFor("reincarnate_time"), 0, 0))
    ParticleManager:ReleaseParticleIndex(effect_cast)
    
end

if modifier_war3_reincarnation_active == nil then
    modifier_war3_reincarnation_active = class({})
end

function modifier_war3_reincarnation_active:CheckState()
    return {
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_OUT_OF_GAME] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true
    }
end
function modifier_war3_reincarnation_active:OnCreated(params)
    if IsServer() then
        -- local eff="particles/generic_hero_status/death_tombstone.vpcf"
        local caster = self:GetParent()
        if caster then
            -- caster:AddEffects(EF_NODRAW)
            caster:Purge(true, true, false, true, false)
            -- local particleName = eff
            -- local duration = 3
            -- local pts = ParticleManager:CreateParticle(particleName,PATTACH_WORLDORIGIN,caster)
            -- ParticleManager:SetParticleControl(pts,0,caster:GetAbsOrigin())
            -- ParticleManager:SetParticleControl(pts,2,Vector(duration,0,0))
            -- ParticleManager:ReleaseParticleIndex(pts)
        end
    end
end

function modifier_war3_reincarnation_active:OnRefresh(params)
    if IsServer() then
    end
end
function modifier_war3_reincarnation_active:OnDestroy()
    if IsServer() then
        local caster = self:GetParent()
        if caster then
            caster:SetHealth(caster:GetMaxHealth())
            caster:SetMana(caster:GetMaxMana())
            -- caster:RemoveEffects(EF_NODRAW)
            caster:FadeGesture(ACT_DOTA_DIE)
            
           --  EmitSoundOn("Hero_Underlord.Portal.Out", caster)
            -- EmitSoundOn("Hero_SkeletonKing.Reincarnate.Ghost", caster)
        end
    end
end
function modifier_war3_reincarnation_active:DeclareFunctions()
    return {}
end
function modifier_war3_reincarnation_active:IsPurgable()
    return false
end
