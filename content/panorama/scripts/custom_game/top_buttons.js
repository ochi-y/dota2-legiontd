const hud = $.GetContextPanel().GetParent().GetParent().GetParent();


const centerhud = hud.FindChildTraverse("lower_hud")

function onClickLeaderboard(mode) {
    GameEvents.SendEventClientSide("top_buttons", { name: "leaderboard", mode });
}
function CreateErrorMessage(msg) {
    var reason = msg.reason || 80;
    if (msg.message) {
        GameEvents.SendEventClientSide("dota_hud_error_message", { "splitscreenplayer": 0, "reason": reason, "message": msg.message });
    } else {
        GameEvents.SendEventClientSide("dota_hud_error_message", { "splitscreenplayer": 0, "reason": reason });
    }
}

function onClickWiki() {
    GameEvents.SendEventClientSide("top_buttons", { name: "wiki" });
}

function onClickWikiPro() {
    GameEvents.SendEventClientSide("top_buttons", { name: "wiki_pro" });
}

function onClickSkin() {
    GameEvents.SendEventClientSide("top_buttons", { name: "skin" });
}
function onClickHome() {
    GameEvents.SendEventClientSide("top_buttons", { name: "home" });
}
function onClickDiscord() {
    //GameEvents.SendEventClientSide("top_buttons", { name: "discord" });
    // 
    //
}

(function () {
    // Game.AddCommand( "CustomGameExecuteAbility1", OnExecuteAbility1ButtonPressed, "", 0 );
    if (Game.IsInToolsMode()) {
        $.GetContextPanel().AddClass("HeroDemo")
    }

})();
