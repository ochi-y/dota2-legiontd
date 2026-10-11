
var PlayerTables = GameUI.CustomUIConfig().PlayerTables;
let Util=GameUI.CustomUIConfig().Util;

let mainPanel = $.GetContextPanel().FindChildInLayoutFile("leaderboardRoot");

let matchList = $.GetContextPanel().FindChildInLayoutFile("matchList");

let matchListContainer=$.GetContextPanel().FindChildInLayoutFile("matchListContainer");

function onCloseBtn() {
    Game.EmitSound("ui_find_match_cancel");
    mainPanel.ToggleClass("Hidden");

    matchList.RemoveAndDeleteChildren()
    
}

let profileData = null

let matchsData = null

let localSteamId=null

let page=1

// let gLeaderboardData = null
// gLeaderboardData = PlayerTables.GetTableValue(tableName, keyName)
// if (gLeaderboardData) {
//     gLeaderboardData = JSON.parse(gLeaderboardData.v)
// }

// CustomNetTables.SubscribeNetTableListener("leaderboard", function () {
//     const str = CustomNetTables.GetTableValue("leaderboard", "value").v
//     gLeaderboardData = JSON.parse(str)
//     //  
//     // 
//     Update()
// })

let mode = "ns"
let season = null
let dropFlag = false

function ToSteam64(steam32) {
    return "76561" + (197960265728 + steam32);
}


function ToSteam32(steam64) {
    return parseInt(steam64.substr(5))-197960265728
}


function formatDate(time) {
    var d = new Date(time * 1000);
    var datestring = d.getFullYear() + "/" + ("0" + (d.getMonth() + 1)).slice(-2) + "/" + ("0" + d.getDate()).slice(-2)
        +" "+ ("0" + d.getHours()).slice(-2) + ":" + ("0" + d.getMinutes()).slice(-2)
    return datestring
}


function formatDuration(endTime,startTime,round) {

    if(!endTime){
        return "--"
    }else{
        let t=endTime-startTime
        let h=Math.floor(t/3600)
        let m=Math.floor((t%3600)/60)
        let s=t%60
        if(h>0){
            return ("0" + h).slice(-2) + ":"+("0" + m).slice(-2) + ":" + ("0" + s).slice(-2)+" round "+round
        }else{
            return ("0" + m).slice(-2) + ":" + ("0" + s).slice(-2)+" round "+round
        }
    }
}

function  getFightersSummary(player) {
    if(!player||!player.towers){
        return []
    }else{
        let list=[]

        for (const t of player.towers) {

            let flag=false
            for (let index = 0; index < list.length; index++) {
                const e = list[index];
                if(e.unit==t.unit){
                    e.count+=1
                    flag=true
                }
            }
            if(!flag){
                list.push({
                    unit:t.unit,
                    count:1
                })
            }
        }
        list.sort(function name(a,b) {
            return -(a.count-b.count)
        })
        return list.slice(0,4)
    }
}

function formatGameMode(game_mode) {

    if(!game_mode){
        return "--"
    }else{
        let secondaryModes=game_mode.secondaryModes
        let primaryMode=game_mode.primaryMode

        let res=""
        if(!primaryMode){
            res+="AP"
        }else{
            let shorts={
                "all_pick":"AP",
                "host_pick":"HP",
                "all_prophet":"PR"
            }
            if(shorts[primaryMode]){
                res +=shorts[primaryMode]
            }
        }

        if(!secondaryModes){
            res+= " AP NS"
        }else{
            if(secondaryModes["fs"]){
                res+=" FS"
            }else if (secondaryModes["ls"]){
                res +=" LS"
            }else{
                res +=" NS"
            }
            if(secondaryModes["x2"]){
                res+=" X2"
            }
            if(secondaryModes["creep_stack"]){
                res+=" CS"
            }
            if(secondaryModes["mind_open"]){
                res+=" MO"
            }
        }
        return res
    }

}

function appendMatches(matches) {

    if(!matches){
        return
    }

    matchList.RemoveAndDeleteChildren()

    let c=0
    for (const match of matches) {

        var newLine = null
        newLine = $.CreatePanel("Panel", matchList, "");
        newLine.BLoadLayoutSnippet("snippet_match");

        newLine.SetDialogVariable("date", formatDate(match.start_time))


        if(c%2==0){
            newLine.AddClass("matchEven")
        }else{
            newLine.AddClass("matchOdd")
        }
        c+=1

        let round=1
        if(match.game_info){
            round=match.game_info.round
        }


        newLine.SetDialogVariable("duration", formatDuration(match.end_time,match.start_time,round))


        newLine.SetDialogVariable("mode", formatGameMode(match.game_mode))

        let fighterList=newLine.FindChildTraverse("fighterList")

        if(match.game_result){
            let winnerTeam=match.game_result.winnerTeam
            let win=false
            let pInMatch=null
            for (const p of match.game_result.players) {
                //if(p.steamid==)
                if((p.steamid)==localSteamId){
                    win=(p.team==winnerTeam) 
                    pInMatch=p
                }
            }
            if(win){
                newLine.SetDialogVariable("result", "Win")
            }else{
                newLine.SetDialogVariable("result", "Lose")

                newLine.FindChildTraverse("resultLabel").AddClass("loseLabel")

            }
            if(pInMatch&&pInMatch.elo!==undefined&&pInMatch.eloChange!=undefined){


                let str=""+pInMatch.eloChange
                if(pInMatch.eloChange>0){
                    str="+"+pInMatch.eloChange
                }


                let s=Util.csFormat("{0}({1})",[pInMatch.elo,str])
                newLine.SetDialogVariable("elo", s)

            }else{
                newLine.SetDialogVariable("elo", "--")
            }
        }else{
            newLine.SetDialogVariable("result", "--")
            newLine.SetDialogVariable("elo", "--")
        }
        if(match.players){

            
            for (const p of match.players) {
                let player=null
                if((p.steamId)==localSteamId){
                    player=p
                }
                
                if(player){
                    let fighterSummary=getFightersSummary(player)
                    if(fighterSummary.length>0){
                        fighterList.RemoveAndDeleteChildren()
                        for (const f of fighterSummary) {
                            var figtherPanel = $.CreatePanel("Panel", fighterList, "");
                            figtherPanel.BLoadLayoutSnippet("snippet_fighter");
                            figtherPanel.SetDialogVariable("count", f.count)
                            figtherPanel.FindChildTraverse("fighter").SetUnit(f.unit, "default_camera", true)
                        }
                    }
                }
            }
        }

        // newLine.SetDialogVariable("rank_score", player[eloColumn] || 0)
        // newLine.SetDialogVariable("player_name", player.playername)
    }
    matchListContainer.ScrollToTop()
}

function Render() {
    var playerInfo = Game.GetLocalPlayerInfo();
    if (!playerInfo) {
        $.Schedule(0.1, Render);
        return
    }
    if (!profileData) {
        return
    }

    page=1

    let player = profileData.player
    localSteamId=player.steamid

    let matches = profileData.matches
    if (player) {
        let fsElo = player.elo_fs || "--"
        let nsElo = player.elo_ns || "--"
        mainPanel.SetDialogVariable("player_elo", nsElo + "/" + fsElo)

        mainPanel.SetDialogVariable("title", player.playername.substr(0,50))

        let player_match_count = 0
        if (player.all_data) {
            player_match_count = player.all_data.match_count
        }
        mainPanel.SetDialogVariable("player_match_count", player_match_count)

        let player_winrate = 0

        if (player.all_data) {

            if (player.all_data.match_count != 0) {
                player_winrate = player.all_data.match_win / player.all_data.match_count
            }
        }
        mainPanel.SetDialogVariable("player_winrate", (100 * player_winrate).toFixed(2) + "%")
    }
    matchList.RemoveAndDeleteChildren()
    mainPanel.SetDialogVariable("load_btn", $.Localize("#ui_load_more"))
    appendMatches(matches)

    // mainPanel.SetDialogVariable("player_elo", )
}

function OnClickLoad() {
    const pid = Players.GetLocalPlayer()
    page+=1
    GameEvents.SendCustomGameEventToServer("web_load_matches", { pid: pid,steamid:localSteamId, page});
    mainPanel.SetDialogVariable("load_btn", $.Localize("#ui_loading"))

}


function loadData(steamid) {
    const pid = Players.GetLocalPlayer()
    var playerInfo = Game.GetLocalPlayerInfo();
    $.Msg(playerInfo)
    if(!steamid){
        steamid=ToSteam32(playerInfo.player_steamid)
    }
    GameEvents.SendCustomGameEventToServer("get_profile", { pid: pid,steamid });

}

function top_buttons(data) {
    $.Msg("top_buttons", data)
    if (data && data.name && data.name == "home") {
        if (data.mode) {
            mode = data.mode
        }
        mainPanel.ToggleClass("Hidden")
        if(mainPanel.BHasClass("Hidden")){
            fighterList.RemoveAndDeleteChildren()
        }else{
            loadData(data.steamid)
        }
        Game.EmitSound("ui_topmenu_activate");
    }
}

function init() {

    var playerInfo = Game.GetLocalPlayerInfo();
    if (!playerInfo) {
        $.Schedule(0.1, init);
        return
    }
    //localSteamId=playerInfo.player_steamid

    let pid = playerInfo.player_id
    let tableName = "web_profile_" + pid
    profileData = PlayerTables.GetTableValue(tableName, "data")
    $.Msg("profileData load")
    if (profileData) {
        profileData = JSON.parse(profileData.v)
        Render()
    }
    PlayerTables.ClearNetTableListener(tableName)


    PlayerTables.SubscribeNetTableListener(tableName, function () {
        $.Msg("profileData load")
        profileData = PlayerTables.GetTableValue(tableName, "data")
        if (profileData) {
            profileData = JSON.parse(profileData.v)
            Render()
        }
    })

    PlayerTables.ClearNetTableListener("web_load_matches_" + pid)
    PlayerTables.SubscribeNetTableListener("web_load_matches_" + pid, function () {
        $.Msg("web_load_matches_ load")
        matchsData = PlayerTables.GetTableValue("web_load_matches_" + pid, "data")
        if (matchsData) {
            matchsData = JSON.parse(matchsData.v)
            appendMatches(matchsData.matchs)
            if(matchsData.matchs.length==0){
                page=0
            }

        }
        mainPanel.SetDialogVariable("load_btn", $.Localize("#ui_load_more"))

    })

}
(function () {
    //playerList.RemoveAndDeleteChildren()
    GameEvents.Subscribe("top_buttons", top_buttons)

    GameEvents.Subscribe("show_profile", top_buttons)

    init()

})();