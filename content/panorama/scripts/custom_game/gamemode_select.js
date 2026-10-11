var mainContainer = $.GetContextPanel().FindChildInLayoutFile("mainContainer");
var gItems = $.GetContextPanel().FindChildInLayoutFile("items");

//
var exampleData = {
        type: "diff",
        items: ["diff1", "diff2", "diff3"],
        selected: "diff1"
    }
    //key:pid value:[]
var gGamemodeChoose = {}

var gTargetPlayerId = null

function OnItemClick(type, item, index) {
    var panel = $.GetContextPanel()
    GameEvents.SendCustomGameEventToServer("gamemode_choose", { type, item, targetPlayerId: gTargetPlayerId, index });
    Game.EmitSound("ui_generic_button_click")
    mainContainer.RemoveClass("Visible")
}

function GetCustomNetTable(sTableName) {
    var entries = CustomNetTables.GetAllTableValues(sTableName);
    var table = {};
    if (entries != null)
        entries.forEach(entry => table[entry.key] = entry.value);
    return table;
}

function updateUi() {

    var playerInfo = Game.GetLocalPlayerInfo();


    if (playerInfo && gGamemodeChoose) {

        var localPlayerId = Game.GetLocalPlayerID();
        var queryUnit = Players.GetLocalPlayerPortraitUnit();
        var unitPlayerId = Entities.GetPlayerOwnerID(queryUnit);



        var targetPlayerId = null
        if (!queryUnit) {
            targetPlayerId = localPlayerId
        } else {
            if (Entities.IsControllableByPlayer(queryUnit, localPlayerId)) {
                targetPlayerId = unitPlayerId
            } else {
                targetPlayerId = localPlayerId
            }
        }
        gTargetPlayerId = targetPlayerId
        var gameChoose = gGamemodeChoose[targetPlayerId + ""]
        var choose = null
        if (gameChoose) {
            gameChoose = gameChoose.value
            for (let i = 0; i < Object.keys(gameChoose).length; i++) {
                if (!gameChoose["" + (i + 1)].selected) {
                    choose = gameChoose["" + (i + 1)]
                    break
                }
            }
        }
        // $.Msg(gGamemodeChoose)
        gItems.RemoveAndDeleteChildren()

        if (choose) {
            $.Msg("[GamemodeSelect] player " + targetPlayerId + " picked the type:", choose.type);
            $.Msg("[GamemodeSelect] number of choices:", Object.keys(choose.items).length);

            // Collect every candidate hero into an array
            var heroList = [];
            for (let i = 0; i < Object.keys(choose.items).length; i++) {
                heroList.push(choose.items[(i + 1) + ""]);
            }

            // Sort by localized name, with the special races last
            heroList.sort(function(a, b) {
                var isAHybrid = a === "npc_dota_hero_morphling";
                var isAProphet = a === "npc_dota_hero_rubick";
                var isBHybrid = b === "npc_dota_hero_morphling";
                var isBProphet = b === "npc_dota_hero_rubick";

                // prophet goes last
                if (isAProphet && !isBProphet) return 1;
                if (!isAProphet && isBProphet) return -1;

                // hybrid sits after the normal races and before prophet
                if (isAHybrid && !isBHybrid && !isBProphet) return 1;
                if (!isAHybrid && !isAProphet && isBHybrid) return -1;

                // Within the same kind, sort by localized name
                var nameA = $.Localize("#" + a);
                var nameB = $.Localize("#" + b);
                if (nameA < nameB) return -1;
                if (nameA > nameB) return 1;
                return 0;
            });

            $.Msg("[GamemodeSelect] sorted hero list:", heroList.join(", "));

            mainContainer.AddClass("Visible")
            mainContainer.SetDialogVariable("title", $.Localize("#" + choose.type));

            for (let i = 0; i < heroList.length; i++) {
                const item = heroList[i];
                $.Msg("[GamemodeSelect] creating hero button [" + (i + 1) + "]:", item);
                var newButton = $.CreatePanel("Panel", gItems, "");
                var snippet = "ChooseItem"
                if (choose.type == "choose_hero") {
                    snippet = "ChooseHero"
                }
                if (Object.keys(choose.items).length == 1) {
                    snippet = "ChooseHeroSingle"
                }
                //
                newButton.BLoadLayoutSnippet(snippet);
                newButton.SetDialogVariable("itemName", $.Localize("#" + item));
                newButton.SetPanelEvent('onactivate', function() { OnItemClick(choose.type, item, choose.index); });

                if (snippet == "ChooseHero" || snippet == "ChooseHeroSingle") {
                    const heropanel = newButton.FindChildTraverse("heroPanel")
                    heropanel.SetUnit(item, "default_camera", true);
                    const panel = newButton
                        //newButton.SetPanelEvent('onmouseover', function() { UIShowTextTooltip("#gold_desc"); });
                    newButton.SetPanelEvent('onmouseover', function() {
                        $.DispatchEvent("DOTAShowTextTooltip", panel, $.Localize("#" + item + "_hero_select"));
                    });
                    newButton.SetPanelEvent('onmouseout', function() {
                        $.DispatchEvent("DOTAHideTextTooltip", panel);
                    });
                }
            }
        } else {
            mainContainer.RemoveClass("Visible")
        }
    } else {
        $.Schedule(0.1, updateUi);
    }
}
//
function OnGamemodeChoose(table_name, key, data) {
    $.Msg("OnGamemodeChoose ", key)
    var localPlayerId = Game.GetLocalPlayerID();
    gGamemodeChoose[key] = data;
    if (localPlayerId == Number(key)) {
        updateUi();
    }
}

CustomNetTables.SubscribeNetTableListener("gamemode_choose", OnGamemodeChoose)

var updateFunc = function() {
    gGamemodeChoose = GetCustomNetTable("gamemode_choose");
    updateUi();
    //$.Schedule(10.0, updateFunc);
}

$.Schedule(1.0, updateFunc);

GameEvents.Subscribe("dota_player_update_selected_unit", updateUi);
GameEvents.Subscribe("dota_player_update_query_unit", updateUi);