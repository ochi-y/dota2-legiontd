GameEvents.Subscribe("display_custom_error", function(msg) {
    let str=$.Localize(msg.message)
    if(msg.args){
        let realArgs=[]
        for (let index = 1; index < 20; index++) {
            const element = msg.args[index];
            realArgs.push(element)
        }
        str=str.format(...realArgs)
    }
    
    GameEvents.SendEventClientSide("dota_hud_error_message", {
        "splitscreenplayer": Players.GetLocalPlayer(),
        "reason": 80,
        "message": str
    });
});