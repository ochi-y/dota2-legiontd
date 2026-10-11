"use strict";

// Global list of panels representing each of the teams
var g_TeamPanels = [];

// Global list of panels representing each of the players (1 per-player). These are reparented
// to the appropriate team panel to indicate which team the player is on.
var g_PlayerPanels = [];

var g_TEAM_SPECATOR = 1;


var gGamePlayData = CustomNetTables.GetTableValue("gameplay", "all")
CustomNetTables.SubscribeNetTableListener("gameplay", function () {
    gGamePlayData = CustomNetTables.GetTableValue("gameplay", "all")
    updateSettingsData()
})

//--------------------------------------------------------------------------------------------------
// Handeler for when the unssigned players panel is clicked that causes the player to be reassigned
// to the unssigned players team
//--------------------------------------------------------------------------------------------------
function OnLeaveTeamPressed() {
    Game.PlayerJoinTeam(DOTATeam_t.DOTA_TEAM_NOTEAM);
}


//--------------------------------------------------------------------------------------------------
// Handler for when the Lock and Start button is pressed
//--------------------------------------------------------------------------------------------------
function OnLockAndStartPressed() {
    // Don't allow a forced start if there are unassigned players
    if (Game.GetUnassignedPlayerIDs().length > 0)
        return;

    // Lock the team selection so that no more team changes can be made
    Game.SetTeamSelectionLocked(true);

    // Disable the auto start count down
    Game.SetAutoLaunchEnabled(false);

    // Set the remaining time before the game starts
    Game.SetRemainingSetupTime(4);
}


//--------------------------------------------------------------------------------------------------
// Handler for when the Cancel and Unlock button is pressed
//--------------------------------------------------------------------------------------------------
function OnCancelAndUnlockPressed() {
    // Unlock the team selection, allowing the players to change teams again
    Game.SetTeamSelectionLocked(false);

    // Stop the countdown timer
    Game.SetRemainingSetupTime(-1);
}


let gIsAllPlayerConnected = false
function isAllPlayerConnected() {
    for (const playerId of Game.GetAllPlayerIDs()) {

        var playerInfo = Game.GetPlayerInfo(playerId);
        if (playerInfo) {
            //playerInfo.player_connection_state == DOTAConnectionState_t.DOTA_CONNECTION_STATE_ABANDONED
            if (playerInfo.player_steamid == 0) {
                continue
            }
            if (playerInfo.player_connection_state != DOTAConnectionState_t.DOTA_CONNECTION_STATE_CONNECTED) {
                return false
            }
        }
    }
    return true
}

function disableGameLaunch() {
    // Disable the auto start count down
    Game.SetAutoLaunchEnabled(false);

    // Set the remaining time before the game starts
    Game.SetRemainingSetupTime(-1);
    $("#GameAndPlayersRoot").SetHasClass("unassigned_players", true);
    $("#GameAndPlayersRoot").SetHasClass("no_unassigned_players", false);
}

//--------------------------------------------------------------------------------------------------
// Handler for the auto assign button being pressed
//--------------------------------------------------------------------------------------------------
function OnAutoAssignPressed() {
    // Assign all of the currently unassigned players to a team, trying
    // to keep any players that are in a party on the same team.
    Game.AutoAssignPlayersToTeams();
}


//--------------------------------------------------------------------------------------------------
// Handler for the shuffle player teams button being pressed
//--------------------------------------------------------------------------------------------------
function OnShufflePlayersPressed() {
    // Shuffle the team assignments of any players which are assigned to a team, 
    // this will not assign any players to a team which are currently unassigned. 
    // This will also not attempt to keep players in a party on the same team.
    Game.ShufflePlayerTeamAssignments();
}


//--------------------------------------------------------------------------------------------------
// Find the player panel for the specified player in the global list or create the panel if there 
// is not already one in the global list. Make the new or existing panel a child panel of the 
// specified parent panel
//--------------------------------------------------------------------------------------------------
function FindOrCreatePanelForPlayer(playerId, parent) {
    // Search the list of player player panels for one witht the specified player id
    for (var i = 0; i < g_PlayerPanels.length; ++i) {
        var playerPanel = g_PlayerPanels[i];

        if (playerPanel.GetAttributeInt("player_id", -1) == playerId) {
            playerPanel.SetParent(parent);
            return playerPanel;
        }
    }

    // Create a new player panel for the specified player id if an existing one was not found
    var newPlayerPanel = $.CreatePanel("Panel", parent, "player_root");
    newPlayerPanel.SetAttributeInt("player_id", playerId);
    newPlayerPanel.BLoadLayout("file://{resources}/layout/custom_game/team_select_player.xml", false, false);

    // Add the panel to the global list of player planels so that we will find it next time
    g_PlayerPanels.push(newPlayerPanel);

    return newPlayerPanel;
}


//--------------------------------------------------------------------------------------------------
// Find player slot n in the specified team panel
//--------------------------------------------------------------------------------------------------
function FindPlayerSlotInTeamPanel(teamPanel, playerSlot) {
    var playerListNode = teamPanel.FindChildInLayoutFile("PlayerList");
    if (playerListNode == null)
        return null;

    var nNumChildren = playerListNode.GetChildCount();
    for (var i = 0; i < nNumChildren; ++i) {
        var panel = playerListNode.GetChild(i);
        if (panel.GetAttributeInt("player_slot", -1) == playerSlot) {
            return panel;
        }
    }

    return null;
}


//--------------------------------------------------------------------------------------------------
// Update the specified team panel ensuring that it has all of the players currently assigned to its
// team and the the remaining slots are marked as empty
//--------------------------------------------------------------------------------------------------
function UpdateTeamPanel(teamPanel) {
    // Get the id of team this panel is displaying
    var teamId = teamPanel.GetAttributeInt("team_id", -1);
    if (teamId <= 0)
        return;

    // Add all of the players currently assigned to the team 
    var teamPlayers = Game.GetPlayerIDsOnTeam(teamId);
    for (var i = 0; i < teamPlayers.length; ++i) {
        var playerSlot = FindPlayerSlotInTeamPanel(teamPanel, i);
        playerSlot.RemoveAndDeleteChildren();
        FindOrCreatePanelForPlayer(teamPlayers[i], playerSlot);
    }

    // Fill in the remaining player slots with the empty slot indicator
    var teamDetails = Game.GetTeamDetails(teamId);
    var nNumPlayerSlots = teamDetails.team_max_players;
    for (var i = teamPlayers.length; i < nNumPlayerSlots; ++i) {
        var playerSlot = FindPlayerSlotInTeamPanel(teamPanel, i);
        if (playerSlot.GetChildCount() == 0) {
            var empty_slot = $.CreatePanel("Panel", playerSlot, "player_root");
            empty_slot.BLoadLayout("file://{resources}/layout/custom_game/team_select_empty_slot.xml", false, false);
        }
    }

    // Change the display state of the panel to indicate the team is full
    teamPanel.SetHasClass("team_is_full", (teamPlayers.length === teamDetails.team_max_players));

    // If the local player is on this team change team panel to indicate this
    var localPlayerInfo = Game.GetLocalPlayerInfo()
    if (localPlayerInfo) {
        var localPlayerIsOnTeam = (localPlayerInfo.player_team_id === teamId);
        teamPanel.SetHasClass("local_player_on_this_team", localPlayerIsOnTeam);
    }
}


//--------------------------------------------------------------------------------------------------
// Update the unassigned players list and all of the team panels whenever a change is made to the
// player team assignments
//--------------------------------------------------------------------------------------------------
function OnTeamPlayerListChanged() {
    var unassignedPlayersContainerNode = $("#UnassignedPlayersContainer");
    if (unassignedPlayersContainerNode === null)
        return;

    // Move all existing player panels back to the unassigned player list
    for (var i = 0; i < g_PlayerPanels.length; ++i) {
        var playerPanel = g_PlayerPanels[i];
        playerPanel.SetParent(unassignedPlayersContainerNode);
    }

    // Make sure all of the unassigned player have a player panel 
    // and that panel is a child of the unassigned player panel.
    var unassignedPlayers = Game.GetUnassignedPlayerIDs();
    for (var i = 0; i < unassignedPlayers.length; ++i) {
        var playerId = unassignedPlayers[i];
        FindOrCreatePanelForPlayer(playerId, unassignedPlayersContainerNode);
    }

    // Update all of the team panels moving the player panels for the
    // players assigned to each team to the corresponding team panel.
    for (var i = 0; i < g_TeamPanels.length; ++i) {
        UpdateTeamPanel(g_TeamPanels[i])
    }

    // Set the class on the panel to indicate if there are any unassigned players
    $("#GameAndPlayersRoot").SetHasClass("unassigned_players", unassignedPlayers.length != 0);
    $("#GameAndPlayersRoot").SetHasClass("no_unassigned_players", unassignedPlayers.length == 0);
}


//--------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------
function OnPlayerSelectedTeam(nPlayerId, nTeamId, bSuccess) {
    var playerInfo = Game.GetLocalPlayerInfo();
    if (!playerInfo)
        return;



    // Check to see if the event is for the local player
    if (playerInfo.player_id === nPlayerId) {
        // Play a sound to indicate success or failure
        if (bSuccess) {
            Game.EmitSound("ui_team_select_pick_team");
        } else {
            Game.EmitSound("ui_team_select_pick_team_failed");
        }

    }
}


//--------------------------------------------------------------------------------------------------
// Check to see if the local player has host privileges and set the 'player_has_host_privileges' on
// the root panel if so, this allows buttons to only be displayed for the host.
//--------------------------------------------------------------------------------------------------
function CheckForHostPrivileges() {
    var playerInfo = Game.GetLocalPlayerInfo();
    if (!playerInfo)
        return;

    // Set the "player_has_host_privileges" class on the panel, this can be used 
    // to have some sub-panels on display or be enabled for the host player.
    $.GetContextPanel().SetHasClass("player_has_host_privileges", playerInfo.player_has_host_privileges);
}

function hasHostPrivileges() {
    var playerInfo = Game.GetLocalPlayerInfo();
    if (!playerInfo)
        return false
    return playerInfo.player_has_host_privileges;
}

//--------------------------------------------------------------------------------------------------
// Update the state for the transition timer periodically
//--------------------------------------------------------------------------------------------------
function UpdateTimer() {

    if (Game.GameStateIsAfter(DOTA_GameState.DOTA_GAMERULES_STATE_STRATEGY_TIME)) {
        return
    }

    var gameTime = Game.GetGameTime();
    var transitionTime = Game.GetStateTransitionTime();

    CheckForHostPrivileges();

    var mapInfo = Game.GetMapInfo();
    $("#MapInfo").SetDialogVariable("map_name", mapInfo.map_display_name);

    if (transitionTime >= 0) {
        $("#StartGameCountdownTimer").SetDialogVariableInt("countdown_timer_seconds", Math.max(0, Math.floor(transitionTime - gameTime)));
        $("#StartGameCountdownTimer").SetHasClass("countdown_active", true);
        $("#StartGameCountdownTimer").SetHasClass("countdown_inactive", false);
    } else {
        $("#StartGameCountdownTimer").SetHasClass("countdown_active", false);
        $("#StartGameCountdownTimer").SetHasClass("countdown_inactive", true);
    }

    var autoLaunch = Game.GetAutoLaunchEnabled();
    $("#StartGameCountdownTimer").SetHasClass("auto_start", autoLaunch);
    $("#StartGameCountdownTimer").SetHasClass("forced_start", (autoLaunch == false));

    // Allow the ui to update its state based on team selection being locked or unlocked
    $.GetContextPanel().SetHasClass("teams_locked", Game.GetTeamSelectionLocked());
    $.GetContextPanel().SetHasClass("teams_unlocked", Game.GetTeamSelectionLocked() == false);



    let b1 = isAllPlayerConnected()

    if (gIsAllPlayerConnected != b1) {
        if (b1) {
            OnTeamPlayerListChanged()
            if(hasHostPrivileges()){
                Game.AutoAssignPlayersToTeams();
                
            }
        }
    }
    if (!b1) {
        disableGameLaunch()
    }
    gIsAllPlayerConnected = b1
    if (!isAllPlayerConnected()) {
        disableGameLaunch()
    }

    $.Schedule(0.1, UpdateTimer);
}

function OnSelectGameMode(mode) {
    GameEvents.SendCustomGameEventToServer("game_setting", { game_mode: mode });
}

function OnSelectSellMode(mode) {
    GameEvents.SendCustomGameEventToServer("game_setting", { sell_mode: mode });
}

function OnToggleConfig(id) {
    let toggle = $("#" + id)
    GameEvents.SendCustomGameEventToServer("game_setting", {
        [id]: toggle.checked
    });
}

function on_game_setting(data) {
    if (data.sell_mode != undefined) {
        $("#btn_sellmode_" + data.sell_mode).checked = true
    }
    if (data.game_mode != undefined) {
        $("#btn_mode_" + data.game_mode).checked = true
    }
    if (data.mind_open != undefined) {
        $("#mind_open").checked = data.mind_open
    }
    if (data.half_creep != undefined) {
        $("#half_creep").checked = data.half_creep
    }
    if (data.x2 != undefined) {
        $("#x2").checked = data.x2
    }
    if (data.creep_stack != undefined) {
        $("#creep_stack").checked = data.creep_stack
    }
    if (data.limited_income != undefined) {
        $("#limited_income").checked = data.limited_income
    }
    if (data.dark_mode != undefined) {
        $("#dark_mode").checked = data.dark_mode
    }
    OnCancelAndUnlockPressed()
}


function updateSettingsData() {
    var playerInfo = Game.GetLocalPlayerInfo();
    if (playerInfo && gGamePlayData) {


        if (Boolean(gGamePlayData.secondaryModes.ls)) {
            $("#btn_sellmode_last_sell").checked = true
        }
        if (Boolean(gGamePlayData.secondaryModes.fs)) {
            $("#btn_sellmode_free_sell").checked = true
        }
        if (!Boolean(gGamePlayData.secondaryModes.ls) && !Boolean(gGamePlayData.secondaryModes.fs)) {
            $("#btn_sellmode_normal_sell").checked = true
        }



        if (gGamePlayData.primaryMode != undefined) {
            $("#btn_mode_" + gGamePlayData.primaryMode).checked = true
        }


        $("#mind_open").checked = Boolean(gGamePlayData.secondaryModes.mo)
        $("#limited_income").checked = Boolean(gGamePlayData.secondaryModes.limited_income)

        $("#dark_mode").checked = Boolean(gGamePlayData.secondaryModes.dark_mode)



        $("#half_creep").checked = Boolean(gGamePlayData.secondaryModes.hc)
        $("#x2").checked = Boolean(gGamePlayData.secondaryModes.x2)
        $("#creep_stack").checked = Boolean(gGamePlayData.secondaryModes.creep_stack)
        $("#fighter_stack").checked = Boolean(gGamePlayData.secondaryModes.fighter_stack)




        // $("#x2").checked = gGamePlayData.secondaryModes.hc


        // if (gGamePlayData.secondaryModes.mo ) {
        //     $("#btn_sellmode_last_sell" ).checked = true
        // }

        // if (data.mind_open != undefined) {
        //     $("#mind_open").checked = data.mind_open
        // }
        // if (data.half_creep != undefined) {
        //     $("#half_creep").checked = data.half_creep
        // }
        // if (data.x2 != undefined) {
        //     $("#x2").checked = data.x2
        // }

    } else {
        $.Schedule(0.1, updateSettingsData);
    }
}

function updateSettings() {
    var playerInfo = Game.GetLocalPlayerInfo();

    if (playerInfo) {
        if (!playerInfo.player_has_host_privileges) {
            $("#btn_mode_all_pick").enabled = false
            $("#btn_mode_all_prophet").enabled = false
            $("#btn_mode_host_pick").enabled = false

            $("#btn_sellmode_normal_sell").enabled = false
            $("#btn_sellmode_free_sell").enabled = false
            $("#btn_sellmode_last_sell").enabled = false
            $("#mind_open").enabled = false
            $("#limited_income").enabled = false
            $("#dark_mode").enabled = false
            $("#half_creep").enabled = false
            $("#x2").enabled = false
            $("#creep_stack").enabled = false

            $("#fighter_stack").enabled = false

            $("#PermissionRedlabel").RemoveClass("Hidden")
            $("#PermissionGreenlabel").AddClass("Hidden")
        } else {
            $("#btn_mode_all_pick").enabled = true
            $("#btn_mode_all_prophet").enabled = true
            $("#btn_mode_host_pick").enabled = true

            $("#btn_sellmode_normal_sell").enabled = true
            $("#btn_sellmode_free_sell").enabled = true
            $("#btn_sellmode_last_sell").enabled = true
            $("#mind_open").enabled = true
            $("#limited_income").enabled = true
            $("#dark_mode").enabled = true
            $("#half_creep").enabled = true
            $("#x2").enabled = true
            $("#creep_stack").enabled = true
            $("#fighter_stack").enabled = true

            $("#PermissionRedlabel").AddClass("Hidden")
            $("#PermissionGreenlabel").RemoveClass("Hidden")
        }


        updateSettingsData()
    } else {
        $.Schedule(0.1, updateSettings);
    }
}

//--------------------------------------------------------------------------------------------------
// Entry point called when the team select panel is created
//--------------------------------------------------------------------------------------------------
(function () {
    var bShowSpectatorTeam = false;
    var bAutoAssignTeams = true;

    // get any custom config
    if (GameUI.CustomUIConfig().team_select) {
        var cfg = GameUI.CustomUIConfig().team_select;
        if (cfg.bShowSpectatorTeam !== undefined) {
            bShowSpectatorTeam = cfg.bShowSpectatorTeam;
        }
        if (cfg.bAutoAssignTeams !== undefined) {
            bAutoAssignTeams = cfg.bAutoAssignTeams;
        }
    }

    $("#TeamSelectContainer").SetAcceptsFocus(true); // Prevents the chat window from taking focus by default
    var teamsListRootNode = $("#TeamsListRoot");

    // Construct the panels for each team
    var allTeamIDs = Game.GetAllTeamIDs();

    if (bShowSpectatorTeam) {
        allTeamIDs.unshift(g_TEAM_SPECATOR);
    }

    for (var teamId of allTeamIDs) {
        var teamNode = $.CreatePanel("Panel", teamsListRootNode, "");
        teamNode.AddClass("team_" + teamId); // team_1, etc.
        teamNode.SetAttributeInt("team_id", teamId);
        teamNode.BLoadLayout("file://{resources}/layout/custom_game/team_select_team.xml", false, false);

        // Add the team panel to the global list so we can get to it easily later to update it
        g_TeamPanels.push(teamNode);
    }

    // Game.PlayerJoinTeam(DOTATeam_t.DOTA_TEAM_NOTEAM);
    // Automatically assign players to teams.
    if (bAutoAssignTeams) {
        //Game.AutoAssignPlayersToTeams();
    }

    // Do an initial update of the player team assignment
    OnTeamPlayerListChanged();

    // Start updating the timer, this function will schedule itself to be called periodically
    UpdateTimer();

    // Register a listener for the event which is brodcast when the team assignment of a player is actually assigned
    $.RegisterForUnhandledEvent("DOTAGame_TeamPlayerListChanged", OnTeamPlayerListChanged);

    // Register a listener for the event which is broadcast whenever a player attempts to pick a team
    $.RegisterForUnhandledEvent("DOTAGame_PlayerSelectedCustomTeam", OnPlayerSelectedTeam);


    updateSettings()

    $("#dark_mode").checked = true
    $("#x2").checked = true
    $("#creep_stack").checked = true

    GameEvents.Subscribe("game_setting", on_game_setting);

})();