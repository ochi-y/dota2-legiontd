
let mainPanel = $.GetContextPanel().FindChildInLayoutFile("leaderboardRoot");


// mainPanel.AddClass("Hidden")




let playerList = $.GetContextPanel().FindChildInLayoutFile("playerList");
let drop = $.GetContextPanel().FindChildInLayoutFile("drop");
let modeDrop = $.GetContextPanel().FindChildInLayoutFile("modeDrop");


function onCloseBtn() {
    Game.EmitSound("ui_find_match_cancel");
    mainPanel.ToggleClass("Hidden");
}

let gLeaderboardData = null

gLeaderboardData = CustomNetTables.GetTableValue("leaderboard", "value")
if (gLeaderboardData) {
    gLeaderboardData = JSON.parse(gLeaderboardData.v)
}

CustomNetTables.SubscribeNetTableListener("leaderboard", function () {
    const str = CustomNetTables.GetTableValue("leaderboard", "value").v
    gLeaderboardData = JSON.parse(str)
    //  
    // 
    Update()
})

let mode = "fs"
let season = null
let dropFlag = false

function ToSteam64(steam32) {
    return "76561" + (197960265728 + steam32);
}

function getSeasons() {
    if (gLeaderboardData && gLeaderboardData.data && gLeaderboardData.data.seasons) {
        return gLeaderboardData.data.seasons
    }
    return null
}

function Update() {

    var playerInfo = Game.GetLocalPlayerInfo();
    if (!playerInfo) {
        $.Schedule(0.1, Update);
        return
    }

    drop.RemoveAllOptions()

    let modeList = ["fs", "ns"]
    modeDrop.RemoveAllOptions()
    for (const key in modeList) {
        let m = modeList[key]
        var label = $.CreatePanel('Label', modeDrop, "leaderboard_" + m);
        label.text = $.Localize('#ui_leaderboard_' + m);
        label.AddClass("dropLabel")
        modeDrop.AddOption(label)
    }
    dropFlag = true
    modeDrop.SetSelected("leaderboard_" + mode)
    dropFlag = false


    mainPanel.SetDialogVariable("leaderboard_title", $.Localize("#ui_leaderboard"))


    var iPlayerID = Players.GetLocalPlayer()
    var sPlayerName = Players.GetPlayerName(iPlayerID);
    mainPanel.SetDialogVariable("player_name", sPlayerName)
    if (gLeaderboardData) {

        let data = gLeaderboardData.data
        let modeData = data[mode]
        let player = data.player
        if (season) {

        }

        let pstat = null
        if (data.player) {
            pstat = data.player[mode + "_data"]
        } else {
            pstat = {
                elo: "--",
                match_count: 0,
                match_win: 0
            }
        }
        // let pstat = player[mode + "_data"]
        if (!pstat) {
            pstat = {
                elo: player.elo,
                match_count: player.match_count,
                match_win: player.match_win,
            }
        }
        // modeData.match_count = modeData.match_count || 0
        // modeData.match_win = modeData.match_win || 0
        let elo = pstat.elo || "--"
        mainPanel.SetDialogVariable("player_elo", "" + elo)
        let fakeCount = pstat.match_count || 1
        const winrate = ((100 * pstat.match_win / fakeCount).toFixed(2))
        mainPanel.SetDialogVariable("player_winrate", "" + winrate + "%")

        mainPanel.SetDialogVariable("player_match_count", "" + (pstat.match_count))
        if (modeData.pos == null) {
            mainPanel.SetDialogVariable("player_pos", "--")
        } else {
            mainPanel.SetDialogVariable("player_pos", "#" + (modeData.pos + 1))
        }
    } else {
        mainPanel.SetDialogVariable("rank_score", "--")
        mainPanel.SetDialogVariable("player_winrate", "--")
        mainPanel.SetDialogVariable("player_match_count", "--")
        mainPanel.SetDialogVariable("player_pos", "--")
    }
    playerList.RemoveAndDeleteChildren()

    if (gLeaderboardData && gLeaderboardData.data) {

        let data = gLeaderboardData.data
        let modeData = data[mode]

        let eloColumn = "elo_" + mode


        for (let i = 0; i < modeData.tops.length; i++) {
            const player = modeData.tops[i]

            let pstat = player[mode + "_data"]


            if (!pstat) {
                pstat = {
                    elo: player.elo,
                    match_count: player.match_count,
                    match_win: player.match_win,
                }
                eloColumn = "elo"
            }

            var newLine = null
            newLine = $.CreatePanel("Panel", playerList, "");
            newLine.BLoadLayoutSnippet("snippet_scoreLine");


            newLine.SetDialogVariable("line_no", "#" + (i + 1))
            newLine.SetDialogVariable("rank_score", player[eloColumn] || 0)
            newLine.SetDialogVariable("player_name", player.playername)

            let fake_match_count = pstat.match_count || 1

            const winrate = ((100 * pstat.match_win / (fake_match_count)).toFixed(2))
            newLine.SetDialogVariable("winrate", winrate + "%")

            let avatar = newLine.FindChildTraverse("avatar")
            avatar.steamid = ToSteam64(Number(player.steamid))
            // const playerList = newLine.FindChildTraverse("playerList")
            // const heroList = newLine.FindChildTraverse("heroList")
            // for (let j = 0; j < 4; j++) {
            //     playerList.GetChild(j).steamid = null
            //     playerList.GetChild(j).AddClass("Hidden")
            // }
            // for (let j = 0; j < 1; j++) {
            //     playerList.GetChild(j).RemoveClass("Hidden")
            //     playerList.GetChild(j).steamid = ToSteam64(Number(player.steamid))
            // }

        }
    }
    if (gLeaderboardData && gLeaderboardData.data && gLeaderboardData.data.seasons) {

        let seasons = gLeaderboardData.data.seasons
        drop.RemoveAllOptions()

        var label = $.CreatePanel('Label', drop, 'season_' + "cur");
        label.text = $.Localize('#ui_season_' + "cur");
        label.AddClass("dropLabel")
        drop.AddOption(label)

        dropFlag = true

        let seasonIndex = seasons.length
        for (const season of seasons) {
            let label = $.CreatePanel('Label', drop, 'season_' + season.id);
            label.text = 'SEASON ' + seasonIndex;
            seasonIndex -= 1
            label.AddClass("dropLabel")
            label.season = season.id
            drop.AddOption(label)
        }
        if (season == null) {
            drop.SetSelected('season_' + "cur")

        } else {
            drop.SetSelected('season_' + season)
        }
        dropFlag = false


    }
}

function onModeDropSelected() {
    if (dropFlag == false) {
        $.Msg("onDropSelected");
        let selected = modeDrop.GetSelected()
        if (selected) {
            let s = selected.id.substr(12)
            mode = s
            loadData()
            Update()
            Game.EmitSound("ui_topmenu_activate");
        }
    }
}
function onDropSelected() {

    if (dropFlag == false) {
        $.Msg("onDropSelected");
        //   var dropdown = $("#PlusMinusScale");
        //   pmscale = parseFloat(dropdown.GetSelected().text);
        let selected = drop.GetSelected()
        if (selected) {
            let s = selected.id.substr(7)
            let newSeason = null
            if (s == "cur") {
                newSeason = null
            }
            else {
                newSeason = parseInt(s)
            }
            season = newSeason
            loadData()
            Update()
            Game.EmitSound("ui_topmenu_activate");
        }
    }
    // loadData()
    //     Update()
    //     Game.EmitSound("ui_topmenu_activate");
}
function onClickLeaderboard() {
    mainPanel.ToggleClass("Hidden")
    loadData()
    Update()
    Game.EmitSound("ui_topmenu_activate");
}

function loadData() {
    const pid = Players.GetLocalPlayer()
    GameEvents.SendCustomGameEventToServer("get_leaderboard", { pid: pid, season: season });
}

function top_buttons(data) {
    $.Msg("top_buttons", data)
    if (data && data.name && data.name == "leaderboard") {
        if (data.mode) {
            mode = data.mode
        }
        onClickLeaderboard()
    }
}

(function () {
    //playerList.RemoveAndDeleteChildren()
    GameEvents.Subscribe("top_buttons", top_buttons)
})();