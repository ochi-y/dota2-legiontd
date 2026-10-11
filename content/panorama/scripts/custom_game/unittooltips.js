var alt = false;
var ab;
const context = $.GetContextPanel()



function SetupTooltip() {

    ab = context.GetAttributeInt("ability", -1)
    if (ab == 0) {
        ab = context.GetAttributeString("ability", -1)
    }
    if (ab && ab != -1) {
        SetupUnit()
    }
}


function fillUnitKv(kvInfo, abilityName) {
    let PlayerTables = GameUI.CustomUIConfig().PlayerTables;

    let abilities = GAME_META.abilities
    let items =GAME_META.items 
    let units = GAME_META.units 
    let abilityKv = abilities[abilityName]

    let unitname = null
    if (abilityKv && abilityKv.Summon && abilityKv.Summon.SummonUnit) {
        unitname = abilityKv.Summon.SummonUnit;
    }
    // 
    let unitKv = units[unitname]

    let res = []
    for (const node of kvInfo) {
        // 
        if (node.name == "attack_speed" && unitKv) {

            let as = (100 * unitKv.AttackRate / (unitKv.BaseAttackSpeed || 100))
            let str = (100 * 1.7 / as).toFixed(0) + " (" + as.toFixed(2) + ")"
            node.value = str
            res.push(node)
        }
        if (node.name == "damage" && unitKv) {
            node.value = unitKv.AttackDamageMin + "-" + unitKv.AttackDamageMax
            res.push(node)
        }
        if (node.name == "attack_range" && unitKv) {
            node.value = (unitKv.AttackRange)
            res.push(node)
        }
        if (node.name == "move_speed" && unitKv) {
            node.value = (unitKv.MovementSpeed)
            res.push(node)
        }
        if (node.name == "health" && unitKv) {
            node.value = (unitKv.StatusHealth)
            res.push(node)
        }
        if (node.name == "unit_count_limit" && unitKv && unitKv.UnitCountLimit !== undefined && unitKv.UnitCountLimit !== null && unitKv.UnitCountLimit !== "") {
            node.value = unitKv.UnitCountLimit
            res.push(node)
        }
        if (node.name == "need_round" && abilityKv && abilityKv.Summon && abilityKv.Summon.need_round) {
            node.value = (abilityKv.Summon.need_round)
            res.push(node)
        }
        if (node.name == "wood" && abilityKv && abilityKv.Summon && abilityKv.Summon.wood) {
            node.value = (abilityKv.Summon.wood)
            res.push(node)
        }
        if (node.name == "gold" && abilityKv && abilityKv.Summon && abilityKv.Summon.gold) {
            node.value = (abilityKv.Summon.gold)
            res.push(node)
        }
        if (node.name == "food" && abilityKv && abilityKv.Summon && abilityKv.Summon.food) {
            node.value = (abilityKv.Summon.food)
            res.push(node)
        }
        if (node.name == "income" && abilityKv && abilityKv.Summon && abilityKv.Summon.income) {
            node.value = (abilityKv.Summon.income)
            res.push(node)
        }

        // 
    }
    // 
    return res
}


function SetupUnit() {


    $.GetContextPanel().RemoveAndDeleteChildren();
    let tooltip = $.CreatePanel("Panel", $.GetContextPanel(), "UnitTooltip");
    tooltip.BLoadLayoutSnippet('UnitTooltip');
    let Util = GameUI.CustomUIConfig().Util;
    let PlayerTables = GameUI.CustomUIConfig().PlayerTables;
    let name;
    let cd;
    if ((typeof ab) == "string") {
        name = ab
    } else {
        name = Abilities.GetAbilityName(ab)
    }
    if (name == "")
        return
    let abilities = GAME_META.abilities
    let items =GAME_META.items 
    let units = GAME_META.units 


    let desc = $.Localize("#DOTA_Tooltip_ability_" + name + "_Description2");


    let abilityKv = abilities[name]

   

    if (abilityKv && abilityKv["AbilityValues"]) {
        for (name in abilityKv["AbilityValues"]) {
            let value = abilityKv["AbilityValues"]["name"]
        }
    }


    $("#DescLabel").text = desc

    $("#DescLabel").visible = false


    var kvInfo = [
        { name: "attack_speed", value: 0, },
        { name: "damage", value: 0, },
        { name: "attack_range", value: 0, },
        { name: "move_speed", value: 0, },
        { name: "health", value: 0, },
        { name: "unit_count_limit", value: 0, color: "#EC615D", key_text: $.Localize("#ui_unit_count_limit") == "#ui_unit_count_limit" ? "Unit Count Limit" : $.Localize("#ui_unit_count_limit") },
        { name: "gold", value: 0, color: "#FFD23E" },  // Dota 2 gold colour
        { name: "wood", value: 0, color: "#7FE83F" },  // Dota 2 heal/nature colour
        { name: "food", value: 0, color: "#66D9F0" },  // Dota 2 mana colour
        { name: "income", value: 0, color: "#FFC933" }, // Dota 2 ability gold
        { name: "need_round", value: 0, color: "#EC615D" }, // Dota 2 damage colour

    ]
    kvInfo = fillUnitKv(kvInfo, name)

    for (const node of kvInfo) {


        let attr = $.CreatePanel("Panel", tooltip.FindChildTraverse("abilityAttrContainer"), "UnitAttr");
        attr.BLoadLayoutSnippet('UnitAttr');

        attr.SetDialogVariable("attr_value", "value")
        let attrKeyText = node.key_text || $.Localize("#ui_" + node.name)
        if (node.color) {
            attr.SetDialogVariable("attr_key", Util.ColorString(attrKeyText, node.color))

        } else {
            attr.SetDialogVariable("attr_key", attrKeyText)

        }

        attr.SetDialogVariable("attr_value", Util.ColorString(node.value, "#fff"))

    }


    let unitname = abilityKv.Summon.SummonUnit;

    tooltip.FindChildTraverse("AbilityIcon").abilityname = name

    // 
    let unitKv = units[unitname]

    if (unitKv) {
        if (unitKv.AttackType) {
            tooltip.FindChildTraverse("attackTypeImg").abilityname = unitKv.AttackType
            tooltip.FindChildTraverse("attackTypeLabel").text = $.Localize("#" + unitKv.AttackType)
        }

        if (unitKv.ArmorType) {
            tooltip.FindChildTraverse("armorTypeImg").abilityname = unitKv.ArmorType
            tooltip.FindChildTraverse("armorTypeLabel").text = $.Localize("#" + unitKv.ArmorType)
        }
        if (unitKv.AttackCapabilities) {
            if (unitKv.AttackCapabilities == "DOTA_UNIT_CAP_RANGED_ATTACK") {
                tooltip.FindChildTraverse("attack_capability").SetImage("file://{images}/custom_game/BTNImprovedBows-Reforged.png")
            } else if (unitKv.AttackCapabilities == "DOTA_UNIT_CAP_MELEE_ATTACK") {
                tooltip.FindChildTraverse("attack_capability").SetImage("file://{images}/custom_game/BTNAttack-Reforged.png")
            } else {
                tooltip.FindChildTraverse("attack_capability_node").AddClass("Hidden")
            }
        }
    }
    let curabpanel;
    
    if (name.startsWith("buy_")) {
        $("#SummonTitle").text = $.Localize("#ui_token_send") + " " + $.Localize("#" + unitname)
    }
    else if (name.startsWith("build_")) {
        $("#SummonTitle").text = $.Localize("#ui_token_build") + " " + $.Localize("#" + unitname)
    }
    else if (name.startsWith("upgrade_")) {
        $("#SummonTitle").text = $.Localize("#ui_token_upgrade") + " " + $.Localize("#" + unitname)
    } else {
        $("#SummonTitle").text = $.Localize("#" + unitname)
    }

    cd = abilityKv["AbilityChargeRestoreTime"] | abilityKv["AbilityCooldown"]
    let hasCooldown = false
    if (cd != undefined && cd != 0) {
        cd = cd.toString()
        if (cd.split) {
            cd = cd.split(" ").join('/');
            cdlabel = Util.ColorString(cd, '#fff')
            tooltip.FindChildTraverse("Cooldown").text = cdlabel
            hasCooldown = true
        } else {
            tooltip.FindChildTraverse("Cooldown").visible = false
        }
    } else {
        tooltip.FindChildTraverse("Cooldown").visible = false
    }
    //
    cd = abilityKv["AbilityManaCost"]
    let hasManaCost = false
    if (cd != undefined) {
        cd = cd.toString()
        if (cd.split) {
            cd = cd.split(" ").join('/');
            cdlabel = Util.ColorString(cd, '#fff')
            tooltip.FindChildTraverse("ManaCost").text = cdlabel
            hasManaCost = true
        } else {
            tooltip.FindChildTraverse("ManaCost").visible = false
        }
    } else {
        tooltip.FindChildTraverse("ManaCost").visible = false
    }

    // With no Cooldown or ManaCost, hide the whole AbilityCosts container
    let abilityCostsPanel = tooltip.FindChildrenWithClassTraverse("AbilityCosts")
    if (abilityCostsPanel && abilityCostsPanel.length > 0) {
        abilityCostsPanel[0].visible = hasCooldown || hasManaCost
    }
    i++;

    var i = 0;
    if (unitKv) {
        for (var k in unitKv["abilities"]) {
            let curab = unitKv["abilities"][k]

            curabpanel = $.CreatePanel("Panel", $("#AbilityDescriptionContainer"), "Ability" + i)
            curabpanel.BLoadLayoutSnippet("UnitAbility")
            curabpanel.FindChildTraverse("AbilityName").text = $.Localize("#DOTA_Tooltip_ability_" + curab).toUpperCase()
            //
            curabpanel.FindChildTraverse("AbilityIcon").abilityname = curab


            let desc = $.Localize("#DOTA_Tooltip_ability_" + curab + "_Description")
            desc = GameUI.ReplaceDOTAAbilitySpecialValues(curab, desc);
            // 
            curabpanel.FindChildTraverse("DescLabel").text = desc
            // 
            if (!abilities[curab]) {
                continue
            }
            i++;
        }
    }

}

function dota_ability_changed(t) {
    if (ab == t.entityIndex) {
        SetupTooltip()
    }
}

(function () {
    GameEvents.Subscribe('dota_ability_changed', dota_ability_changed)
})()
