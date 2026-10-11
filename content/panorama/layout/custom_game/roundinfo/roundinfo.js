var gContent = $.GetContextPanel().FindChildInLayoutFile("bigContent");
var gBigInfo = $.GetContextPanel().FindChildInLayoutFile("bigInfo");

var gRoundHeadBg = $.GetContextPanel().FindChildInLayoutFile("roundHeadBg");
var gWestPlayers = $.GetContextPanel().FindChildInLayoutFile("goodPlayers");
var gEastPlayers = $.GetContextPanel().FindChildInLayoutFile("badPlayers");

var gModesBoard = $.GetContextPanel().FindChildInLayoutFile("modesBoard");

console.log = $.Msg;

var gGamePlayData = CustomNetTables.GetTableValue("gameplay", "all")
CustomNetTables.SubscribeNetTableListener("gameplay", function() {
    gGamePlayData = CustomNetTables.GetTableValue("gameplay", "all")

    UpdateView()
})
var gPlayerData = CustomNetTables.GetAllTableValues("player")
CustomNetTables.SubscribeNetTableListener("player", function() {
    gPlayerData = CustomNetTables.GetAllTableValues("player")
    UpdateView()
})


function calModeStr() {
    if (!gGamePlayData.secondaryModes) {
        return ""
    }
    const strs = []
    for (const k in gGamePlayData.secondaryModes) {
        if (gGamePlayData.secondaryModes[k]) {
            strs.push(k)
        }
    }
    strs.sort()
    let res = ""
    for (let index = 0; index < strs.length; index++) {
        res = res + strs[index] + " "
    }
    return res
}

function getPlayerData(pid) {

    var v = gPlayerData.find(v => {
        return parseInt(v.key) == pid
    })
    if (v) {
        return v.value
    }
    return null
}

var preState = null
var preRound = 0

var lastTime = Game.GetGameTime()
var timer = 0



function secondsToTime(totalSeconds) {
    totalSeconds = Math.floor(totalSeconds)
    let hours = Math.floor(totalSeconds / 3600);
    totalSeconds %= 3600;
    let minutes = Math.floor(totalSeconds / 60);
    let seconds = totalSeconds % 60;
    // If you want strings with leading zeroes:
    minutes = String(minutes).padStart(2, "0");
    hours = String(hours).padStart(2, "0");
    seconds = String(seconds).padStart(2, "0");
    return hours + ":" + minutes + ":" + seconds
}

function intToARGB(i) {
    return ('00' + (i & 0xFF).toString(16)).substr(-2) +
        ('00' + ((i >> 8) & 0xFF).toString(16)).substr(-2) +
        ('00' + ((i >> 16) & 0xFF).toString(16)).substr(-2) +
        ('00' + ((i >> 24) & 0xFF).toString(16)).substr(-2);
}


function updateSettings() {
    if (gGamePlayData.primaryMode) {
        let shorts = {
            all_pick: "AP",
            all_prophet: "PR",
            host_pick: "HP",

        }
        let btn = $("#game_mode")
        btn.text = shorts[gGamePlayData.primaryMode]

        btn.SetPanelEvent('onmouseover', function() {
            $.DispatchEvent("DOTAShowTextTooltip", btn, $.Localize("#ui_mode_" + gGamePlayData.primaryMode + "_desc"));
        });
        btn.SetPanelEvent('onmouseout', function() {
            $.DispatchEvent("DOTAHideTextTooltip", btn);
        });
    }

    if (gGamePlayData.secondaryModes) {
        let sellMode = "normal_sell"
        if (gGamePlayData.secondaryModes["fs"]) {
            sellMode = "free_sell"
        }
        if (gGamePlayData.secondaryModes["ls"]) {
            sellMode = "last_sell"
        }
        let shorts = {
            normal_sell: "NS",
            free_sell: "FS",
            last_sell: "LS",
        }
        let btn = $("#sell_mode")
        btn.text = shorts[sellMode]

        btn.SetPanelEvent('onmouseover', function() {
            $.DispatchEvent("DOTAShowTextTooltip", btn, $.Localize("#ui_sellmode_" + sellMode + "_desc"));
        });
        btn.SetPanelEvent('onmouseout', function() {
            $.DispatchEvent("DOTAHideTextTooltip", btn);
        });
    }
    if (gGamePlayData.secondaryModes) {
        if (gGamePlayData.secondaryModes["mo"]) {
            $("#mind_open").RemoveClass("Hidden")
        } else {
            $("#mind_open").AddClass("Hidden")
        }

        if (gGamePlayData.secondaryModes["hc"]) {
            $("#half_creep").RemoveClass("Hidden")
        } else {
            $("#half_creep").AddClass("Hidden")
        }
        if (gGamePlayData.secondaryModes["x2"]) {
            $("#x2").RemoveClass("Hidden")
        } else {
            $("#x2").AddClass("Hidden")
        }
        if (gGamePlayData.secondaryModes["creep_stack"]) {
            $("#creep_stack").RemoveClass("Hidden")
        } else {
            $("#creep_stack").AddClass("Hidden")
        }

        if (gGamePlayData.secondaryModes["fighter_stack"]) {
            $("#fighter_stack").RemoveClass("Hidden")
        } else {
            $("#fighter_stack").AddClass("Hidden")
        }
        if (gGamePlayData.secondaryModes["limited_income"]) {
            $("#limited_income").RemoveClass("Hidden")
        } else {
            $("#limited_income").AddClass("Hidden")
        }
    }
}

function UpdateView() {
    if (!gGamePlayData) {
        return
    }

    const state = gGamePlayData["state"] || ""
    const round = gGamePlayData["round"] || ""

    // if (preState != state || preRound != round) {
    //     gProgress = 0
    //     gProgressTotal = 1
    // }

    if (state == "idle") {
        gBigInfo.SetDialogVariable("rount_info", "--")
            // gBigInfo.SetDialogVariable("rount_timer", "--")
    } else if (state == "pre-round") {
        gBigInfo.SetDialogVariable("rount_info", $.Localize("#round_" + round) + " In")
    } else if (state == "in-round") {
        gBigInfo.SetDialogVariable("rount_info", $.Localize("#round_" + round) + " In")
            // gBigInfo.SetDialogVariable("rount_timer", secondsToTime(0))
    }
    //
    gBigInfo.SetDialogVariable("west_alive", "" + gGamePlayData["westAlive"] || "1")
    gBigInfo.SetDialogVariable("west_king_hp", "HP " + gGamePlayData["westKingHp"] || "0")
    gBigInfo.SetDialogVariable("east_alive", "" + gGamePlayData["eastAlive"] || "0")
    gBigInfo.SetDialogVariable("east_king_hp", "HP " + gGamePlayData["eastKingHp"] || "0")

    // const modeStr = calModeStr()
    // if (modeStr == "") {
    //     gModesBoard.AddClass("Hidden")
    // } else {
    //     gModesBoard.RemoveClass("Hidden")
    // }

    //gBigInfo.SetDialogVariable("game_mode", modeStr)


    updateSettings()


    if (gGamePlayData["goodMaxAlive"] == 0) {
        gGamePlayData["goodMaxAlive"] = 1
    }
    if (gGamePlayData["westKingMaxHp"] == 0) {
        gGamePlayData["westKingMaxHp"] = 1
    }
    if (gGamePlayData["badMaxAlive"] == 0) {
        gGamePlayData["badMaxAlive"] = 1
    }
    if (gGamePlayData["eastKingMaxHp"] == 0) {
        gGamePlayData["eastKingMaxHp"] = 1
    }

    var westAliveColor = $.GetContextPanel().FindChildInLayoutFile("westAliveColor");
    westAliveColor.style.width = "" + 100 * gGamePlayData["westAlive"] / gGamePlayData["goodMaxAlive"] + "%"

    var westHpColor = $.GetContextPanel().FindChildInLayoutFile("westHpColor");
    westHpColor.style.width = "" + 100 * gGamePlayData["westKingHp"] / gGamePlayData["westKingMaxHp"] + "%"

    var eastAliveColor = $.GetContextPanel().FindChildInLayoutFile("eastAliveColor");
    eastAliveColor.style.width = "" + 100 * gGamePlayData["eastAlive"] / gGamePlayData["badMaxAlive"] + "%"

    var eastHpColor = $.GetContextPanel().FindChildInLayoutFile("eastHpColor");
    eastHpColor.style.width = "" + 100 * gGamePlayData["eastKingHp"] / gGamePlayData["eastKingMaxHp"] + "%"
        //
    gWestPlayers.RemoveAndDeleteChildren()
    gEastPlayers.RemoveAndDeleteChildren()
    const localTeam = Players.GetTeam(Players.GetLocalPlayer())
    for (let i = 0; i < Players.GetMaxPlayers(); i++) {
        if (Players.IsValidPlayerID(i)) {
            //addPlayer(i)
            const team = Players.GetTeam(i)
            
            const pdata = getPlayerData(i)
            if (pdata) {

                let playerLine = null
                if (team == DOTATeam_t.DOTA_TEAM_GOODGUYS) {
                    playerLine = $.CreatePanel("Panel", gWestPlayers, "");
                } else {
                    playerLine = $.CreatePanel("Panel", gEastPlayers, "");
                }
                playerLine.BLoadLayoutSnippet("roundinfo_player");
                //

                let show = (team == localTeam)
                if (round == 11 || round == 22 || round >= 30) {
                    show = true
                }
                if (gGamePlayData.mindOpen) {
                    show = true
                }
                if (show) {
                    let sPlayerName = Players.GetPlayerName(i);
                    let sPlayerColor = intToARGB(Players.GetPlayerColor(i));

                    playerLine.SetDialogVariable("player_name", "<font color='#" + sPlayerColor + "'>" + sPlayerName + "</font>");
                    playerLine.SetDialogVariable("player_value", pdata.creepValue);
                    playerLine.SetDialogVariable("player_income", pdata.income);
                    playerLine.SetDialogVariable("player_lumber", pdata.lumberWoker);
                    playerLine.SetDialogVariable("wood_collect", pdata.woodCollect);
                    playerLine.SetDialogVariable("player_kills", pdata.kills);
                } else {
                    let sPlayerName = Players.GetPlayerName(i);
                    let sPlayerColor = intToARGB(Players.GetPlayerColor(i));
                    playerLine.SetDialogVariable("player_name", "<font color='#" + sPlayerColor + "'>" + sPlayerName + "</font>");
                    playerLine.SetDialogVariable("player_value", "--");
                    playerLine.SetDialogVariable("player_income", "--");
                    playerLine.SetDialogVariable("player_lumber", "--");
                    playerLine.SetDialogVariable("wood_collect", "--");
                    playerLine.SetDialogVariable("player_kills", "--");
                }

                if (team == localTeam || true) {
                    let player_name = playerLine.FindChildTraverse("player_name")
                    let str = ""
                    str = "Player ID: " + i
                    if (pdata.rankInfo) {
                        str += "<br> ELO: " + pdata.rankInfo.elo
                        str += "<br> <font color='#fff'>" + $.Localize("#ui_match_count") + ":</font> " + pdata.rankInfo.match_count
                        str += "<br> " + $.Localize("#ui_winrate") + ": " + pdata.rankInfo.winrate / 10 + "%"
                    }
                    player_name.SetPanelEvent('onmouseover', function() {
                        $.DispatchEvent("DOTAShowTextTooltip", player_name, str);
                    });
                    player_name.SetPanelEvent('onmouseout', function() {
                        $.DispatchEvent("DOTAHideTextTooltip", player_name);
                    });
                } else {
                    let player_name = playerLine.FindChildTraverse("player_name")
                    let str = ""
                    str = "player id: " + i
                    player_name.SetPanelEvent('onmouseover', function() {
                        $.DispatchEvent("DOTAShowTextTooltip", player_name, str);
                    });
                    player_name.SetPanelEvent('onmouseout', function() {
                        $.DispatchEvent("DOTAHideTextTooltip", player_name);
                    });
                }
            }
        }
    }
    //
    preState = state
    preRound = round
}

UpdateView()

function toggleContent() {
    if (gContent.BHasClass("Hidden")) {
        gContent.RemoveClass("Hidden")
    } else {
        gContent.AddClass("Hidden")
    }
}

function dota_player_update_selected_unit(params) {
    var selectedUnit = Players.GetLocalPlayerPortraitUnit()
    if (selectedUnit) {
        $.DispatchEvent('FireCustomGameEvent_Str', 'UnitSelected', String(selectedUnit));
    }
}

function dota_player_update_query_unit(params) {
    var selectedUnit = Players.GetLocalPlayerPortraitUnit()
    if (selectedUnit) {
        $.DispatchEvent('FireCustomGameEvent_Str', 'UnitQueried', String(selectedUnit));
    }
}



function TimerUpdateWidth() {
    if (timer <= 0) {
        gRoundHeadBg.style.width = "" + 0 + "%"
            //$.Schedule(0.1, TimerUpdateWidth);
        return
    }
    const timeEscape = Game.GetGameTime() - lastTime
    let timeRemain = timer - timeEscape
    let showTime = Math.ceil(timeRemain)
    showTime = Math.max(0, showTime)
    timeRemain = Math.max(0, timeRemain)
    var progress = (timeRemain / timer) * 100

    // $.Msg("TimerUpdateWidth", progress, " ", timeRemain, " ", timer)


    let timeGap = 5

    let nextTime = Math.max(0, timeRemain - timeGap)
    let nextProgress = (nextTime / timer) * 100
        //  $.Msg(nextTime, " ", nextProgress)
    if (nextProgress == 0) {
        timeGap = timeRemain
    }



    if(Game.IsGamePaused()){
        gRoundHeadBg.style["transition-duration"] = "0s"
    }else
    {
        gRoundHeadBg.style["transition-duration"] = "0s"
        gRoundHeadBg.style.width = "" + progress.toFixed(2) + "%"
        gRoundHeadBg.style["transition-duration"] = timeGap + "s"
        gRoundHeadBg.style.width = "" + nextProgress.toFixed(2) + "%"
    }


    // gRoundHeadBg.style.width = "" + progress.toFixed(2) + "%"
    //

    if (nextProgress != 0) {
        $.Schedule(timeGap, TimerUpdateWidth);
    }
}

function TimerUpdateProgress() {
    if (timer <= 0) {
        gRoundHeadBg.style.width = "" + 0 + "%"
        $.Schedule(0.1, TimerUpdateProgress);

        gBigInfo.SetDialogVariable("rount_timer", secondsToTime(0))

        return
    }
    const timeEscape = Game.GetGameTime() - lastTime
    let timeRemain = timer - timeEscape
    let showTime = Math.ceil(timeRemain)
    showTime = Math.max(0, showTime)
    timeRemain = Math.max(0, timeRemain)
    gBigInfo.SetDialogVariable("rount_timer", secondsToTime(showTime))
        //
    $.Schedule(0.1, TimerUpdateProgress);
}
// TimerUpdateProgress()
//TimerUpdateWidth()

function round_timer(params) {

    timer = params.time || 0
    lastTime = Game.GetGameTime()

    gRoundHeadBg.style["transition-duration"] = "0s"
    gRoundHeadBg.style.width = "100%"

        // gRoundHeadBg.style["transition-duration"] = "1s"
        // gRoundHeadBg.style.width = "0%"
        
    TimerUpdateWidth()
    TimerUpdateProgress()
}




//GameEvents.Subscribe("dota_portrait_ability_layout_changed", dota_player_update_selected_unitCb);
GameEvents.Subscribe("dota_player_update_selected_unit", dota_player_update_selected_unit);
GameEvents.Subscribe("dota_player_update_query_unit", dota_player_update_query_unit);

GameEvents.Subscribe("round_timer", round_timer);

// Subscribe to the end screen event to collapse roundinfo
GameEvents.Subscribe("show_end_screen", function(data) {
    // show == 0 hides the end screen, anything else shows it
    if (data.show != 0) {
        // Collapse roundinfo while the end screen is up
        gContent.AddClass("Hidden");
        $.Msg("[RoundInfo] Collapsed due to end screen");
    } else {
        // Restore roundinfo when the end screen closes
        gContent.RemoveClass("Hidden");
        $.Msg("[RoundInfo] Restored after end screen closed");
    }
});