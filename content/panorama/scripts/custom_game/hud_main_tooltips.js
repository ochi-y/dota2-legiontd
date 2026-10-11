const hud = $.GetContextPanel().GetParent().GetParent().GetParent();

// let PlayerTables = GameUI.CustomUIConfig().PlayerTables;

const centerhud = hud.FindChildTraverse("lower_hud")

let gActiveTooltipPanel = null

function AddUnitTooltip(panel, ability) {
    panel.SetPanelEvent("onmouseover", function () {
        gActiveTooltipPanel = panel
        $.DispatchEvent('UIShowCustomLayoutParametersTooltip', panel, "UnitTooltip", "file://{resources}/layout/custom_game/unittooltips.xml", "hero=1&ability=" + ability);
    })

    panel.SetPanelEvent("onmouseout", function () {

        // $.DispatchEvent("DOTAHideAbilityTooltip", panel);
        // $.DispatchEvent("DOTAHideTextTooltip", panel);

        gActiveTooltipPanel = null

        $.DispatchEvent("UIHideCustomLayoutTooltip", panel, "UnitTooltip")
    })
}

function AddScepterTooltip(panel, ability,selectedEntity) {

    $.Msg("AddScepterTooltip ",selectedEntity)

    panel.SetPanelEvent("onmouseover", function () {
        gActiveTooltipPanel = panel
        $.DispatchEvent('UIShowCustomLayoutParametersTooltip', panel, "ScepterTooltip", "file://{resources}/layout/custom_game/scepter_tooltips.xml", "hero=1&ability=" + ability+"&unit="+selectedEntity);
    })

    panel.SetPanelEvent("onmouseout", function () {
        // $.DispatchEvent("DOTAHideAbilityTooltip", panel);
        // $.DispatchEvent("DOTAHideTextTooltip", panel);
        gActiveTooltipPanel = null
        $.DispatchEvent("UIHideCustomLayoutTooltip", panel, "ScepterTooltip")
    })
}


function ApplyStyleFromString(panel, panelStyle) {

    panelStyle = panelStyle.replace(/(\r\n|\n|\r)/gm, "");

    var a = panelStyle.split(";");
    var b = [];

    for (var i = 0; i < a.length; i++) {
        b[i] = a[i].split(/:(.+)/);
        if (b[i][0] && b[i][1]) {
            let k = b[i][0].trim()
            let v = b[i][1].trim()
            panel.style[k] = v;
        }
    }
}
function CreateChildren(panelToAttach, type, panel_id_name, panelStyle, panelData) {
    var panel;
    if (type === "DOTAScenePanel") {
        panel = $.CreatePanelWithProperties(`DOTAScenePanel`, panelToAttach, panel_id_name, {
            camera: panelData.camera,
            particleonly: panelData.particleonly,
            map: panelData.map,
            antialias: panelData.antialias,
            light: panelData.light,
        });
    } else if (type == "DOTAAvatarImage") {
        panel = $.CreatePanelWithProperties(`DOTAAvatarImage`, panelToAttach, panel_id_name, {
            scaling: "stretch-to-fit-preserve-aspect",
        });
    } else {
        panel = $.CreatePanel(type, panelToAttach, panel_id_name);
    }

    panel.hittest = panelData.hittest;
    ApplyStyleFromString(panel, panelStyle);

    if (type == "Label" && panelData.text) {
        panel.text = panelData.text;
        panel.html = panelData.html || true;
    } else if (type == "Image" && panelData.img_src) {
        panel.SetImage(panelData.img_src);
    }

    if (panelData.class) {
        panel.AddClass(panelData.class);
    }

    return panel;
}

function dumpAllChild(prefix, panel, classCheck) {
    if (!panel) {
        return
    }
    $.Msg(prefix, " ", panel.paneltype, " ", panel.id, " ", panel.BHasClass(classCheck))

    for (let i = 0; i < panel.GetChildCount(); i++) {
        var lastPanel = panel.GetChild(i);
        dumpAllChild(prefix + "--", lastPanel)
    }
}

function AddCostlabel(panel, selectedEntity, abilityIndex, abilityName, isBuilding) {

    let CostContainer = panel.FindChildTraverse("ButtonSize")

    let legionGoldCost = CostContainer.FindChildTraverse("legionGoldCost")
    if (legionGoldCost) {
        legionGoldCost.DeleteAsync(0)
    }
    let legionFoodCost = CostContainer.FindChildTraverse("legionFoodCost")
    if (legionFoodCost) {
        legionFoodCost.DeleteAsync(0)
    }

    let legionWoodCost = CostContainer.FindChildTraverse("legionWoodCost")
    if (legionWoodCost) {
        legionWoodCost.DeleteAsync(0)
    }
    if (!isBuilding) {

    } else {
        let abilities = GAME_META.abilities

        let units = GAME_META.units 

        let abilityKv = abilities[abilityName]
        let unitname = null

        let uiType = null
        if (abilityKv.IsSummonAbility) {
            uiType = "goldAndFood"
        }
        uiType = abilityKv.LegionUiType || uiType

        if (uiType == "goldAndFood") {
            let gold = Abilities.GetSpecialValueFor(abilityIndex, "gold") || 0
            let food = Abilities.GetSpecialValueFor(abilityIndex, "food") || 0
            if (abilityName == "upgrade_fighter_level") {
                let parentName = Entities.GetUnitName(selectedEntity)
                let unitKv = units[parentName]
                if (unitKv) {
                    gold = unitKv.creepValue || 0
                    food = unitKv.creepFood || 0
                }
            }
            if (abilityName == "item_fighter_level_up") {
                let parentName = Entities.GetUnitName(selectedEntity)

                let unitKv = units[parentName]
                if (unitKv) {
                    gold = unitKv.creepValue || 0
                    food = unitKv.creepFood || 0
                }
            }

            let css1 = `
            color: #FFFF99;
            font-size: 14px;
            font-weight: bold;
            text-shadow: 0px 0px 3px 3.0 #000000;
            vertical-align: bottom;
            horizontal-align: left;
            `

            legionGoldCost = CreateChildren(CostContainer, "Label", "legionGoldCost", css1, { hittest: false });
            legionGoldCost.text = gold || 0

            let css2 = `
            font-size: 14px;
            font-weight: bold;
            text-shadow: 0px 0px 3px 3.0 #000000;
            vertical-align: bottom;
            horizontal-align: right;
            margin-right:5px;
            color: #ff576b;
            `

            legionFoodCost = CreateChildren(CostContainer, "Label", "legionFoodCost", css2, { hittest: false });
            legionFoodCost.text = food || 0
        }
        if (uiType == "wood") {
            let css1 = `
            color: #00fc8b;
            font-size: 14px;
            text-shadow: 0px 0px 3px 3.0 #000000;
            vertical-align: bottom;
            horizontal-align: right;
            `
            legionWoodCost = CreateChildren(CostContainer, "Label", "legionWoodCost", css1, { hittest: false });

            let wood = Abilities.GetSpecialValueFor(abilityIndex, "wood")
            legionWoodCost.text = wood
        }

        if (uiType == "goldAndWood") {
            let css1 = `
            color: #FFFF99;
            font-size: 14px;
            text-shadow: 0px 0px 3px 3.0 #000000;
            vertical-align: bottom;
            horizontal-align: left;
            `
            legionGoldCost = CreateChildren(CostContainer, "Label", "legionGoldCost", css1, { hittest: false });

            let gold = Abilities.GetSpecialValueFor(abilityIndex, "gold")
            legionGoldCost.text = gold

            let css2 = `
            color: #00fc8b;
            font-size: 14px;
            text-shadow: 0px 0px 3px 3.0 #000000;
            vertical-align: bottom;
            horizontal-align: right;
            `
            legionWoodCost = CreateChildren(CostContainer, "Label", "legionWoodCost", css2, { hittest: false });

            let wood = Abilities.GetSpecialValueFor(abilityIndex, "wood")
            legionWoodCost.text = wood
        }
        if (uiType == "gold") {
            let css1 = `
            color: #FFFF99;
            font-size: 14px;
            font-weight: bold;
            text-shadow: 0px 0px 3px 3.0 #000000;
            vertical-align: bottom;
            horizontal-align: left;
            `
            legionGoldCost = CreateChildren(CostContainer, "Label", "legionGoldCost", css1, { hittest: false });
            let gold = Abilities.GetSpecialValueFor(abilityIndex, "gold") || 0
            if (abilityName == "item_legiontd_aghanims_scepter") {
                let parentName = Entities.GetUnitName(selectedEntity)
                let unitKv = units[parentName]
                if (unitKv) {
                    gold = unitKv.ultimateAbilityGoldCost || 0
                }
            }
            legionGoldCost.text = gold

        }
    }
}
var mini_fix = true

function UpdateSelectedUnit() {

    // $.Msg("UpdateSelectedUnit")
    //clean tooltip 
    if (gActiveTooltipPanel) {
        $.DispatchEvent("UIHideCustomLayoutTooltip", gActiveTooltipPanel, "UnitTooltip")
        gActiveTooltipPanel = null
    }

    let selectedEntity = Players.GetLocalPlayerPortraitUnit()
    if (mini_fix) {
        mini_fix = false
        $.Schedule(0, function () {
            let PlayerTables = GameUI.CustomUIConfig().PlayerTables;
            let abilities =  GAME_META.abilities  
            let items = GAME_META.items  
            // 

            mini_fix = true
            for (let i = 0; i < 12; i++) {
                let abpanel = hud.FindChildTraverse('Ability' + i)
                if (!abpanel && i > 0) continue
                if (!abpanel) {
                    $.Schedule(0, UpdateSelectedUnit)
                    return
                }

                // dumpAllChild("", abpanel, "no_gold_cost")

                let btnsize = abpanel.FindChildTraverse('ButtonSize');
                if (!btnsize) {
                    $.Schedule(0, UpdateSelectedUnit)
                    return
                }
                let abbtn = btnsize.FindChild('AbilityButton');
                if (!abbtn) {
                    $.Schedule(0, UpdateSelectedUnit)
                    return
                }
                let abname = abbtn.FindChild("AbilityImage");
                let name = abname.abilityname;
                let abilityKv = abilities[name];

                if (name.indexOf("spawn_hero_") != -1) {
                    btnsize.SetPanelEvent("onmouseover", function () { })
                    btnsize.SetPanelEvent("onmouseout", function () { })
                    let info = CustomNetTables.GetTableValue('Hero_Levels', Entities.GetAbilityByName(selectedEntity, name))
                    AddHeroTooltip(abbtn, Entities.GetAbilityByName(selectedEntity, name), info ? info.lvl : 1)
                } else if (abilityKv != null && abilityKv["ScriptFile"] == "abilities/tower_upgrades.lua") {
                    btnsize.SetPanelEvent("onmouseover", function () { })
                    btnsize.SetPanelEvent("onmouseout", function () { })
                    AddGradeTooltip(abbtn, Entities.GetAbilityByName(selectedEntity, name), "tower_upgrades")
                } else {

                    // btnsize.SetPanelEvent("onmouseover", ShowAbilityTooltip(btnsize, selectedEntity, name))
                    // btnsize.SetPanelEvent("onmouseout", HideAbilityTooltip(btnsize))
                    // abbtn.SetPanelEvent("onmouseover", function() {})
                    // abbtn.SetPanelEvent("onmouseout", function() {})
                }

                if (abilityKv && abilityKv.IsSummonAbility) {
                    btnsize.SetPanelEvent("onmouseover", function () { })
                    btnsize.SetPanelEvent("onmouseout", function () { })
                    abbtn.SetPanelEvent("onmouseover", function () { })
                    abbtn.SetPanelEvent("onmouseout", function () { })
                    AddUnitTooltip(abbtn, Entities.GetAbilityByName(selectedEntity, name))

                } else {
                    btnsize.SetPanelEvent("onmouseover", ShowAbilityTooltip(btnsize, selectedEntity, name))
                    btnsize.SetPanelEvent("onmouseout", HideAbilityTooltip(btnsize))
                    abbtn.SetPanelEvent("onmouseover", function () { })
                    abbtn.SetPanelEvent("onmouseout", function () { })

                }

                if (abilityKv && (abilityKv.IsSummonAbility || abilityKv.LegionUiType)) {
                    AddCostlabel(abpanel, selectedEntity, Entities.GetAbilityByName(selectedEntity, name), name, true)
                } else {
                   // $.Msg("clear")
                    AddCostlabel(abpanel, selectedEntity, Entities.GetAbilityByName(selectedEntity, name), name, false)
                }
            }

            for (let i = 0; i < 9; i++) {
                let abpanel = hud.FindChildTraverse('inventory_slot_' + i)
                if (!abpanel && i > 0) continue
                if (!abpanel) {
                    $.Schedule(0, UpdateSelectedUnit)
                    return
                }

                let btnsize = abpanel.FindChildTraverse('ButtonSize');
                if (!btnsize) {
                    $.Schedule(0, UpdateSelectedUnit)
                    return
                }
                let abbtn = btnsize.FindChild('AbilityButton');
                if (!abbtn) {
                    $.Schedule(0, UpdateSelectedUnit)
                    return
                }

                
                let img = abbtn.FindChild("ItemImage");
                let name = img.itemname;
                let ab = Entities.GetItemInSlot(selectedEntity, i);
                let item = abilities[name];

                img.RemoveAndDeleteChildren()

                if (name == "") {
                    btnsize.SetPanelEvent("onmouseover", function () { })
                    btnsize.SetPanelEvent("onmouseout", function () { })
                    abbtn.SetPanelEvent("onmouseover", function () { })
                    abbtn.SetPanelEvent("onmouseout", function () { })
                    AddCostlabel(abpanel, selectedEntity, ab, name, false)
                } else if (item) {
                    if (item["ScriptFile"] == "items/creep_spawn_items.lua") {
                        btnsize.SetPanelEvent("onmouseover", function () { })
                        btnsize.SetPanelEvent("onmouseout", function () { })
                        AddUnitTooltip(abbtn, ab)
                    } else if (item["ScriptFile"] == "items/items_upgrades.lua") {
                        btnsize.SetPanelEvent("onmouseover", function () { })
                        btnsize.SetPanelEvent("onmouseout", function () { })
                        AddGradeTooltip(abbtn, ab, "upgrades")

                        var race_data = CustomNetTables.GetTableValue("Player_Races", Entities.GetPlayerOwnerID(Players.GetLocalPlayerPortraitUnit()).toString())
                        if (race_data) {
                            var raceid = race_data.race,
                                races = PlayerTables.GetTableValue("kvs", "races"),
                                gradeKV = races[race_names[raceid].toLowerCase()]["race_data"]["upgrades"][name]
                            var new_img = $.CreatePanel("Image", img, "NewItemImage")
                            new_img.SetImage(gradeKV.icon) //"file://{resources}/images/castle_upgrades/treants/"+(i+1)+".png"
                        }

                    } 
                    else if (name=="item_legiontd_aghanims_scepter"){
                        //$.Msg(121212)

                        btnsize.SetPanelEvent("onmouseover", function () { })
                        btnsize.SetPanelEvent("onmouseout", function () { })
                        abbtn.SetPanelEvent("onmouseover", function () { })
                        abbtn.SetPanelEvent("onmouseout", function () { })
                        AddScepterTooltip(abbtn, ab,selectedEntity)

                    }
                    else {
                        btnsize.SetPanelEvent("onmouseover", ShowAbilityTooltip(btnsize, selectedEntity, name))
                        btnsize.SetPanelEvent("onmouseout", HideAbilityTooltip(btnsize))
                        abbtn.SetPanelEvent("onmouseover", function () { })
                        abbtn.SetPanelEvent("onmouseout", function () { })
                    }


                    let abilityKv = abilities[name];
                    if (abilityKv && (abilityKv.IsSummonAbility || abilityKv.LegionUiType)) {
                        AddCostlabel(abpanel, selectedEntity,ab, name, true)
                    } else {
                       // $.Msg("clear")
                        AddCostlabel(abpanel, selectedEntity, ab, name, false)
                    }
                }
            }
        })
    }
}
var ShowAbilityTooltip = (function (abpanel, ability, name) {
    return function () {
        $.DispatchEvent("DOTAShowAbilityTooltipForEntityIndex", abpanel, name, ability);
    }
});

var HideAbilityTooltip = (function (ability) {
    return function () {
        $.DispatchEvent("DOTAHideAbilityTooltip", ability);
    }
});

(function () {

    GameEvents.Subscribe("dota_player_update_query_unit", UpdateSelectedUnit)
    GameEvents.Subscribe('dota_player_update_hero_selection', UpdateSelectedUnit)
    GameEvents.Subscribe('dota_player_update_selected_unit', UpdateSelectedUnit)
    GameEvents.Subscribe('dota_ability_changed', UpdateSelectedUnit)
    GameEvents.Subscribe('dota_inventory_item_added', UpdateSelectedUnit)
    GameEvents.Subscribe('dota_inventory_item_changed', UpdateSelectedUnit)
    GameEvents.Subscribe('dota_inventory_changed', UpdateSelectedUnit)

})();
