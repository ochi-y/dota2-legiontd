var mainPanel = $.GetContextPanel().FindChildInLayoutFile("wikiPanel");




mainPanel.SetPanelEvent("oncancel", onCloseBtn);


let contentPanels = {
    SummonsPanel: mainPanel.FindChildTraverse("SummonsPanel"),
    WavesPanel: mainPanel.FindChildTraverse("WavesPanel"),
    BuildersPanel: mainPanel.FindChildTraverse("BuildersPanel"),
    KingPanel: mainPanel.FindChildTraverse("KingPanel"),
    CommandsPanel: mainPanel.FindChildTraverse("CommandsPanel"),
}


let CUEERNE_PANEL = null

var ShowAbilityTooltip = (function(abpanel,  name) {
    return function() {
        //$.DispatchEvent("DOTAShowAbilityTooltipForEntityIndex", abpanel, name, ability);
        $.DispatchEvent("DOTAShowAbilityTooltip", abpanel,name);
    }
});

var HideAbilityTooltip = (function(ability) {
    return function() {
        $.DispatchEvent("DOTAHideAbilityTooltip", ability);
    }
});

function showPanel(panelName) {
    CUEERNE_PANEL = panelName
    for (const key in contentPanels) {
        let panel = contentPanels[key]
        if (key == panelName) {
            panel.RemoveClass("Hidden")
        } else {
            panel.AddClass("Hidden")
        }
    }
}

function onCloseBtn() {
    Game.EmitSound("ui_find_match_cancel");
    mainPanel.AddClass("Hidden");

}

function onClickButton(name) {

    Game.EmitSound("ui_topmenu_activate");

    if (name == "Summons") {
        showPanel("SummonsPanel")
    } else if (name == "Waves") {
        showPanel("WavesPanel")
    } else if (name == "Builders") {
        showPanel("BuildersPanel")
    } else if (name == "King") {
        showPanel("KingPanel")
    } else if (name == "Commands") {
        showPanel("CommandsPanel")
    }
}

function onClickWiki() {
    mainPanel.RemoveClass("Hidden");
    Game.EmitSound("ui_topmenu_activate");
}


function setAttackCapabilityImage(card, unitKv) {

    if (unitKv.AttackCapabilities == "DOTA_UNIT_CAP_RANGED_ATTACK") {
        let attack_capability = card.FindChildTraverse("attack_capability")
        attack_capability.SetImage("file://{images}/custom_game/BTNImprovedBows-Reforged.png")

        attack_capability.SetPanelEvent("onmouseover", function() {
            $.DispatchEvent('UIShowTextTooltip', attack_capability, "#ui_ranged");
        });

        attack_capability.SetPanelEvent("onmouseout", function() { $.DispatchEvent('UIHideTextTooltip', attack_capability); });

    } else if (unitKv.AttackCapabilities == "DOTA_UNIT_CAP_MELEE_ATTACK") {
        let attack_capability = card.FindChildTraverse("attack_capability")
        attack_capability.SetImage("file://{images}/custom_game/BTNAttack-Reforged.png")
        attack_capability.SetPanelEvent("onmouseover", function() { $.DispatchEvent('UIShowTextTooltip', attack_capability, "#ui_melee"); });
        attack_capability.SetPanelEvent("onmouseout", function() { $.DispatchEvent('UIHideTextTooltip', attack_capability); });
    } else {
        card.FindChildTraverse("attack_capability").AddClass("Hidden")
    }
}

function updateSummons() {
    mainPanel.FindChildTraverse("SummonsPanelSub").RemoveAndDeleteChildren()

    let SummonsPanel = mainPanel.FindChildTraverse("SummonsPanelSub")

    let PlayerTables = GameUI.CustomUIConfig().PlayerTables;
    let abilities = GAME_META.abilities
    let items = GAME_META.items 
    let units =  GAME_META.units  
    let summons = GAME_META.summons  

    for (const key in summons) {
        let unitName = summons[key]
        let abilityName = "buy_" + unitName

        var card = $.CreatePanel("Panel", SummonsPanel, "");
        card.BLoadLayoutSnippet("SummonUnitCard");


        card.SetDialogVariable("unit_name", "#" + key + " " + $.Localize("#" + unitName))



        let unitKv = units[unitName]
        let abilityKv = abilities[abilityName]

        // card.FindChildTraverse("abilityImage").abilityname = "buy_" + unitName
        
   const unitScene = card.FindChildInLayoutFile("unitScene");
   unitScene.SetUnit(unitName, "default_camera", true);

   
        if (unitKv && abilityKv) {
            card.SetDialogVariable("health", unitKv.StatusHealth)
            
            card.SetDialogVariable("health_regen", "+" + unitKv.StatusHealthRegen)

            card.SetDialogVariable("mana", unitKv.StatusMana)
            card.SetDialogVariable("mana_regen", "+" + parseFloat(unitKv.StatusManaRegen).toFixed(2))

            card.FindChildTraverse("unitAttackType").abilityname = unitKv.AttackType

            card.SetDialogVariable("attack_damage", unitKv.AttackDamageMin + "-" + unitKv.AttackDamageMax + " (" + ((unitKv.AttackDamageMin + unitKv.AttackDamageMax) / 2).toFixed(0) + ")")

            let as = (100 * unitKv.AttackRate / (unitKv.BaseAttackSpeed || 100))
            let str = (100 * 1.7 / as).toFixed(0) + " (" + as.toFixed(2) + ")"

            card.SetDialogVariable("attack_speed", str)
            card.SetDialogVariable("attack_range", unitKv.AttackRange)


            card.FindChildTraverse("unitArmorType").abilityname = unitKv.ArmorType

            card.SetDialogVariable("armor", unitKv.ArmorPhysical)

            card.SetDialogVariable("move_speed", unitKv.MovementSpeed)
            card.SetDialogVariable("bounty", ((unitKv.BountyGoldMin + unitKv.BountyGoldMax) / 2).toFixed(0))

            setAttackCapabilityImage(card, unitKv)

            card.SetDialogVariable("lumber_cost", abilityKv.Summon.wood)
            card.SetDialogVariable("income", abilityKv.Summon.income)
            card.SetDialogVariable("round", abilityKv.Summon.need_round || 1)



            let unitAbilities = unitKv.abilities
            let abilityListPanel = card.FindChildTraverse("abilityListPanel")

            abilityListPanel.RemoveAndDeleteChildren()
            if (unitAbilities) {
                let c = 0
                for (const index in unitAbilities) {
                    const abilityName = unitAbilities[index]

                    var AbilityItem = $.CreatePanel("Panel", abilityListPanel, "");
                    AbilityItem.BLoadLayoutSnippet("AbilityItem");
                    AbilityItem.SetDialogVariable("ability_name", $.Localize("#DOTA_Tooltip_ability_" + abilityName))
                    AbilityItem.FindChildTraverse("AbilityItem_abilityImage").abilityname = abilityName
                    AbilityItem.SetPanelEvent("onmouseover", ShowAbilityTooltip(AbilityItem,abilityName))
                    AbilityItem.SetPanelEvent("onmouseout", HideAbilityTooltip(AbilityItem))
                    if (c != 0) {
                        AbilityItem.AddClass("margint_top_2")
                    }
                    c = c + 1
                }
                if (c == 0) {
                    var label = $.CreatePanel("Label", abilityListPanel, "");
                    label.AddClass("AttrLabelRight")
                    label.text = "--"
                }
            }

        }


        // card.SetDialogVariable("health", cstring cstring_2)
    }

}

function updateWaves() {
    mainPanel.FindChildTraverse("WavesPanelSub").RemoveAndDeleteChildren()

    let WavesPanel = mainPanel.FindChildTraverse("WavesPanelSub")

    let PlayerTables = GameUI.CustomUIConfig().PlayerTables;
    let abilities = GAME_META.abilities
    let items =GAME_META.items 
    let units = GAME_META.units  
    let waves = GAME_META.waves 


    for (const key in waves) {
        let wave = waves[key]
        let unitName = wave.unit
        let abilityName = "buy_" + unitName

        var card = $.CreatePanel("Panel", WavesPanel, "");
        card.BLoadLayoutSnippet("WaveUnitCard");


        card.SetDialogVariable("unit_name", "#" + key + " " + $.Localize("#" + unitName))


        let unitKv = units[unitName]
            // let abilityKv = abilities[abilityName]
            // 


       // card.FindChildTraverse("abilityImage").SetImage("file://{images}/custom_game/waves/" + unitName + ".png")


       const unitScene = card.FindChildInLayoutFile("unitScene");
        unitScene.SetUnit(unitName, "default_camera", true);

        if (unitKv) {
            card.SetDialogVariable("health", unitKv.StatusHealth)
            card.SetDialogVariable("health_regen", "+" + unitKv.StatusHealthRegen)

            card.SetDialogVariable("mana", unitKv.StatusMana)
            card.SetDialogVariable("mana_regen", "+" + parseFloat(unitKv.StatusManaRegen).toFixed(2))

            card.FindChildTraverse("unitAttackType").abilityname = unitKv.AttackType

            card.SetDialogVariable("attack_damage", unitKv.AttackDamageMin + "-" + unitKv.AttackDamageMax + " (" + ((unitKv.AttackDamageMin + unitKv.AttackDamageMax) / 2).toFixed(0) + ")")

            let as = (100 * unitKv.AttackRate / (unitKv.BaseAttackSpeed || 100))
            let str = (100 * 1.7 / as).toFixed(0) + " (" + as.toFixed(2) + ")"

            card.SetDialogVariable("attack_speed", str)
            card.SetDialogVariable("attack_range", unitKv.AttackRange)


            card.FindChildTraverse("unitArmorType").abilityname = unitKv.ArmorType

            card.SetDialogVariable("armor", unitKv.ArmorPhysical)

            card.SetDialogVariable("move_speed", unitKv.MovementSpeed)
            card.SetDialogVariable("bounty", ((unitKv.BountyGoldMin + unitKv.BountyGoldMax) / 2).toFixed(0))

            setAttackCapabilityImage(card, unitKv)


            card.SetDialogVariable("wave_gold", wave.waveGold)
            card.SetDialogVariable("wave_value", wave.value)
            card.SetDialogVariable("wave_count", wave.count)




            // card.SetDialogVariable("lumber_cost", abilityKv.Summon.wood)
            // card.SetDialogVariable("income", abilityKv.Summon.income)
            // card.SetDialogVariable("round", abilityKv.Summon.need_round || 1)

            let unitAbilities = unitKv.abilities
            let abilityListPanel = card.FindChildTraverse("abilityListPanel")

            abilityListPanel.RemoveAndDeleteChildren()
            if (unitAbilities) {
                let c = 0
                for (const index in unitAbilities) {
                    const abilityName = unitAbilities[index]

                    var AbilityItem = $.CreatePanel("Panel", abilityListPanel, "");
                    AbilityItem.BLoadLayoutSnippet("AbilityItem");
                    AbilityItem.SetDialogVariable("ability_name", $.Localize("#DOTA_Tooltip_ability_" + abilityName))
                    AbilityItem.FindChildTraverse("AbilityItem_abilityImage").abilityname = abilityName
                    AbilityItem.SetPanelEvent("onmouseover", ShowAbilityTooltip(AbilityItem,abilityName))
                    AbilityItem.SetPanelEvent("onmouseout", HideAbilityTooltip(AbilityItem))
                    if (c != 0) {
                        AbilityItem.AddClass("margint_top_2")
                    }
                    c = c + 1
                }
                if (c == 0) {
                    var label = $.CreatePanel("Label", abilityListPanel, "");
                    label.AddClass("AttrLabelRight")
                    label.text = "--"
                }
            }

        }


        // card.SetDialogVariable("health", cstring cstring_2)
    }

}

function updateBuildersDetail(name) {
    mainPanel.FindChildTraverse("BuildersPanelSub").RemoveAndDeleteChildren()

    let BuildersPanelSub = mainPanel.FindChildTraverse("BuildersPanelSub")
    let BuildersPanel = mainPanel.FindChildTraverse("BuildersPanel")
        // 
    let PlayerTables = GameUI.CustomUIConfig().PlayerTables;
    let abilities = GAME_META.abilities
    let items =GAME_META.items 
    let units = GAME_META.units  
    let waves = GAME_META.waves 



    let builders = GAME_META.builders 
    // 

    let builder = null
    for (const key in builders) {
        if (builders[key].name == name) {
            builder = builders[key]
        }
    }
    // 

    BuildersPanel.SetDialogVariable("builder_title", $.Localize("#" + name))
    BuildersPanel.SetDialogVariable("builder_desc", $.Localize("#" + name + "_desc"))


    if (builder) {
        let fighters = builder.fighters
        for (const key in fighters) {
            let unitName = fighters[key]
            let abilityName = "build_" + unitName
            if (!abilities[abilityName]) {
                abilityName = "upgrade_" + unitName
            }
            // 
            var card = $.CreatePanel("Panel", BuildersPanelSub, "");
            card.BLoadLayoutSnippet("FighterUnitCard");
            card.SetDialogVariable("unit_name", "#" + key + " " + $.Localize("#" + unitName))
            let unitKv = units[unitName]
            let abilityKv = abilities[abilityName]
                // 
           // card.FindChildTraverse("abilityImage").abilityname = abilityName
            
            const unitScene = card.FindChildInLayoutFile("unitScene");
            unitScene.SetUnit(unitName, "default_camera", true);
            
    

           if (unitKv && abilityKv) {
                card.SetDialogVariable("health", unitKv.StatusHealth)

                card.SetDialogVariable("health_regen", "+" + parseFloat(unitKv.StatusHealthRegen).toFixed(2))

                card.SetDialogVariable("mana", unitKv.StatusMana)
                card.SetDialogVariable("mana_regen", "+" + parseFloat(unitKv.StatusManaRegen).toFixed(2))

                card.FindChildTraverse("unitAttackType").abilityname = unitKv.AttackType

                card.SetDialogVariable("attack_damage", unitKv.AttackDamageMin + "-" + unitKv.AttackDamageMax + " (" + ((unitKv.AttackDamageMin + unitKv.AttackDamageMax) / 2).toFixed(0) + ")")

                let as = (100 * unitKv.AttackRate / (unitKv.BaseAttackSpeed || 100))
                let str = (100 * 1.7 / as).toFixed(0) + " (" + as.toFixed(2) + ")"

                card.SetDialogVariable("attack_speed", str)
                card.SetDialogVariable("attack_range", unitKv.AttackRange)


                card.FindChildTraverse("unitArmorType").abilityname = unitKv.ArmorType

                card.SetDialogVariable("armor", unitKv.ArmorPhysical)

                card.SetDialogVariable("move_speed", unitKv.MovementSpeed)
                card.SetDialogVariable("bounty", ((unitKv.BountyGoldMin + unitKv.BountyGoldMax) / 2).toFixed(0))

                setAttackCapabilityImage(card, unitKv)

                card.SetDialogVariable("lumber_cost", abilityKv.Summon.wood)

                card.SetDialogVariable("gold_cost", abilityKv.Summon.gold || 0)
                card.SetDialogVariable("food_cost", abilityKv.Summon.food || 0)




                let unitAbilities = unitKv.abilities
                let abilityListPanel = card.FindChildTraverse("abilityListPanel")

                abilityListPanel.RemoveAndDeleteChildren()
                if (unitAbilities) {
                    let c = 0
                    for (const index in unitAbilities) {
                        const abilityName = unitAbilities[index]

                        var AbilityItem = $.CreatePanel("Panel", abilityListPanel, "");
                        AbilityItem.BLoadLayoutSnippet("AbilityItem");
                        AbilityItem.SetDialogVariable("ability_name", $.Localize("#DOTA_Tooltip_ability_" + abilityName))
                        AbilityItem.FindChildTraverse("AbilityItem_abilityImage").abilityname = abilityName

                        AbilityItem.SetPanelEvent("onmouseover", ShowAbilityTooltip(AbilityItem,abilityName))
                        AbilityItem.SetPanelEvent("onmouseout", HideAbilityTooltip(AbilityItem))

                        if (c != 0) {
                            AbilityItem.AddClass("margint_top_2")
                        }
                        c = c + 1
                    }
                    if (c == 0) {
                        var label = $.CreatePanel("Label", abilityListPanel, "");
                        label.AddClass("AttrLabelRight")
                        label.text = "--"
                    }
                }

            }


            // card.SetDialogVariable("health", cstring cstring_2)
        }
    }
}

function updateBuilders() {
    mainPanel.FindChildTraverse("builderList").RemoveAndDeleteChildren()

    let builderList = mainPanel.FindChildTraverse("builderList")
    let BuildersPanel = mainPanel.FindChildTraverse("BuildersPanel")


    let PlayerTables = GameUI.CustomUIConfig().PlayerTables;


    let builders =GAME_META.builders




    for (const key in builders) {
        const builder = builders[key]
        var newButton = $.CreatePanel("Panel", builderList, "");
        newButton.BLoadLayoutSnippet("builderButton");
        newButton.FindChildTraverse("builderHeroImage").SetUnit(builder.name, "default_camera", true);
        newButton.SetDialogVariable("builder_name", $.Localize("#" + builder.name))
        let builderHeroImage = newButton.FindChildTraverse("builderHeroImage")
        builderHeroImage.SetPanelEvent("onactivate", function() {
            Game.EmitSound("ui_generic_button_click")
            updateBuildersDetail(builder.name)
        });
    }

    updateBuildersDetail("npc_dota_hero_tusk")
}

function updateKing() {
    mainPanel.FindChildTraverse("kingUpgradesList").RemoveAndDeleteChildren()
    
    let kingUpgradesList = mainPanel.FindChildTraverse("kingUpgradesList")
    let PlayerTables = GameUI.CustomUIConfig().PlayerTables;
    let king =GAME_META.king 

    for (const key in king.upgrades) {
        const abilityName = king.upgrades[key]

        var abilityCard = $.CreatePanel("Panel", kingUpgradesList, "");
        abilityCard.BLoadLayoutSnippet("KingAbilityCard");
        abilityCard.SetDialogVariable("ability_name", $.Localize("#DOTA_Tooltip_ability_" + abilityName))
        abilityCard.SetDialogVariable("ability_name", $.Localize("#DOTA_Tooltip_ability_" + abilityName))
        let desc = $.Localize("#DOTA_Tooltip_ability_" + abilityName + "_Description")
        desc = GameUI.ReplaceDOTAAbilitySpecialValues(abilityName, desc);
        abilityCard.SetDialogVariable("ability_desc", desc)
        abilityCard.FindChildTraverse("AbilityImage").abilityname = abilityName
    }
    //
    mainPanel.FindChildTraverse("kingInnateList").RemoveAndDeleteChildren()
    let kingInnateList = mainPanel.FindChildTraverse("kingInnateList")
    for (const key in king.innate) {
        const abilityName = king.innate[key]

        var abilityCard = $.CreatePanel("Panel", kingInnateList, "");
        abilityCard.BLoadLayoutSnippet("KingAbilityCard");
        abilityCard.SetDialogVariable("ability_name", $.Localize("#DOTA_Tooltip_ability_" + abilityName))
        abilityCard.SetDialogVariable("ability_name", $.Localize("#DOTA_Tooltip_ability_" + abilityName))
        let desc = $.Localize("#DOTA_Tooltip_ability_" + abilityName + "_Description")
        desc = GameUI.ReplaceDOTAAbilitySpecialValues(abilityName, desc);
        abilityCard.SetDialogVariable("ability_desc", desc)

        abilityCard.FindChildTraverse("AbilityImage").abilityname = abilityName
    }
    //
    mainPanel.FindChildTraverse("kingAbilityList").RemoveAndDeleteChildren()
    let kingAbilityList = mainPanel.FindChildTraverse("kingAbilityList")
    for (const key in king.abilities) {
        const abilityName = king.abilities[key]

        var abilityCard = $.CreatePanel("Panel", kingAbilityList, "");
        abilityCard.BLoadLayoutSnippet("KingAbilityCard");
        abilityCard.SetDialogVariable("ability_name", $.Localize("#DOTA_Tooltip_ability_" + abilityName))
        abilityCard.SetDialogVariable("ability_name", $.Localize("#DOTA_Tooltip_ability_" + abilityName))
        let desc = $.Localize("#DOTA_Tooltip_ability_" + abilityName + "_Description")
        desc = GameUI.ReplaceDOTAAbilitySpecialValues(abilityName, desc);
        abilityCard.SetDialogVariable("ability_desc", desc)
        abilityCard.FindChildTraverse("AbilityImage").abilityname = abilityName
    }
}

function updateUi() {
    updateSummons()
    updateWaves()
    updateBuilders()

    updateKing()

}

let openCount = 0

function top_buttons(data) {
    if (data && data.name && data.name == "wiki") {
        updateUi()
        onClickWiki()

        if (CUEERNE_PANEL == null) {
            CUEERNE_PANEL = "WavesPanel"
        }
        showPanel(CUEERNE_PANEL)
    }
}

(function() {
    // Game.AddCommand( "CustomGameExecuteAbility1", OnExecuteAbility1ButtonPressed, "", 0 );
    GameEvents.Subscribe("top_buttons", top_buttons)

})();