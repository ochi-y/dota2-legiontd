LinkLuaModifier("modifier_upgrade_farm", "ability/upgrade_farm.lua", LUA_MODIFIER_MOTION_NONE)
-- Abilities
upgrade_farm = class({})
upgrade_farm_x2 = upgrade_farm

function upgrade_farm:Spawn()
    self.upgradeCount = 0
end

function upgrade_farm:OnAbilityPhaseStart()
    local caster = self:GetCaster()
    local pid = caster:GetPlayerOwnerID()

    if self.upgradeCount >= self:GetMaxLevel() then
        SendErrorMessage(pid, "level_max")
        return false
    end
    local res = teckTree:UseResource(self:GetCaster(), self, nil, {
    })
    return res
end


-- function upgrade_farm:GetHealthCost(level)
-- 	if IsServer() then
-- 		return 0
-- 	else
-- 		return self:GetSpecialValueFor("gold")
-- 	end
-- end

function upgrade_farm:OnSpellStart()
    if not IsServer() then
        return
    end
	self:startEff()
end

function upgrade_farm:startEff()
    local caster = self:GetCaster()
    caster:StartGesture(ACT_DOTA_FLINCH)
    EmitSoundOnEntityForPlayer("Miniboss.Tormenter.Spawn", caster, caster:GetPlayerOwnerID())
    Timers:CreateTimer(0.2, function()
        local caster = self:GetCaster()

        if self.channelEff then
            ParticleManager:DestroyParticle(self.channelEff,false)
            self.channelEff=nil
        end

        self.channelEff=PlayEffOnUnit("particles/neutral_fx/miniboss_shield.vpcf", caster, {
            cpUnit = {
                [0] = {caster, PATTACH_POINT_FOLLOW, ""},
                [1] = {caster, PATTACH_POINT_FOLLOW, ""},
            },
            release=false
        })
    end)
end

function upgrade_farm:endEff()
    local caster = self:GetCaster()
    StopSoundOn("Miniboss.Tormenter.Spawn", caster)
    caster:FadeGesture(ACT_DOTA_FLINCH)
    if self.channelEff then
        ParticleManager:DestroyParticle(self.channelEff,false)
        self.channelEff=nil
    end
end

function upgrade_farm:OnChannelFinish(bInterrupted)
    if not IsServer() then
        return
    end

	self:endEff()


    teckTree:OnChannelFinish(self:GetCaster(), self, bInterrupted)
    if not bInterrupted then
        local foodIncrease = self:GetSpecialValueFor("foodIncrease")
        local caster = self:GetCaster()
        local pid = caster:GetPlayerOwnerID()
        Player:AddFood(pid, foodIncrease)

        self.upgradeCount = self.upgradeCount + 1
        if self:GetLevel() < self:GetMaxLevel() then
            self:UpgradeAbility(true)
        end

        -- if ENABLE_BUILDING_PARTICLE then
        --     SimplePlayEffOnUnit(caster, "particles/econ/events/ti9/hero_levelup_ti9.vpcf")
        -- end
        EmitSoundOnLocationForAllies(caster:GetAbsOrigin(), "Miniboss.Tormenter.Reflect", caster)

        

    end
end

