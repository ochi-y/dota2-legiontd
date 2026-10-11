-- https://www.jianshu.com/p/0b4a80784707
function SimpleOverheadMsg(unit, type, number)
    SendOverheadEventMessage(nil, type, unit, number, nil)
end

-- function SimpleOverheadGoldMsg(pid, unit, gold)
--     SendOverheadEventMessage(PlayerResource:GetPlayer(pid), OVERHEAD_ALERT_GOLD,unit, gold, nil)
-- end


function SimplePlayExplosionAtLocation(eff, point, radius, radiusCP)
    local effect_cast = ParticleManager:CreateParticle(eff, PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(effect_cast, 0, point)
    ParticleManager:SetParticleControl(effect_cast, radiusCP, Vector(radius, radius, radius))
    ParticleManager:ReleaseParticleIndex(effect_cast)
end


function PlayEffOnLocation(eff, pos, params)
    if params == nil then
        params = {}
    end
    if params.bind == nil then
        params.bind = PATTACH_WORLDORIGIN
    end
    
    if params.release == nil then
        params.release = true
    end
    local effect_cast=nil
    if params.team then
        effect_cast = ParticleManager:CreateParticleForTeam(eff, params.bind, nil,params.team)
    else
        effect_cast = ParticleManager:CreateParticle(eff, params.bind, nil)
    end

    if params.cps == nil then
        params.cps = {0}
    end
    for i = 1, #params.cps do
        ParticleManager:SetParticleControl(effect_cast, params.cps[i], pos)
    end
    if params.cpKv then
        for k, v in pairs(params.cpKv) do
            if v then
                ParticleManager:SetParticleControl(effect_cast, k, v)
            end
        end
    end

    if params.cb then
        params.cb(effect_cast)
    end

    if params.release then
        ParticleManager:ReleaseParticleIndex(effect_cast)
    else
        return effect_cast
    end
end
function PlayEffOnUnit(eff, unit, params)
    if params == nil then
        params = {}
    end
    if params.bind == nil then
        params.bind = PATTACH_POINT_FOLLOW
    end
    -- if params.attach == nil then
    --     params.attach = "attach_hitloc"
    -- end
    if params.release == nil then
        params.release = true
    end
    local effect_cast = nil
    if params.player then
        effect_cast = ParticleManager:CreateParticleForPlayer(eff, params.bind, unit,params.player)
    else
        effect_cast = ParticleManager:CreateParticle(eff, params.bind, unit)
    end

    if params.cps == nil then
        params.cps = {0}
    end

    if unit then
        for i = 1, #params.cps do
            ParticleManager:SetParticleControlEnt(effect_cast, params.cps[i], unit, params.bind, params.attach,
                unit:GetAbsOrigin(), true)
        end
    end
   

    if params.cpKv then
        for k, v in pairs(params.cpKv) do
            if v then
                ParticleManager:SetParticleControl(effect_cast, k, v)
            end
        end
    end
    if params.cpUnit then
        for k, node in pairs(params.cpUnit) do
            if node then
                ParticleManager:SetParticleControlEnt(effect_cast, k, node[1], node[2], node[3], node[1]:GetAbsOrigin(),
                    true)
            end
        end
    end
    if params.cpDir then
        for k, v in pairs(params.cpDir) do
            if v then
                ParticleManager:SetParticleControlForward(effect_cast, k, v)
            end
        end
    end
    if params.mod then
        params.mod:AddParticle(effect_cast, false, false, -1, false, false)
    end
    if params.release and not params.mod then
        ParticleManager:ReleaseParticleIndex(effect_cast)
    else
        return effect_cast
    end
end

function SimplePlayEffOnUnit(unit, eff, cps, cpKv,bind)
    if bind==nil then
        bind=PATTACH_POINT_FOLLOW
    end
    local effect_cast = ParticleManager:CreateParticle(eff, bind, unit)
    if cps == nil then
        cps = {0, 1, 2, 3, 4}
    end
    for i = 1, #cps do
        ParticleManager:SetParticleControlEnt(effect_cast, cps[i], unit, bind, nil,
            unit:GetAbsOrigin(), true)
    end
    if cpKv then
        for k, v in pairs(cpKv) do
            if v then
                ParticleManager:SetParticleControl(effect_cast, k, v)
            end
        end
    end
    ParticleManager:ReleaseParticleIndex(effect_cast)
end

function SimplePlayHeadEff(unit, eff, cps, cpKv)
    local effect_cast = ParticleManager:CreateParticle(eff, PATTACH_ABSORIGIN_FOLLOW, unit)
    if cps == nil then
        cps = {0, 1, 2, 3, 4}
    end
    for i = 1, #cps do
        ParticleManager:SetParticleControlEnt(effect_cast, cps[i], unit, PATTACH_ABSORIGIN_FOLLOW, nil,
            unit:GetAbsOrigin(), true)
    end
    if cpKv then
        for k, v in pairs(cpKv) do
            if v then
                ParticleManager:SetParticleControl(effect_cast, k, v)
            end
        end
    end
    ParticleManager:ReleaseParticleIndex(effect_cast)
end

function SimplePlayEffAtlocation(eff, point, cps,cpKv,params)

    params=params or {}

    local effect_cast = ParticleManager:CreateParticle(eff, PATTACH_WORLDORIGIN, nil)
    if cps == nil then
        cps = {0, 1, 2, 3, 4}
    end
    for i = 1, #cps do
        ParticleManager:SetParticleControl(effect_cast, cps[i], point)
    end
   
    if cpKv then
        for k, v in pairs(cpKv) do
            if v then
                ParticleManager:SetParticleControl(effect_cast, k, v)
            end
        end
    end
    if not params.returnIndex then
        ParticleManager:ReleaseParticleIndex(effect_cast)    
    end
    return effect_cast
end

function SimpleAddEff(modifier, unit, particle, cps)
    local particle_cast = particle
    local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, unit)
    if cps == nil then
        cps = {0, 1, 2, 3, 4}
    end
    for i = 1, #cps do
        ParticleManager:SetParticleControlEnt(effect_cast, cps[i], unit, PATTACH_ABSORIGIN_FOLLOW, nil,
            unit:GetAbsOrigin(), -- unknown
            true -- unknown, true
        )
    end
    modifier:AddParticle(effect_cast, false, false, -1, false, false)
end
function SimpleAddHeadEff(modifier, unit, particle, cps)
    local particle_cast = particle
    local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_OVERHEAD_FOLLOW, unit)
    if cps == nil then
        cps = {0, 1, 2, 3, 4}
    end
    for i = 1, #cps do
        ParticleManager:SetParticleControlEnt(effect_cast, cps[i], unit, PATTACH_OVERHEAD_FOLLOW, nil,
            unit:GetAbsOrigin(), -- unknown
            true -- unknown, true
        )
    end
    modifier:AddParticle(effect_cast, false, false, -1, false, false)
end


function SimplePlayLink(particle,source,target,attach1,attach2,bone1,bone2)
    attach1=attach1 or PATTACH_POINT_FOLLOW
    attach2=attach2 or PATTACH_POINT_FOLLOW
    bone1=bone1 
    bone2=bone2 
    local effect_cast = ParticleManager:CreateParticle(particle, PATTACH_POINT_FOLLOW, source)
    ParticleManager:SetParticleControlEnt(effect_cast, 0, source, attach1, bone1,
        source:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(effect_cast, 1, target, attach2, bone2,
    target:GetAbsOrigin(), true)
    ParticleManager:ReleaseParticleIndex(effect_cast)
end

function SimpleCreateParticle(eff, unit)
    return ParticleManager:CreateParticle(eff, PATTACH_ABSORIGIN_FOLLOW, unit)
end

function SimpleSetControlEnt(particle, index, entity, attach)
    ParticleManager:SetParticleControlEnt(particle, index, entity, attach, nil, Vector(0, 0, 0), true)
end
function SimpleSetControl(particle, index, pos)
    ParticleManager:SetParticleControl(particle, index, pos)
end
function SimpleReleaseParticle(particle)
    ParticleManager:ReleaseParticleIndex(particle)
end


function PlayChooseHeroParticle(target)
    if target then
        EmitSoundOnEntityForPlayer("General.LevelUp", target,target:GetPlayerOwnerID())
        local pts = ParticleManager:CreateParticle(
            "particles/econ/events/ti6/hero_levelup_ti6.vpcf", PATTACH_CUSTOMORIGIN, target)
        ParticleManager:SetParticleControlEnt(pts, 0, target, PATTACH_ABSORIGIN_FOLLOW, nil,
        target:GetAbsOrigin(), true)
        ParticleManager:ReleaseParticleIndex(pts)
    end
end


function PlayUpgradeParticle(target,params)

    if not params then
        params={}
    end
    if target then
        --EmitSoundOn("General.LevelUp", target)
        local sound=params.sound or "General.LevelUp"
        if params.playerSound then
	        EmitSoundOnLocationForPlayer(sound,target:GetAbsOrigin() ,target:GetPlayerOwnerID())
        else
            EmitSoundOnLocationForAllies(target:GetAbsOrigin(),sound, target)
        end
        
        local effName=params.particle or "particles/econ/events/ti6/hero_levelup_ti6.vpcf"

        Timers:CreateTimer(FrameTime(), function()
            SimplePlayEffOnUnit(target,effName)    
        end)
        -- local pts = ParticleManager:CreateParticle(
        --     effName, PATTACH_CUSTOMORIGIN, target)
        -- ParticleManager:SetParticleControlEnt(pts, 0, target, PATTACH_ABSORIGIN_FOLLOW, nil,
        -- target:GetAbsOrigin(), true)
        -- ParticleManager:ReleaseParticleIndex(pts)
    end
end

function PlayRefreshEff(target)
    if target then
        EmitSoundOn("DOTA_Item.Refresher.Activate", target)
        local pts = ParticleManager:CreateParticle("particles/items2_fx/refresher.vpcf", PATTACH_CUSTOMORIGIN, target)
        ParticleManager:SetParticleControl(pts, 0, target:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(pts)
    end
end
