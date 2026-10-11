LinkLuaModifier("modifier_upgrade_lumber_farm", "ability/upgrade_lumber_farm.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_upgrade_lumber_farm_init", "ability/upgrade_lumber_farm.lua", LUA_MODIFIER_MOTION_NONE)
-- Abilities
if upgrade_lumber_farm == nil then
    upgrade_lumber_farm = class({})
end

function upgrade_lumber_farm:GetIntrinsicModifierName()
    return "modifier_upgrade_lumber_farm_init"
end
-- function upgrade_lumber_farm:GetHealthCost(level)
-- 	if IsServer() then
-- 		return 0
-- 	else
-- 		return self:GetSpecialValueFor("gold")
-- 	end
-- end

function upgrade_lumber_farm:checkValue()
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

function upgrade_lumber_farm:OnAbilityPhaseStart()

    if not IsServer() then return end

    local caster=self:GetCaster()
    local pid = caster:GetPlayerOwnerID()
    
    local pdata=Player:GetPData(pid)

    local orderPlayerId=self.lastOrderPlayerId or pid

    if not self:checkValue() then
        return false
    end
    -- 

    
    if self:GetLevel() == self:GetMaxLevel() then
        print("[legiontd] cant upgrade")
        -- caster:Stop()
		SendErrorMessage(orderPlayerId,"level_max")
        return false
    end
    -- 
    local res = teckTree:UseResource(self:GetCaster(), self,nil,{dontRefundGold=true})
    return res
end


function upgrade_lumber_farm:OnSpellStart()
    if not IsServer() then
        return
    end
    local caster = self:GetCaster()
    local pid = caster:GetPlayerOwnerID()
    self:startEff()
end

function upgrade_lumber_farm:startEff()
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

function upgrade_lumber_farm:endEff()
    local caster = self:GetCaster()
    StopSoundOn("Outpost.Reward", caster)
    caster:FadeGesture(ACT_DOTA_CHANNEL_ABILITY_1)
    if self.channelEff then
        ParticleManager:DestroyParticle(self.channelEff,false)
        self.channelEff=nil
    end
end

function upgrade_lumber_farm:startTreeCutter(caster, pid)
    local point = Entities:FindByName(nil, "ent_tree_" .. Player:GetPData(caster:GetPlayerOwnerID()).laneIndex)
        :GetAbsOrigin()
    local trees = GridNav:GetAllTreesAroundPoint(point, 600, false)
    for i = 1, #trees do
        if trees[i].cuted then

        else
            -- local eff="particles/units/heroes/hero_treant/treant_eyesintheforest.vpcf"
            local eff = "particles/units/heroes/hero_treant/treant_livingarmor.vpcf"
            local particle=SimplePlayEffAtlocation(eff, trees[i]:GetAbsOrigin(), {0, 1, 2, 3},nil,{returnIndex=true})

            trees[i].cuted = true
            local thinker = CreateModifierThinker(caster, self, "modifier_upgrade_lumber_farm", {},
                trees[i]:GetAbsOrigin(), caster:GetTeamNumber(), false)
            thinker:SetOwner(PlayerResource:GetSelectedHeroEntity(pid))

            thinker:FindModifierByName("modifier_upgrade_lumber_farm"):AddParticle(particle, false, false, -1, false, false)

            local pdata = Player:GetPData(pid)
            pdata.lumberWoker = pdata.lumberWoker + 1
            EmitSoundOn("Hero_Treant.LivingArmor.Target", thinker)
            table.insert(pdata.treeThinkers,thinker)
            
            break
        end
    end
end



function upgrade_lumber_farm:OnChannelFinish(bInterrupted)
    if not IsServer() then
        return
    end
    self:endEff()

    if not self:checkValue() then
        bInterrupted=true
    end
    print("OnChannelFinish",bInterrupted)
    teckTree:OnChannelFinish(self:GetCaster(), self, bInterrupted)
    local caster = self:GetCaster()
    local pid = caster:GetPlayerOwnerID()
    if not bInterrupted then
        self:startTreeCutter(caster, pid)
        self:SetLevel(self:GetLevel() + 1)

        EmitSoundOnLocationForAllies(caster:GetAbsOrigin(), "Outpost.Captured.Notification", caster)

        

        -- if ENABLE_BUILDING_PARTICLE then
        --     SimplePlayEffOnUnit(caster, "particles/econ/events/ti10/hero_levelup_ti10.vpcf")
        -- end
    end
end

---------------------------------------------------------------------
-- Modifiers
modifier_upgrade_lumber_farm = class({
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
function modifier_upgrade_lumber_farm:OnCreated(params)
    if not IsServer() then
        return
    end
    self:StartIntervalThink(10)
    self.ownerPid = self:GetCaster():GetPlayerOwnerID()
    AddFOWViewer(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), 128, 10.1, false)
end

function modifier_upgrade_lumber_farm:OnRefresh(params)
    if IsServer() then
    end
end

function modifier_upgrade_lumber_farm:OnDestroy()
    if IsServer() then
    end
end

function modifier_upgrade_lumber_farm:DeclareFunctions()
    return {}
end

function modifier_upgrade_lumber_farm:OnIntervalThink()
    if not IsServer() then
        return
    end
    if IsActiveUnit(self:GetCaster()) then
        if Convars:GetInt("dota_legiontd_paused") == 1 and GamePlay.state=="pre-round" then
            return
        end
        local pid = self.ownerPid
        local pdata = Player:GetPData(pid)
        local wood = pdata.woodCollect
        if wood then
            -- PopupHealing(self:GetParent(), wood)
            -- print("lumber")
            PopupNumbers(self:GetParent(), "heal", Vector(0, 255, 0), 2.0, wood, POPUP_SYMBOL_PRE_PLUS, nil, {
                team=PlayerResource:GetTeam(pid),
                usePos=true,
            })
            Player:ModifyWood(self.ownerPid, wood)
        end
        AddFOWViewer(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), 128, 10.1, false)
    end
end

---------------------------------------------------------------------
-- Modifiers
modifier_upgrade_lumber_farm_init = class({
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

function modifier_upgrade_lumber_farm_init:OnCreated(params)
    if not IsServer() then
        return
    end

    Timers:CreateTimer(1, function()
        local pid = self:GetParent():GetPlayerOwnerID()
        local pdata = Player:GetPData(pid)
        if pdata then
            Timers:CreateTimer(0, function()
                self:GetAbility():startTreeCutter(self:GetParent(), pid)
            end)
            return nil
        else
            return 1
        end
    end)
    --
end
function modifier_upgrade_lumber_farm_init:OnRefresh(params)
    if IsServer() then
    end
end
function modifier_upgrade_lumber_farm_init:OnDestroy()
    if IsServer() then
    end
end
function modifier_upgrade_lumber_farm_init:DeclareFunctions()
    return {}
end
