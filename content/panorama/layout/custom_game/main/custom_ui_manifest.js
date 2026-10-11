
(function () {

    function HidePickScreen() {
        var dotaHud = $.GetContextPanel().GetParent().GetParent();
        if (Game.GameStateIsBefore(DOTA_GameState.DOTA_GAMERULES_STATE_HERO_SELECTION)) {
            dotaHud.FindChild("PreGame").visible = false;
        }
        else if (Game.GameStateIs(DOTA_GameState.DOTA_GAMERULES_STATE_HERO_SELECTION)) {
            dotaHud.FindChild("PreGame").visible = true;
        }
        else if (Game.GameStateIs(DOTA_GameState.DOTA_GAMERULES_STATE_PRE_GAME)) {
            dotaHud.FindChild("PreGame").visible = false;
        }
    }
    (function () {
        GameEvents.Subscribe("game_rules_state_change", HidePickScreen);
    })();

    // Uncomment any of the following lines in order to disable that portion of the default UI

    //GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_TIMEOFDAY, false );      		//Time of day (clock).
    //GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_HEROES, false );     			//Heroes and team score at the top of the HUD.


    //GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_ACTION_PANEL, false );     		//Hero actions UI.
    //GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_ACTION_MINIMAP, false );     		//Minimap.
    //GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_PANEL, false );      	//Entire Inventory UI
    //GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_SHOP, false );     		//Shop portion of the Inventory. 
    //GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_ITEMS, false );      	//Player items.
    //GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_QUICKBUY, false );     	//Quickbuy.
    //GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_COURIER, false );      	//Courier controls.
    //GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_PROTECT, false );      	//Glyph.
    //GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_GOLD, false );     		//Gold display.
    //GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_SHOP_SUGGESTEDITEMS, false );      //Suggested items shop panel.
    //GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_HERO_SELECTION_TEAMS, false );     //Hero selection Radiant and Dire player lists.
    //GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_HERO_SELECTION_GAME_NAME, false ); //Hero selection game mode name display.
    //GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_HERO_SELECTION_CLOCK, false );     //Hero selection clock.

    GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_MENU_BUTTONS, false);     	//Top-left menu buttons in the HUD.

    //GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_ENDGAME, false );      			//Endgame scoreboard.    
    //GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_BAR_BACKGROUND, false );     	//Top-left menu buttons in the HUD.

    GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_FLYOUT_SCOREBOARD, true);      //Lefthand flyout scoreboard.
    GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_ACTION_PANEL, true);     //Hero actions UI.


    GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_SHOP, false);     //Shop portion of the Inventory.

    GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_QUICKBUY, false);     //Quickbuy.
    GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_ITEMS, true);
    GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_PROTECT, true);
    GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_PANEL, true);
    GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_ENDGAME, false);


    GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_AGHANIMS_STATUS, false);


    //GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_PREGAME_STRATEGYUI , false );     //

    if (Game.IsInToolsMode()) {
        GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_SHOP, true);
    }

    // These lines set up the panorama colors used by each team (for game select/setup, etc)
    GameUI.CustomUIConfig().team_colors = {}
    GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_GOODGUYS] = "#3dd296;";
    GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_BADGUYS] = "#F3C909;";
    GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_1] = "#c54da8;";
    GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_2] = "#FF6C00;";
    GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_3] = "#3455FF;";
    GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_4] = "#65d413;";
    GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_5] = "#815336;";
    GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_6] = "#1bc0d8;";
    GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_7] = "#c7e40d;";
    GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_8] = "#8c2af4;";


    if (true) {

        var newUI = $.GetContextPanel().GetParent().GetParent().FindChildTraverse("HUDElements").FindChildTraverse("lower_hud").FindChildTraverse("center_with_stats").FindChildTraverse("center_block");


        // remove the defence runes and scan -->
        var newUI = $.GetContextPanel().GetParent().GetParent().FindChildTraverse("HUDElements").FindChildTraverse("minimap_container");
        newUI.FindChildTraverse("GlyphScanContainer").style.visibility = "collapse";

        newUI.FindChildTraverse("TormentorTimerContainer").style.visibility = "collapse";

        var hudElements = $.GetContextPanel().GetParent().GetParent().FindChildTraverse("HUDElements");
        var newUI = hudElements.FindChildTraverse("center_block");

        // newUI.FindChildTraverse("HUDSkinPortrait").style.backgroundimage = "url(raw://resource/flash3/images/hud_skins/zodiac_hud/actionpanel/portrait_wide.png)"; -->
        // remove the talent tree -->
        newUI.FindChildTraverse("StatBranch").style.visibility = "collapse";
        // it comes back at levels 10, 15, 20 and 25, so remove this one too -->
        newUI.FindChildTraverse("level_stats_frame").style.visibility = "collapse";

        // remove the Aghanim's panel -->
        newUI.FindChildTraverse("AghsStatusContainer").style.visibility = "collapse";

        var newUI = $.GetContextPanel().GetParent().GetParent().FindChildTraverse("HUDElements");
        // turn off the suggested items -->

        newUI.FindChildTraverse("CommonItems").style.visibility = "collapse";;

        newUI.FindChildTraverse("GuideFlyout").style.visibility = "collapse";;

        newUI.FindChildTraverse("inventory_composition_layer_container").style.visibility = "collapse";;

        newUI.FindChildTraverse("RoshanTimerContainer").style.visibility = "collapse";;
         newUI.FindChildTraverse("TimersContainer").style.visibility = "collapse";;
        //facet
        //newUI.FindChildTraverse("ContentsContainer").GetParent().style.visibility = "collapse";;

        newUI.FindChildTraverse("shop_launcher_block").FindChildTraverse("QuickBuyRows").style.visibility = "collapse";;

    }

})();

$.Msg("custom_ui_manifest.js")