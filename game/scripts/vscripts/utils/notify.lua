

-- 
-- GameRules:SendCustomMessage("#tip_duel_timeout", 0, 0)

function SendErrorMessage(pID, string,args)

    if pID then
        CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(pID), "display_custom_error", {
            message = "#" .. string,
            args=args
        })
        EmitSoundOnClient("General.Cancel", PlayerResource:GetPlayer(pID))    
    end
end

-- the built-in broadcast, it cannot target a single player
-- team -1 for all
-- example
-- "Custom_KillCreature"   "{s:player_name} <panel class='CombatEventKillIcon'/> {s:locstring_value}"
-- "Custom_ReceiveBenefit" "{s:player_name} received <font color='#ffd825'>{d:int_value}</font><panel class='CombatEventGoldIcon'/>({s:locstring_value}% crit)"
function fireLeftNotify(pid, bSameTeam,msg, data)

    local team=-1
    if bSameTeam then
        local pdata=Player:GetPData(pid)
        team=pdata.team
    end
    local gameEvent = {}
    gameEvent["player_id"] = pid
    gameEvent["teamnumber"] = team
    gameEvent["player_id2"] = data.pid2
    gameEvent["value"] = data.float0
    gameEvent["value1"] = data.float1
    gameEvent["value2"] = data.float2
    gameEvent["value3"] = data.float3
    gameEvent["int_value"] = data.int1
    gameEvent["int_value2"] = data.int2
    gameEvent["ability_name"] = data.ability
    gameEvent["locstring_value"] = data.str1
    gameEvent["locstring_value2"] = data.str2
    --

    if not data.rawText then
        gameEvent["message"] = "#" .. msg
    else
        gameEvent["message"]=msg
    end
    --
    FireGameEvent("dota_combat_event_message", gameEvent)
end

function batchFireLeftNotify(pid, bSameTeam,msg, data,count)
    for i = 1, count do
        fireLeftNotify(pid, bSameTeam,msg.."_"..i, data)
    end
end

function minimapNotice(pid, pos,duration)
    duration=duration or 5
    local player=nil
    local hero=nil
    local team=nil
    if pid and pid>=0 then
        hero = PlayerResource:GetSelectedHeroEntity(pid)
        team=PlayerResource:GetTeam(pid)
    end
    local dummy = CreateDummy(pid,Vector(0,0,0), duration)
    MinimapEvent(
        team,
        dummy,
        pos.x,
        pos.y,
        DOTA_MINIMAP_EVENT_HINT_LOCATION,
        1
    )
end

function Ping(pingType, entity, duration, location)
    if entity then
        local duration = duration or NOTIFICATIONS_DEFAULT_PING_DURATION
        local location = location or entity:GetAbsOrigin()
        MinimapEvent( DOTA_TEAM_GOODGUYS, entity, location.x, location.y, pingType, duration )
    else
        print("Notifications | ERROR: No entity for ping!")
    end
end
-- Emits a Green Ping to all SWAT Players at location for duration seconds
function PingGreen(entity, duration, location)
    Ping(DOTA_MINIMAP_EVENT_TEAMMATE_TELEPORTING, entity, duration, location)
end

-- Emits a Yellow (!) Ping to all SWAT Players at location for duration seconds
function PingAlert(entity, duration, location)
    Ping(DOTA_MINIMAP_EVENT_HINT_LOCATION, entity, duration, location)
end

-- Emits a Red Ping to all SWAT Players at location for duration seconds
function PingDanger(entity, duration, location)
    Ping(DOTA_MINIMAP_EVENT_ENEMY_TELEPORTING, entity, duration, location)
end

-- Emits a Yellow Ping to all SWAT Players at location for duration seconds
-- Also places a marker on the actual map for the duration
function PingTask(entity, duration, location)
    Ping(DOTA_MINIMAP_EVENT_TUTORIAL_TASK_ACTIVE, entity, duration, location)
    -- After the duration is up, we have to remove this task
    Timers:CreateTimer(duration, function()
        Ping(location, DOTA_MINIMAP_EVENT_TUTORIAL_TASK_FINISHED, duration)
    end)
end
