--Abilities

upgrade_lumber_farm_speedup = class({})


upgrade_lumber_farm_speedup_x2 = upgrade_lumber_farm_speedup


function upgrade_lumber_farm_speedup:checkValue()
    local caster=self:GetCaster()
    local pid = caster:GetPlayerOwnerID()
    
    local pdata=Player:GetPData(pid)

    local orderPlayerId=self.lastOrderPlayerId or pid

    if GamePlay:Mode("limited_income") then
        if pdata.creepValue<self:GetSpecialValueFor("value_needed") then
            SendErrorMessage(orderPlayerId,"no_enough_value")
            return false
        end
    end
    return true
end

function upgrade_lumber_farm_speedup:OnAbilityPhaseStart()
    local caster=self:GetCaster()
    local pid = caster:GetPlayerOwnerID()

    local pdata=Player:GetPData(pid)

    local orderPlayerId=self.lastOrderPlayerId or pid

    if not self:checkValue() then
        return false
    end

    if self.upgradeCount>=self:GetMaxLevel() then
		SendErrorMessage(pid,"level_max")
        return false
    end
    local res = teckTree:UseResource(self:GetCaster(), self,nil,{dontRefundGold=true})
    return res
end



-- function upgrade_lumber_farm_speedup:GetHealthCost(level)
-- 	if IsServer() then
-- 		return 0
-- 	else
-- 		return self:GetSpecialValueFor("gold")
-- 	end
-- end

function upgrade_lumber_farm_speedup:Spawn()
	self.upgradeCount=0
end

function upgrade_lumber_farm_speedup:OnSpellStart()
    if not IsServer() then return end
	local caster = self:GetCaster()
	local pid=caster:GetPlayerOwnerID()
	self:startEff()
end


function upgrade_lumber_farm_speedup:startEff()
    local caster = self:GetCaster()
    caster:StartGesture(ACT_DOTA_CHANNEL_ABILITY_1)
    EmitSoundOnEntityForPlayer("Outpost.Reward", caster, caster:GetPlayerOwnerID())
    Timers:CreateTimer(0.2, function()
        local caster = self:GetCaster()

        if self.channelEff then
            ParticleManager:DestroyParticle(self.channelEff,false)
            self.channelEff=nil
        end

        self.channelEff=PlayEffOnUnit("particles/world_outpost/world_outpost_radiant_ambient.vpcf", caster, {
            cpUnit = {
                [0] = {caster, PATTACH_POINT_FOLLOW, "attach_fx"},
                [1] = {caster, PATTACH_POINT_FOLLOW, ""},
            },
            release=false
        })
    end)
end

function upgrade_lumber_farm_speedup:endEff()
    local caster = self:GetCaster()
    StopSoundOn("Outpost.Reward", caster)
    caster:FadeGesture(ACT_DOTA_CHANNEL_ABILITY_1)
    if self.channelEff then
        ParticleManager:DestroyParticle(self.channelEff,false)
        self.channelEff=nil
    end
end

function upgrade_lumber_farm_speedup:OnChannelFinish(bInterrupted)
	if not IsServer() then return end

	self:endEff()

    if not self:checkValue() then
        bInterrupted=true
    end

    teckTree:OnChannelFinish(self:GetCaster(), self, bInterrupted)
	local caster = self:GetCaster()
	local pid=caster:GetPlayerOwnerID()
	if not bInterrupted then
		local pdata=Player:GetPData(pid)
		pdata.woodCollect=pdata.woodCollect+1
		Player:SyncNetTable(pid)
		self.upgradeCount=self.upgradeCount+1
		if self:GetLevel()<self:GetMaxLevel() then
			self:UpgradeAbility(true)
		end
		EmitSoundOnLocationForAllies(caster:GetAbsOrigin(),"ui.trophy_levelup", caster)
		if ENABLE_BUILDING_PARTICLE then
			SimplePlayEffOnUnit(caster,"particles/econ/events/fall_2021/hero_levelup_fall_2021.vpcf")
		end

	end
end

