
let PlayerTables = GameUI.CustomUIConfig().PlayerTables;
let Util = GameUI.CustomUIConfig().Util;

GameUI.SetCameraTerrainAdjustmentEnabled(false);


var damageItemList = $.GetContextPanel().FindChildInLayoutFile("damageItemList");


var damage_table = CustomNetTables.GetTableValue("damage_table", "all")
CustomNetTables.SubscribeNetTableListener("damage_table", function () {
    damage_table = CustomNetTables.GetTableValue("damage_table", "all")

    UpdateDamageTable()
})

if (!damage_table) {
    damage_table = {}
}

function formatString(str, args) {
    for (var i in args) {
        var arg = args[i];
        str = str.replace("s" + i, arg);
    }
    return str;
}

function localHiddenMsg() {
    $('#errorMsgBG').SetHasClass("AniScaleOut", false);
    $('#errorMsgBG').SetHasClass("Hidden", true);
}

function localShowMsg() {
    $('#errorMsgBG').SetHasClass("AniScaleOut", true);
    $('#errorMsgBG').SetHasClass("Hidden", false);
}
var g_func_hiddenClass = null;

function onErrorMsg(data) {
    var text = data.text
    var errorMsgBG = $('#errorMsgBG');
    Game.EmitSound("General.CastFail_AbilityNotLearned");
    if (errorMsgBG.BHasClass("AniScaleOut")) {
        localHiddenMsg();
        $.CancelScheduled(g_func_hiddenClass);
    }
    localShowMsg();
    $('#errorMsgTxt').text = $.Localize(text);
    g_func_hiddenClass = $.Schedule(1.2, localHiddenMsg);
}
GameUI.onErrorMsg = onErrorMsg;
GameEvents.Subscribe("S2C_ERROR_MSG", onErrorMsg);
localHiddenMsg();


function player_camera_zoom(params) {
    $.Msg("set zoom",params)
    GameUI.SetCameraDistance(Math.ceil(params.zoom*1143/100) );
}

GameEvents.Subscribe("player_camera_zoom", player_camera_zoom);


function MouseOver(str, panelname) {
    $.DispatchEvent("DOTAShowTextTooltip", $('#btn_' + str), $.Localize("#" + str + "_desc"));
}

function MouseOut() {
    $.DispatchEvent("DOTAHideTextTooltip");
}

function ShowResPanel() {
    $('#kill_num').visible = !$('#kill_num').visible;
}

function ShowBuildPanel() {
    $('#setRoot2').visible = !$('#setRoot2').visible;
}


function LookAtBoss(data) {
    GameUI.SetCameraTarget(data["boss_ent_index"]);
}

function FixCamera() {
    GameUI.SetCameraTarget(-1);
}

function SlideThumbActivate() {
    var slideThumb = $.GetContextPanel();
    var bMinimized = slideThumb.BHasClass('Minimized');
    if (bMinimized) {
        Game.EmitSound("ui_settings_slide_out");
    } else {
        Game.EmitSound("ui_settings_slide_in");
    }
    slideThumb.ToggleClass('Minimized');
}

function UpdateDamageTable() {
    if(!$("#damageTable")){
        return
    }
    let pid = Players.GetLocalPlayer();

    if (!damage_table[pid]) {
        // With no data, clear the list
        damageItemList.RemoveAndDeleteChildren()
        return
    }

    let list = []
    for (const name in damage_table[pid]) {
        const node = {
            name: name,
            damage: 0,
            damageList:[0,0,0,0]
        }
        for (const idx in damage_table[pid][name]) {
            // $.Msg(idx,typeof(idx))
            let d=Math.ceil(damage_table[pid][name][idx])
            if(idx=="1"){
                node.damageList[0]+= d
            }
            if(idx=="2"){
                node.damageList[1]+= d
            }
            if(idx=="4"){
                node.damageList[2]+= d
            }
            if(idx=="8"){
                node.damageList[3]+= d
            }
            node.damage+=d
        }
        list.push(node)
    }
    if (list.length == 0) {
        damageItemList.RemoveAndDeleteChildren()
        return
    }
    list.sort(function (a, b) {
        return -a.damage + b.damage
    })
    const maxDamage = list[0].damage
    if (maxDamage == 0) {
        maxDamage = 1
    }

    // Map used to track the existing panels
    let existingPanels = {};
    for (let i = 0; i < damageItemList.GetChildCount(); i++) {
        let child = damageItemList.GetChild(i);
        let unitName = child.GetAttributeString("unit_name", "");
        if (unitName) {
            existingPanels[unitName] = child;
        }
    }

    // Build the new order array
    let newPanelOrder = [];

    for (const idx in list) {
        const node = list[idx]
        let item = existingPanels[node.name];
        let isNewItem = false;

        if (!item) {
            // Create the panel when it is missing
            item = $.CreatePanel("Panel", damageItemList, "");
            item.BLoadLayoutSnippet("damage_item");
            item.SetAttributeString("unit_name", node.name);
            isNewItem = true;

            // New panels start transparent
            item.style.opacity = "0";
        }

        // Enable smooth movement on every panel
        item.AddClass("damage-item-animated");

        // Fade new panels in one frame later
        if (isNewItem) {
            $.Schedule(0.01, function() {
                item.style.opacity = "1";
            });
        }

        // Update the data
        item.SetDialogVariable("unit_name", $.Localize("#" + node.name));
        item.SetDialogVariable("damage_value", node.damage);

        var damageList = item.FindChildTraverse("damageList")
        const progress = Math.floor(100 * node.damage / maxDamage)
        damageList.style.width = "" + progress + "%"

        //var damageColorPhysical = item.FindChildTraverse("damageColorPhysical")

        item.FindChildTraverse("damageColorPhysical").style.width = "" + Math.floor(100 * node.damageList[0] / node.damage) + "%"
        item.FindChildTraverse("damageColorMagical").style.width = "" + Math.floor(100 * node.damageList[1] / node.damage) + "%"
        item.FindChildTraverse("damageColorPure").style.width = "" + Math.floor(100 * node.damageList[2] / node.damage) + "%"
        item.FindChildTraverse("damageColorHpremoval").style.width = "" + Math.floor(100 * node.damageList[3] / node.damage) + "%"

        if(progress* node.damageList[0] / node.damage>4){
            item.SetDialogVariable("damage_physical","" + Math.floor(100 * node.damageList[0] / node.damage)  );
        }else{
            item.SetDialogVariable("damage_physical","" );
        }
        if(progress* node.damageList[1] / node.damage>4){
            item.SetDialogVariable("damage_magical","" + Math.floor(100 * node.damageList[1] / node.damage) );
        }else{
            item.SetDialogVariable("damage_magical","");
        }
        if(progress* node.damageList[2] / node.damage>4){
            item.SetDialogVariable("damage_pure","" + Math.floor(100 * node.damageList[2] / node.damage) );
        }else{
            item.SetDialogVariable("damage_pure","");
        }
        if(progress* node.damageList[3] / node.damage>4){
            item.SetDialogVariable("damage_hpremoval","" + Math.floor(100 * node.damageList[3] / node.damage) );
        }else{
            item.SetDialogVariable("damage_hpremoval","");
        }

        newPanelOrder.push(item);
        delete existingPanels[node.name];
    }

    // Remove panels that are no longer needed, with a fade out
    for (let name in existingPanels) {
        let panel = existingPanels[name];
        // Fade out
        panel.style.opacity = "0";
        panel.style.transform = "translateX(-20px)";
        // Delete once the animation finished
        $.Schedule(0.35, function() {
            panel.DeleteAsync(0);
        });
    }

    // Reorder the panels by damage, highest first
    if (newPanelOrder.length > 0) {
        // Move every panel into its position
        for (let i = 0; i < newPanelOrder.length; i++) {
            if (i === 0) {
                // The first panel, with the highest damage, goes to the front
                let firstChild = damageItemList.GetChild(0);
                if (firstChild !== newPanelOrder[i]) {
                    damageItemList.MoveChildBefore(newPanelOrder[i], firstChild);
                }
            } else {
                // The others are inserted after the previous panel
                damageItemList.MoveChildAfter(newPanelOrder[i], newPanelOrder[i-1]);
            }
        }
    }
}
UpdateDamageTable()

function CustomGameKeyT() {
    $.Msg("CustomGameKeyT")
    var selectedUnit = Players.GetLocalPlayerPortraitUnit()
    var localPlayerId = Game.GetLocalPlayerID();
    if (Entities.IsControllableByPlayer(selectedUnit, localPlayerId)) {
        var ab = Entities.GetAbilityByName(selectedUnit, "gameplay_unstuck")
        if (ab) {
            Abilities.ExecuteAbility(ab, selectedUnit, false);
        }
    }
}

let gToolTipAbility=null
function AddUnitTooltip(panel, ability) {
    panel.SetPanelEvent("onmouseover", function () {
        gToolTipAbility = panel
        $.DispatchEvent('UIShowCustomLayoutParametersTooltip', panel, "UnitTooltip", "file://{resources}/layout/custom_game/unittooltips.xml", "hero=1&ability=" + ability);
    })
    panel.SetPanelEvent("onmouseout", function () {
        gToolTipAbility = null
        $.DispatchEvent("UIHideCustomLayoutTooltip", panel, "UnitTooltip")
    })
}

function open_fighter_pool() {
   // $("#unitPool").RemoveClass("Hidden");
}
function updateFighterPool() {
    let playerInfo = Game.GetLocalPlayerInfo();
    let fighterPool = PlayerTables.GetTableValue("legiontd_fighter_pool", playerInfo.player_id);

    if (!fighterPool) {
        $.Msg("Warning: fighterPool data not available");
        return;
    }

    $.Msg("Updating fighter pool with data:", fighterPool);

    for (let index = 1; index <= 6; index++) {
        let tierUnits = fighterPool[index.toString()]
        let tierPanel = $("#unitTier"+index)
        tierPanel.RemoveAndDeleteChildren()

        if (!tierUnits) {
            continue;
        }

        // Turn the object into an array so it can be sorted
        let unitsArray = [];
        for (const key in tierUnits) {
            unitsArray.push(tierUnits[key]);
        }

        // Sort order:
        // 1. By used state, unused first
        // 2. Then alphabetically by unit name
        unitsArray.sort(function(a, b) {
            // Different used state: the unused one (0) comes first
            if (a.used !== b.used) {
                return a.used - b.used;
            }
            // Same used state: compare the unit names
            let nameA = a.unit.toLowerCase();
            let nameB = b.unit.toLowerCase();
            if (nameA < nameB) return -1;
            if (nameA > nameB) return 1;
            return 0;
        });

        // Create the panels in sorted order
        for (let i = 0; i < unitsArray.length; i++) {
            let unitData = unitsArray[i];
            let node = $.CreatePanel("Panel", tierPanel, "");
            node.BLoadLayoutSnippet("snippet_fighter");
            let fighter = node.FindChildTraverse("fighterAbilityImage")
            let unitPoolCellCont = node.FindChildTraverse("unitPoolCellCont")

            let unitName = unitData.unit.substring(6)
            node.SetDialogVariable("name", $.Localize("#"+unitName));

            fighter.abilityname = unitData.unit

            // Check and mark used units
            $.Msg("Unit:", unitData.unit, "Used:", unitData.used);
            if(unitData.used == 1){
                node.AddClass("unitPoolCellUsed")
                $.Msg("Marked unit as used:", unitData.unit);
            }

            unitPoolCellCont.SetPanelEvent("onmouseover", function () { })
            unitPoolCellCont.SetPanelEvent("onmouseout", function () { })
            AddUnitTooltip(unitPoolCellCont, unitData.unit)
        }
    }
}


function onCloseUnitPool() {
    Game.EmitSound("ui_find_match_cancel");
    $("#unitPool").ToggleClass("Hidden");
     
}
function ShowUnitPool() {
    Game.EmitSound("ui_find_match_cancel");
    $("#unitPool").ToggleClass("Hidden");

    if(!$("#unitPool").BHasClass("Hidden")){
        updateFighterPool()
    }  
}

(function HUDThink() {
    let pid=Game.GetLocalPlayerID()
    if(pid!=null){
        let heroIndex=Players.GetPlayerHeroEntityIndex(pid )
        if(heroIndex!=null){
            let unitName=Entities.GetUnitName( heroIndex )
            if(unitName=="npc_dota_hero_rubick"){
                if($("#unitPoolBtn").BHasClass("Hidden")){
                    $("#unitPoolBtn").RemoveClass("Hidden")
                }
            }else{
                if(!$("#unitPoolBtn").BHasClass("Hidden")){
                    $("#unitPoolBtn").AddClass("Hidden")
                }
            }
        }
    }
    $.Schedule(0.003, HUDThink);
})();

function CustomGameKeyT_R() { }
GameEvents.Subscribe("lookat_boss", LookAtBoss);

(function () {
    GameEvents.SendCustomGameEventToServer("C2S_RECONNECT", {});
    // if (!$.GetContextPanel().commands) {
    //     $.Msg("init commands")
    //     $.GetContextPanel().commands = true
    //     Game.AddCommand("+CustomGameKeyT", CustomGameKeyT, "", 0);
    //     Game.AddCommand("-CustomGameKeyT", CustomGameKeyT_R, "", 0);
    // }
    GameUI.SetCameraDistance(Math.ceil(115*1143/100) );
    PlayerTables.SubscribeNetTableListener("legiontd_fighter_pool",updateFighterPool)

    GameEvents.Subscribe("open_fighter_pool", open_fighter_pool);
})();

