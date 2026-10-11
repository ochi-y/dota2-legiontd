var gTeamsContainer = $.GetContextPanel().FindChildInLayoutFile("TeamsContainer");

var gEndScreenWindow = $.GetContextPanel().FindChildInLayoutFile("EndScreenWindow");

var gLoadingContainer = $.GetContextPanel().FindChildInLayoutFile("LoadingContainer");


var gPlayerData = CustomNetTables.GetAllTableValues("player")
    // CustomNetTables.SubscribeNetTableListener("player", function() {
    //     gPlayerData = CustomNetTables.GetAllTableValues("player")
    //         //UpdateView()
    // })

// Game data, including gameWinner
var gGamePlayData = null
var gGamePlayDataPrev = null  // used to compare the previous value


// Close the end screen and restore the HUD
function CloseEndScreen() {

    gGamePlayData = null
    gGamePlayDataPrev = null 

    // Hide the end screen
    gEndScreenWindow.AddClass("Hidden");

    // Clear TeamsContainer
    gTeamsContainer.RemoveAndDeleteChildren();

    // Hide the loading hint
    if (gLoadingContainer) {
        gLoadingContainer.AddClass("Hidden");
    }

    $.Msg("[EndScreen] End screen closed, HUD restored");
    Game.EmitSound("ui_generic_button_click");
}

// Button click handling
function OnCloseButtonPressed() {
    CloseEndScreen();
}

//=============================================================================
//=============================================================================
function getPlayerData(pid) {
    var v = gPlayerData.find(v => {
        return parseInt(v.key) === pid
    })
    if (v) {
        return v.value
    }
    return null
}

gGameEndResult = CustomNetTables.GetTableValue("game_end_result", "value")
if (gGameEndResult && gGameEndResult.v) {
    gGameEndResult = JSON.parse(gGameEndResult.v)
} else {
    gGameEndResult = null
}
var gGameEndResultPrev = null  // used to compare the previous value

CustomNetTables.SubscribeNetTableListener("game_end_result", function() {
    var tableValue = CustomNetTables.GetTableValue("game_end_result", "value")
    if (!tableValue || !tableValue.v) {
        $.Msg("[EndScreen] Warning: game_end_result value is empty");
        return;
    }
    const str = tableValue.v
    const newGameEndResult = JSON.parse(str)

    // Skip rendering when the data did not change
    if (gGameEndResultPrev !== null && JSON.stringify(newGameEndResult) === JSON.stringify(gGameEndResultPrev)) {
        $.Msg("[EndScreen] game_end_result unchanged, skipping re-render");
        return;
    }

    gGameEndResult = newGameEndResult
    gGameEndResultPrev = newGameEndResult  // remember the previous value
    $.Msg("[EndScreen] game_end_result updated from NetTable");

    // When the end screen is already up, re-render TeamsContainer with the latest data
    if (!gEndScreenWindow.BHasClass("Hidden")) {
        $.Msg("[EndScreen] Refreshing TeamsContainer with new game_end_result");
        RenderTeamsContainer();
    }
})

//=============================================================================
//=============================================================================
function _ScoreboardUpdater_SetTextSafe(panel, childName, textValue) {
    if (panel === null)
        return;
    var childPanel = panel.FindChildInLayoutFile(childName)
    if (childPanel === null)
        return;

    childPanel.text = textValue;
}

function getPlayerInfoFromResult(pid) {
    if (gGameEndResult && gGameEndResult.data && gGameEndResult.data.player_list) {
        for (const p of gGameEndResult.data.player_list) {

            if (p.pid === pid) {
                return p
            }
        }
    }
    return null
}

// Render the team container
function RenderTeamsContainer() {
    $.Msg("[EndScreen] Rendering TeamsContainer");

    // Hide the loading hint
    if (gLoadingContainer) {
        gLoadingContainer.AddClass("Hidden");
    }

    var teamsList = [];
    for (var teamId of Game.GetAllTeamIDs()) {
        teamsList.push(Game.GetTeamDetails(teamId));
    }

    gTeamsContainer.RemoveAndDeleteChildren()
    for (const team of teamsList) {
        var newTeam = $.CreatePanel("Panel", gTeamsContainer, "");
        newTeam.BLoadLayoutSnippet("end_screen_team");
        team.teamPanel = newTeam
        var playerContainer = newTeam.FindChildTraverse("PlayersContainer")
        for (let i = 0; i < Players.GetMaxPlayers(); i++) {
            const playerId = i
            var isTeammate = false;

            if (Players.IsValidPlayerID(i)) {
                const teamNum = Players.GetTeam(i)
                if (teamNum === team.team_id) {
                    var newPlayer = $.CreatePanel("Panel", playerContainer, "");
                    newPlayer.BLoadLayoutSnippet("end_screen_player");
                    var playerInfo = Game.GetPlayerInfo(playerId);
                    const pdata = getPlayerData(playerId)
                    if (playerInfo && pdata) {
                        const localPlayerTeamId = pdata.team
                        isTeammate = (playerInfo.player_team_id == localPlayerTeamId);
                        if (isTeammate) {
                            ultStateOrTime = Game.GetPlayerUltimateStateOrTime(playerId);
                        }
                        var playerPortrait = newPlayer.FindChildInLayoutFile("HeroIcon");
                        if (playerPortrait) {
                            if (playerInfo.player_selected_hero !== "") {
                                playerPortrait.SetImage("file://{images}/heroes/" + playerInfo.player_selected_hero + ".png");
                            } else {
                                playerPortrait.SetImage("file://{images}/custom_game/unassigned.png");
                            }
                        }
                        newPlayer.SetHasClass("local_player_teammate", isTeammate && (playerId != Game.GetLocalPlayerID()));
                        //
                        _ScoreboardUpdater_SetTextSafe(newPlayer, "RespawnTimer", (playerInfo.player_respawn_seconds + 1)); // value is rounded down so just add one for rounded-up
                        _ScoreboardUpdater_SetTextSafe(newPlayer, "PlayerName", playerInfo.player_name);
                        _ScoreboardUpdater_SetTextSafe(newPlayer, "Level", playerInfo.player_level);
                        _ScoreboardUpdater_SetTextSafe(newPlayer, "Kills", pdata.kills);

                        _ScoreboardUpdater_SetTextSafe(newPlayer, "Lumber", pdata.lumberWoker + "/" + pdata.woodCollect);


                        _ScoreboardUpdater_SetTextSafe(newPlayer, "Deaths", pdata.creepValue);

                        const presult = getPlayerInfoFromResult(i)
                        if (presult) {

                             let suffix = ""
                            if (presult.eloChange > 0) {
                                suffix = "(+" + presult.eloChange + ")"
                            } else {
                                suffix = "(" + presult.eloChange + ")"
                            }
                            _ScoreboardUpdater_SetTextSafe(newPlayer, "Elo", presult.elo + suffix);
                        } else {
                            _ScoreboardUpdater_SetTextSafe(newPlayer, "Assists", "None");
                            _ScoreboardUpdater_SetTextSafe(newPlayer, "Elo", "None");
                        }

                        if (presult && presult.eloChange < 0) {
                            // var assistPanel = newPlayer.FindChildInLayoutFile("Assists")
                            // assistPanel.AddClass("AssistsLose")

                            var EloPanel = newPlayer.FindChildInLayoutFile("Elo")
                            EloPanel.AddClass("AssistsLose")
                        }

                        if (playerInfo.player_selected_hero_id == -1) {
                            _ScoreboardUpdater_SetTextSafe(newPlayer, "HeroName", $.Localize("#DOTA_Scoreboard_Picking_Hero"))
                        } else {
                            _ScoreboardUpdater_SetTextSafe(newPlayer, "HeroName", $.Localize("#" + playerInfo.player_selected_hero))
                        }

                        var heroNameAndDescription = newPlayer.FindChildInLayoutFile("HeroNameAndDescription");
                        if (heroNameAndDescription) {
                            if (playerInfo.player_selected_hero_id == -1) {
                                heroNameAndDescription.SetDialogVariable("hero_name", $.Localize("#DOTA_Scoreboard_Picking_Hero"));
                            } else {
                                heroNameAndDescription.SetDialogVariable("hero_name", $.Localize("#" + playerInfo.player_selected_hero));
                            }
                            heroNameAndDescription.SetDialogVariableInt("hero_level", playerInfo.player_level);
                        }
                        var playerAvatar = newPlayer.FindChildInLayoutFile("AvatarImage");
                        if (playerAvatar) {
                            playerAvatar.steamid = playerInfo.player_steamid;
                        }
                        //
                        var playerColorBar = newPlayer.FindChildInLayoutFile("PlayerColorBar");
                        if (playerColorBar !== null) {
                            if (GameUI.CustomUIConfig().team_colors) {
                                var teamColor = GameUI.CustomUIConfig().team_colors[playerInfo.player_team_id];
                                if (teamColor) {
                                    playerColorBar.style.backgroundColor = teamColor;
                                }
                            } else {
                                var playerColor = "#000000";
                                playerColorBar.style.backgroundColor = playerColor;
                            }
                        }
                    }
                }
            }
        }
    }
    var delay = 0.2;
    var delay_per_panel = 1 / teamsList.length;
    for (var teamInfo of teamsList) {
        var teamPanel = teamInfo.teamPanel
        teamPanel.SetHasClass("team_endgame", false);
        var callback = function(panel) {
            return function() { panel.SetHasClass("team_endgame", 1); }
        }(teamPanel);
        $.Schedule(delay, callback)
        delay += delay_per_panel;
    }

    // Show the legend panel
    var tableCols = $("#tableCols");
    if (tableCols) {
        tableCols.RemoveClass("Hidden");
        $.Msg("[EndScreen] Legend panel shown");
    }
}

function UpdateView() {

    // Clear TeamsContainer first
    gTeamsContainer.RemoveAndDeleteChildren();

    var tableCols = $("#tableCols");
    tableCols.AddClass("Hidden")

    // Show the end screen
    gEndScreenWindow.RemoveClass("Hidden");

    // Show the loading hint
    if (gLoadingContainer) {
        gLoadingContainer.RemoveClass("Hidden");
    }

    // Fetch the game end result again
    var endResultData = CustomNetTables.GetTableValue("game_end_result", "value");
    $.Msg(endResultData)
    if (endResultData && endResultData.v) {
        gGameEndResult = JSON.parse(endResultData.v);
        $.Msg("[EndScreen] Refreshed game end result data");
    } else {
        $.Msg("[EndScreen] Warning: game_end_result not found in NetTable");
        gGameEndResult = null;
    }

    // Winning team from the net table
    var newGamePlayData = CustomNetTables.GetTableValue("gameplay", "all");

    // Skip the rest when gGamePlayData did not change
    if (gGamePlayDataPrev !== null && JSON.stringify(newGamePlayData) === JSON.stringify(gGamePlayDataPrev)) {
        $.Msg("[EndScreen] gGamePlayData unchanged, skipping re-render");
        return;
    }

    gGamePlayData = newGamePlayData;
    gGamePlayDataPrev = newGamePlayData;  // remember the previous value

    var winningTeamId = gGamePlayData ? gGamePlayData.gameWinner : null;

    var endScreenTeamName = $("#EndScreenTeamName");
    var endScreenVictory = $("#EndScreenVictory");

    if (!winningTeamId) {
        // No winner, so clear the team name
        $.Msg("[EndScreen] Warning: gameWinner not found in NetTable, clearing team name");
        if (endScreenTeamName) {
            endScreenTeamName.text = "";
        }
        if (endScreenVictory) {
            endScreenVictory.text = "";
        }
        return;
    }

    var winningTeamDetails = Game.GetTeamDetails(winningTeamId);
    var teamName = $.Localize(winningTeamDetails.team_name);
    $.Msg("abcdef")
    $.Msg(winningTeamDetails)
    $.Msg(teamName)

    if (endScreenTeamName) {
        endScreenTeamName.text = teamName;
        // Set the team colour
        if (GameUI.CustomUIConfig().team_colors) {
            var teamColor = GameUI.CustomUIConfig().team_colors[winningTeamId];
            if (teamColor) {
                teamColor = teamColor.replace(";", "");
                endScreenTeamName.style.color = teamColor + ";";
            }
        }
        $.Msg("[EndScreen] Set victory team name to: " + teamName);
    }


    //
    // Decide whether TeamsContainer renders right away
    if (gGameEndResult) {
        // The result data is here, render immediately
        $.Msg("[EndScreen] Has game_end_result, rendering TeamsContainer immediately");
        RenderTeamsContainer();
    } else {
        // No result data yet, check again in 5 seconds
        $.Msg("[EndScreen] No game_end_result, will check after 5 seconds");
        $.Schedule(5.0, function() {
            // Re-check gGameEndResult after 5 seconds
            if (!gGameEndResult) {
                $.Msg("[EndScreen] 5 seconds timeout, gGameEndResult still empty, force rendering TeamsContainer");
                RenderTeamsContainer();
            } else {
                $.Msg("[EndScreen] gGameEndResult loaded after 5 seconds, skipping forced render");
            }
        });
    }
}

// Initialisation: keep the UI hidden by default
(function() {
    if (gEndScreenWindow && !gEndScreenWindow.BHasClass("Hidden")) {
        gEndScreenWindow.AddClass("Hidden");
    }

    // Hide the loading hint at start
    if (gLoadingContainer) {
        gLoadingContainer.AddClass("Hidden");
    }

    // Subscribe to the game end event
    GameEvents.Subscribe("show_end_screen", function(data) {
        $.Msg("[EndScreen] Received show_end_screen event, data: " + JSON.stringify(data));

        // Check the show flag: 0 hides, anything else shows
        if (data.show == 0) {
            // Close the end screen
            CloseEndScreen();
        } else {
            // Show the end screen
            UpdateView();
            Game.EmitSound("ui_topmenu_activate");
        }
    });
})();