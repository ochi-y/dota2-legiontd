var WEB_API_TESTING = Game.IsInToolsMode() && false;

function SubscribeToNetTableKey(tableName, key, callback) {
    var immediateValue = CustomNetTables.GetTableValue(tableName, key) || {};
    if (immediateValue != null) callback(immediateValue);
    CustomNetTables.SubscribeNetTableListener(tableName, function(_tableName, currentKey, value) {
        if (currentKey === key && value != null) callback(value);
    });
}

function GetDotaHud() {
    var p = $.GetContextPanel();
    while (p !== null && p.id !== 'Hud') {
        p = p.GetParent();
    }
    if (p === null) {
        throw new HudNotFoundException('Could not find Hud root as parent of panel with id: ' + $.GetContextPanel().id);
    } else {
        return p;
    }
}


function csFormat(s,params) {
    var args = params;
    return s.replace(/{(\d+)}/g, function(match, number) { 
    return typeof args[number] != 'undefined'
        ? args[number]
        : match
    ;
    });
}

String.prototype.format = function() {
    var args = arguments;
    return this.replace(/{(\d+)}/g, function(match, number) { 
    return typeof args[number] != 'undefined'
        ? args[number]
        : match
    ;
    });
};

function FindDotaHudElement(id) {
    return GetDotaHud().FindChildTraverse(id);
}

function FillTopBarPlayer(TeamContainer) {
    // Fill players top bar in case on partial lobbies
    var playerCount = TeamContainer.GetChildCount();
    for (var i = playerCount + 1; i <= 12; i++) {
        var newPlayer = $.CreatePanel('DOTATopBarPlayer', TeamContainer, 'RadiantPlayer-1');
        if (newPlayer) {
            newPlayer.FindChildTraverse('PlayerColor').style.backgroundColor = '#FFFFFFFF';
        }
        newPlayer.SetHasClass('EnemyTeam', true);
    }
}

function error_message(params) {
    GameEvents.SendEventClientSide("dota_hud_error_message", { "splotscreenplayer": Players.GetLocalPlayer(), "reson": 80, "message": msg });
}

var Util = {csFormat};

var parent = $.GetContextPanel().GetParent();
while (parent.GetParent() != null)
    parent = parent.GetParent();

var hudElements = parent.FindChildTraverse('HUDElements').Children();


Util.ColorString = (function(str, color) {
    return "<font color=\"" + (color || "#FFFFFF") + "\">" + str + "</font>";
});

Util.ColorDescString = (function(str, color) {
    var result = str.replace(/%[^%]+%{1,2}/g, function(match, token) {
        return "<font color=\"" + (color || "#FFFFFF") + "\">" + match + "</font>";
    });
    return result;
});

(function() {
    GameUI.CustomUIConfig().Util = Util;
})()


// let s = "Gives you a %chance%%  chance to finish off enemies with a single blow!%c1%%%c2%"

// let matchs = s.matchAll(/%[^%]+%{1,2}/g)

// $.Msg(1212, matchs)
// for (const match of matchs) {
//     $.Msg(match)
// }

// var result = s.replace(/%[^%]+%{1,2}/g, function(match, token) {
//     return "<font color=\"" + ("#FFFFFF") + "\">" + match + "</font>";
// });
// $.Msg(result)

//