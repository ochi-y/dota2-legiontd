

function testMessage()
    local gameEvent = {}
    gameEvent["player_id"] = 2
    gameEvent["int_value"] = 123
    gameEvent["locstring_value"] = "1212"
    gameEvent["teamnumber"] = DOTA_TEAM_GOODGUYS
    gameEvent["message"] = "#Custom_KillCreature"
    FireGameEvent( "dota_combat_event_message", gameEvent )
end



