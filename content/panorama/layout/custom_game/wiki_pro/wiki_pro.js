"use strict";

// Main panel reference
var mainPanel = $.GetContextPanel().FindChildInLayoutFile("wikiProRoot");

// Active tab and current selection
var currentTab = "Summons";
var selectedItems = {
    Summons: null,
    Waves: null,
    Builders: null,
    King: "upgrades",
    Commands: "general"
};

// Initialisation
function InitWikiPro() {
    // Load the data of every tab
    LoadSummonsData();
    LoadWavesData();
    LoadBuildersData();
    LoadKingData();
    LoadCommandsData();

    // Select the first entry by default
    $.Schedule(0.1, function() {
        SelectFirstItems();
    });
}

// Tab switching
function switchTab(tabName) {
    // Refresh the tab button state
    var tabs = ["Summons", "Waves", "Builders", "King", "Commands"];
    for (var i = 0; i < tabs.length; i++) {
        var tabBtn = $("#tab" + tabs[i]);
        var panel = $("#panel" + tabs[i]);

        if (tabs[i] === tabName) {
            tabBtn.AddClass("active");
            panel.RemoveClass("Hidden");
        } else {
            tabBtn.RemoveClass("active");
            panel.AddClass("Hidden");
        }
    }

    currentTab = tabName;
}

// Close the wiki
function onCloseWiki() {
    if (mainPanel) {
        mainPanel.AddClass("Hidden");
        Game.EmitSound("ui_generic_button_click");
    }
}

// Load the summoned unit data
function LoadSummonsData() {
    var summonsList = $("#summonsList");

    // Clear the old data
    summonsList.RemoveAndDeleteChildren();

    // Pull the real data from GAME_META
    if (typeof GAME_META === "undefined" || !GAME_META.summons) {
        $.Msg("[WikiPro] GAME_META not loaded yet, retrying...");
        $.Schedule(0.5, LoadSummonsData);
        return;
    }

    var summons = GAME_META.summons;

    for (var key in summons) {
        var unitName = summons[key];
        var displayName = "#" + key + " " + $.Localize("#" + unitName);

        var item = $.CreatePanel("Button", summonsList, unitName);
        item.AddClass("listItem");
        item.SetPanelEvent("onactivate", (function(name) {
            return function() { onSelectSummon(name); };
        })(unitName));

        var label = $.CreatePanel("Label", item, "");
        label.AddClass("listItemName");
        label.text = displayName;
    }
}

// Load the wave data
function LoadWavesData() {
    var wavesList = $("#wavesList");

    // Clear the old data
    wavesList.RemoveAndDeleteChildren();

    // Pull the wave data from GAME_META
    if (typeof GAME_META === "undefined" || !GAME_META.waves) {
        $.Msg("[WikiPro] GAME_META waves not loaded yet, retrying...");
        $.Schedule(0.5, LoadWavesData);
        return;
    }

    var waves = GAME_META.waves;

    for (var waveNum in waves) {
        var wave = waves[waveNum];
        var unitName = wave.unit;
        // Same format as summons: #index unit name
        var displayName = "#" + waveNum + " " + $.Localize("#" + unitName);

        var item = $.CreatePanel("Button", wavesList, "wave_" + waveNum);
        item.AddClass("listItem");
        item.SetPanelEvent("onactivate", (function(num) {
            return function() { onSelectWave(num); };
        })(waveNum));

        var label = $.CreatePanel("Label", item, "");
        label.AddClass("listItemName");
        label.text = displayName;
    }
}

// Load the builder data
function LoadBuildersData() {
    var buildersList = $("#buildersList");

    // Clear the old data
    buildersList.RemoveAndDeleteChildren();

    // Pull the builder data from GAME_META
    if (typeof GAME_META === "undefined" || !GAME_META.builders) {
        $.Msg("[WikiPro] GAME_META builders not loaded yet, retrying...");
        $.Schedule(0.5, LoadBuildersData);
        return;
    }

    var builders = GAME_META.builders;

    for (var i = 0; i < builders.length; i++) {
        var builder = builders[i];
        var heroName = builder.name;

        // Display name: #index hero name
        var displayName = "#" + (i + 1) + " " + $.Localize("#" + heroName);

        var item = $.CreatePanel("Button", buildersList, "builder_" + i);
        item.AddClass("listItem");
        item.AddClass("builderItem");
        item.SetPanelEvent("onactivate", (function(idx) {
            return function() { onSelectBuilder(idx); };
        })(i));

        var icon = $.CreatePanel("DOTAHeroImage", item, "");
        icon.AddClass("builderIcon");
        icon.heroname = heroName;

        var label = $.CreatePanel("Label", item, "");
        label.AddClass("listItemName");
        label.text = displayName;
    }
}

// Load the King data
function LoadKingData() {
    // King data is loaded on demand per category
    selectKingCategory("upgrades");
}

// Load the command data
function LoadCommandsData() {
    // Command data is loaded on demand per category
    selectCommandCategory("general");

    // The whitelist button only shows in tools mode
    var whitelistBtn = $("#cmdWhitelist");
    if (whitelistBtn) {
        if (Game.IsInToolsMode()) {
            whitelistBtn.RemoveClass("Hidden");
        } else {
            whitelistBtn.AddClass("Hidden");
        }
    }
}

// Select a summoned unit
function onSelectSummon(unitName) {
    // Refresh the selection state
    UpdateListSelection("#summonsList", unitName);
    selectedItems.Summons = unitName;

    // Refresh the details panel
    UpdateSummonDetail(unitName);

    Game.EmitSound("ui_generic_button_click");
}

// Select a wave
function onSelectWave(waveNum) {
    var waveId = "wave_" + waveNum;
    UpdateListSelection("#wavesList", waveId);
    selectedItems.Waves = waveNum;

    UpdateWaveDetail(waveNum);

    Game.EmitSound("ui_generic_button_click");
}

// Select a builder
function onSelectBuilder(builderIndex) {
    UpdateListSelection("#buildersList", "builder_" + builderIndex);
    selectedItems.Builders = builderIndex;

    UpdateBuilderDetail(builderIndex);

    Game.EmitSound("ui_generic_button_click");
}

// Select a King category
function selectKingCategory(category) {
    // Refresh the selection state
    var categories = ["upgrades", "innate", "abilities"];
    for (var i = 0; i < categories.length; i++) {
        var btn = $("#king" + categories[i].charAt(0).toUpperCase() + categories[i].slice(1));
        if (categories[i] === category) {
            btn.AddClass("active");
        } else {
            btn.RemoveClass("active");
        }
    }

    selectedItems.King = category;
    UpdateKingDetail(category);

    Game.EmitSound("ui_generic_button_click");
}

// Select a command category
function selectCommandCategory(category) {
    // Outside tools mode, whitelist falls back to general
    if (category === "whitelist" && !Game.IsInToolsMode()) {
        category = "general";
    }

    // Refresh the selection state
    var categories = ["general", "cheats", "whitelist"];
    var btnMap = {
        "general": "cmdGeneral",
        "cheats": "cmdCheats",
        "whitelist": "cmdWhitelist"
    };

    for (var i = 0; i < categories.length; i++) {
        var btn = $("#" + btnMap[categories[i]]);
        if (btn && !btn.BHasClass("Hidden")) {
            if (categories[i] === category) {
                btn.AddClass("active");
            } else {
                btn.RemoveClass("active");
            }
        }
    }

    selectedItems.Commands = category;
    UpdateCommandsDetail(category);

    Game.EmitSound("ui_generic_button_click");
}

// Refresh the list selection
function UpdateListSelection(listId, selectedId) {
    var list = $(listId);
    var children = list.Children();

    for (var i = 0; i < children.length; i++) {
        if (children[i].id === selectedId) {
            children[i].AddClass("active");
        } else {
            children[i].RemoveClass("active");
        }
    }
}

// Refresh the summoned unit details
function UpdateSummonDetail(unitName) {
    if (!GAME_META || !GAME_META.units || !GAME_META.abilities) {
        $.Msg("[WikiPro] GAME_META not ready");
        return;
    }

    var unitKv = GAME_META.units[unitName];
    var abilityName = "buy_" + unitName;
    var abilityKv = GAME_META.abilities[abilityName];

    if (!unitKv) {
        $.Msg("[WikiPro] Unit data not found for: " + unitName);
        return;
    }

    // Find the summon index
    var summonNumber = "";
    for (var key in GAME_META.summons) {
        if (GAME_META.summons[key] === unitName) {
            summonNumber = key;
            break;
        }
    }

    // Update the unit name
    $("#summonNameTitle").text = "#" + summonNumber + " " + $.Localize("#" + unitName);

    $.Msg("unitKv")
    $.Msg(unitKv)
    // Update health and mana
    $("#summonHealthValue").text = unitKv.StatusHealth || "0";
    $("#summonHealthRegen").text = "+" + (unitKv.StatusHealthRegen || "0");

    $("#summonManaValue").text = unitKv.StatusMana || "0";
    $("#summonManaRegen").text = "+" + (unitKv.StatusManaRegen || "0");

    // Update the 3D model
    var scene = $("#summonScene");
    scene.SetUnit(unitName, "default_camera", false);

    // Update the attributes
    var attrPanel = $("#summonAttributes");
    attrPanel.RemoveAndDeleteChildren();

    // Show the attributes in priority order

    // 1. Attack attributes
    var damage = unitKv.AttackDamageMin + "-" + unitKv.AttackDamageMax;
    CreateAttributeRow(attrPanel, $.Localize("#ui_attack_damage"), damage);
    CreateAttributeRow(attrPanel, $.Localize("#ui_attack_speed"), unitKv.BaseAttackTime || "1.0");
    CreateAttributeRow(attrPanel, $.Localize("#ui_attack_range"), unitKv.AttackRange || "100");

    // 2. Defence attributes
    CreateAttributeRow(attrPanel, $.Localize("#ui_armor"), unitKv.ArmorPhysical || "0");

    // 3. Attack and armour types
    if (unitKv.AttackType) {
        var attackTypeName = $.Localize("#" + unitKv.AttackType);
        CreateAttributeRowWithIcon(attrPanel, $.Localize("#ui_attack_type"), attackTypeName, unitKv.AttackType);
    }
    if (unitKv.ArmorType) {
        var armorTypeName = $.Localize("#" + unitKv.ArmorType);
        CreateAttributeRowWithIcon(attrPanel, $.Localize("#ui_armor_type"), armorTypeName, unitKv.ArmorType);
    }

    // 4. Other attributes
    CreateAttributeRow(attrPanel, $.Localize("#ui_move_speed"), unitKv.MovementSpeed || "300");
    var bounty = Math.floor((parseInt(unitKv.BountyGoldMin || 0) + parseInt(unitKv.BountyGoldMax || 0)) / 2);
    CreateAttributeRow(attrPanel, $.Localize("#ui_bounty"), bounty.toString());

    // 5. Summon-only attributes (cost and requirements), last
    $.Msg("[WikiPro] abilityKv for " + abilityName + ":");
    $.Msg(abilityKv);

    if (abilityKv) {
        var summonData = abilityKv.Summon || abilityKv.AbilitySpecial;

        if (summonData) {
            $.Msg("[WikiPro] Summon data found:");
            $.Msg(summonData);

            var wood = summonData.wood ||
                       (summonData["01"] && summonData["01"].wood) ||
                       (summonData["02"] && summonData["02"].wood) || "0";
            var income = summonData.income ||
                        (summonData["01"] && summonData["01"].income) ||
                        (summonData["02"] && summonData["02"].income) || "0";
            var needRound = summonData.need_round ||
                           (summonData["01"] && summonData["01"].need_round) ||
                           (summonData["03"] && summonData["03"].need_round) || "1";

            CreateAttributeRow(attrPanel, $.Localize("#ui_lumber_cost") || "Wood", wood);
            CreateAttributeRow(attrPanel, $.Localize("#ui_income") || "Income", income);
            CreateAttributeRow(attrPanel, $.Localize("#ui_round") || "Round", needRound);

        } else {
            $.Msg("[WikiPro] No Summon data found in ability");
        }
    } else {
        $.Msg("[WikiPro] No ability data found for " + abilityName);
    }

    // Update the abilities
    var abilitiesPanel = $("#summonAbilities");
    abilitiesPanel.RemoveAndDeleteChildren();

    var abilitiesSection = abilitiesPanel.GetParent();
    var hasAbilities = false;

    if (unitKv.abilities) {
        for (var abilityKey in unitKv.abilities) {
            var ability = unitKv.abilities[abilityKey];
            if (ability && ability !== "0") {
                CreateAbilityDisplay(abilitiesPanel, ability);
                hasAbilities = true;
            }
        }
    }

    // Hide the whole ability panel when there are none
    if (!hasAbilities) {
        abilitiesSection.AddClass("Hidden");
    } else {
        abilitiesSection.RemoveClass("Hidden");
    }
}

// Refresh the wave details
function UpdateWaveDetail(waveNum) {
    if (!GAME_META || !GAME_META.waves || !GAME_META.units) {
        $.Msg("[WikiPro] GAME_META not ready for waves");
        return;
    }

    var wave = GAME_META.waves[waveNum];
    if (!wave) {
        $.Msg("[WikiPro] Wave data not found for: " + waveNum);
        return;
    }

    var unitName = wave.unit;
    var unitKv = GAME_META.units[unitName];

    if (!unitKv) {
        $.Msg("[WikiPro] Unit data not found for wave unit: " + unitName);
        return;
    }

    // Update the wave name
    $("#waveNameTitle").text = "Wave " + waveNum + " - " + $.Localize("#" + unitName);

    // Update health and mana
    $("#waveHealthValue").text = unitKv.StatusHealth || "0";
    $("#waveHealthRegen").text = "+" + (unitKv.StatusHealthRegen || "0");

    $("#waveManaValue").text = unitKv.StatusMana || "0";
    $("#waveManaRegen").text = "+" + (unitKv.StatusManaRegen || "0");

    // Update the 3D model
    var scene = $("#waveScene");
    scene.SetUnit(unitName, "default_camera", true);

    // Update the attributes
    var attrPanel = $("#waveAttributes");
    attrPanel.RemoveAndDeleteChildren();

    // Show the attributes in the same priority order as summons

    // 1. Attack attributes
    var damage = unitKv.AttackDamageMin + "-" + unitKv.AttackDamageMax;
    CreateAttributeRow(attrPanel, $.Localize("#ui_attack_damage"), damage);
    CreateAttributeRow(attrPanel, $.Localize("#ui_attack_speed"), unitKv.BaseAttackTime || "1.0");
    CreateAttributeRow(attrPanel, $.Localize("#ui_attack_range"), unitKv.AttackRange || "100");

    // 2. Defence attributes
    CreateAttributeRow(attrPanel, $.Localize("#ui_armor"), unitKv.ArmorPhysical || "0");

    // 3. Attack and armour types
    if (unitKv.AttackType) {
        var attackTypeName = $.Localize("#" + unitKv.AttackType);
        CreateAttributeRowWithIcon(attrPanel, $.Localize("#ui_attack_type"), attackTypeName, unitKv.AttackType);
    }
    if (unitKv.ArmorType) {
        var armorTypeName = $.Localize("#" + unitKv.ArmorType);
        CreateAttributeRowWithIcon(attrPanel, $.Localize("#ui_armor_type"), armorTypeName, unitKv.ArmorType);
    }

    // 4. Other attributes
    CreateAttributeRow(attrPanel, $.Localize("#ui_move_speed"), unitKv.MovementSpeed || "300");
    var bounty = Math.floor((parseInt(unitKv.BountyGoldMin || 0) + parseInt(unitKv.BountyGoldMax || 0)) / 2);
    CreateAttributeRow(attrPanel, $.Localize("#ui_bounty"), bounty.toString());

    // 5. Wave-only attributes (round count and total gold), last
    CreateAttributeRow(attrPanel, $.Localize("#ui_wave_count"), wave.count || "0");
    var waveGold = bounty * parseInt(wave.count || 0);
    CreateAttributeRow(attrPanel, $.Localize("#ui_wave_gold"), waveGold.toString());

    // Update the abilities
    var abilitiesPanel = $("#waveAbilities");
    abilitiesPanel.RemoveAndDeleteChildren();

    var abilitiesSection = abilitiesPanel.GetParent();
    var hasAbilities = false;

    if (unitKv.abilities) {
        for (var abilityKey in unitKv.abilities) {
            var ability = unitKv.abilities[abilityKey];
            if (ability && ability !== "0") {
                CreateAbilityDisplay(abilitiesPanel, ability);
                hasAbilities = true;
            }
        }
    }

    // Hide the whole ability panel when there are none
    if (!hasAbilities) {
        abilitiesSection.AddClass("Hidden");
    } else {
        abilitiesSection.RemoveClass("Hidden");
    }
}

// Index of the selected builder
var currentBuilderIndex = -1;

// Refresh the builder details
function UpdateBuilderDetail(builderIndex) {
    if (!GAME_META || !GAME_META.builders || !GAME_META.builders[builderIndex]) {
        $.Msg("[WikiPro] Builder data not found for index: " + builderIndex);
        return;
    }

    currentBuilderIndex = builderIndex;
    var builderData = GAME_META.builders[builderIndex];

    // Clear and rebuild the fighter list
    var fightersList = $("#builderFightersList");
    fightersList.RemoveAndDeleteChildren();

    // Show the fighter list
    if (builderData.fighters && builderData.fighters.length > 0) {
        for (var i = 0; i < builderData.fighters.length; i++) {
            var unitName = builderData.fighters[i];
            var displayName = "#" + (i + 1) + " " + $.Localize("#" + unitName);

            var item = $.CreatePanel("Button", fightersList, unitName);
            item.AddClass("listItem");
            item.SetPanelEvent("onactivate", (function(name) {
                return function() { onSelectBuilderUnit(name); };
            })(unitName));

            var label = $.CreatePanel("Label", item, "");
            label.AddClass("listItemName");
            label.text = displayName;
        }

        // Select the first unit by default
        var firstUnit = fightersList.GetChild(0);
        firstUnit.AddClass("active");
        onSelectBuilderUnit(builderData.fighters[0]);
    } else {
        // With no fighters, clear the unit detail panel
        ClearBuilderUnitDetail();
    }
}

// Select a builder unit
function onSelectBuilderUnit(unitName) {
    // Refresh the selection state
    UpdateListSelection("#builderFightersList", unitName);

    // Refresh the unit details
    UpdateBuilderUnitDetail(unitName);

    Game.EmitSound("ui_generic_button_click");
}

// Clear the builder unit details
function ClearBuilderUnitDetail() {
    // Clear the unit name
    $("#builderUnitNameTitle").text = "";

    // Clear health and mana
    $("#builderUnitHealthValue").text = "0";
    $("#builderUnitHealthRegen").text = "+0";
    $("#builderUnitManaValue").text = "0";
    $("#builderUnitManaRegen").text = "+0";

    // Clear the 3D model scene
    var scene = $("#builderUnitScene");
    if (scene) {
        scene.SetUnit("", "", false);
    }

    // Clear the attribute panel
    var attrPanel = $("#builderUnitAttributes");
    if (attrPanel) {
        attrPanel.RemoveAndDeleteChildren();
    }

    // Clear the ability panel and hide the section
    var abilitiesPanel = $("#builderUnitAbilities");
    if (abilitiesPanel) {
        abilitiesPanel.RemoveAndDeleteChildren();
        var abilitiesSection = abilitiesPanel.GetParent();
        if (abilitiesSection) {
            abilitiesSection.AddClass("Hidden");
        }
    }
}

// Refresh the builder unit details
function UpdateBuilderUnitDetail(unitName) {
    if (!GAME_META || !GAME_META.units) {
        $.Msg("[WikiPro] GAME_META units not ready");
        return;
    }

    var unitKv = GAME_META.units[unitName];
    if (!unitKv) {
        $.Msg("[WikiPro] Unit data not found for: " + unitName);
        return;
    }

    // Update the unit name
    $("#builderUnitNameTitle").text = $.Localize("#" + unitName);

    // Update health and mana
    $("#builderUnitHealthValue").text = unitKv.StatusHealth || "0";
    $("#builderUnitHealthRegen").text = "+" + (unitKv.StatusHealthRegen || "0");
    $("#builderUnitManaValue").text = unitKv.StatusMana || "0";
    $("#builderUnitManaRegen").text = "+" + (unitKv.StatusManaRegen || "0");

    // Update the 3D model
    var scene = $("#builderUnitScene");
    scene.SetUnit(unitName, "default_camera", false);

    // Update the attributes, same order as summons
    var attrPanel = $("#builderUnitAttributes");
    attrPanel.RemoveAndDeleteChildren();

    // 1. Attack attributes
    var damage = unitKv.AttackDamageMin + "-" + unitKv.AttackDamageMax;
    CreateAttributeRow(attrPanel, $.Localize("#ui_attack_damage"), damage);
    CreateAttributeRow(attrPanel, $.Localize("#ui_attack_speed"), unitKv.BaseAttackTime || "1.0");
    CreateAttributeRow(attrPanel, $.Localize("#ui_attack_range"), unitKv.AttackRange || "100");

    // 2. Defence attributes
    CreateAttributeRow(attrPanel, $.Localize("#ui_armor"), unitKv.ArmorPhysical || "0");

    // 3. Attack and armour types
    if (unitKv.AttackType) {
        var attackTypeName = $.Localize("#" + unitKv.AttackType);
        CreateAttributeRowWithIcon(attrPanel, $.Localize("#ui_attack_type"), attackTypeName, unitKv.AttackType);
    }
    if (unitKv.ArmorType) {
        var armorTypeName = $.Localize("#" + unitKv.ArmorType);
        CreateAttributeRowWithIcon(attrPanel, $.Localize("#ui_armor_type"), armorTypeName, unitKv.ArmorType);
    }

    // 4. Other attributes
    CreateAttributeRow(attrPanel, $.Localize("#ui_move_speed"), unitKv.MovementSpeed || "300");
    var bounty = Math.floor((parseInt(unitKv.BountyGoldMin || 0) + parseInt(unitKv.BountyGoldMax || 0)) / 2);
    CreateAttributeRow(attrPanel, $.Localize("#ui_bounty"), bounty.toString());

    // Update the abilities
    var abilitiesPanel = $("#builderUnitAbilities");
    abilitiesPanel.RemoveAndDeleteChildren();

    var abilitiesSection = abilitiesPanel.GetParent();
    var hasAbilities = false;

    if (unitKv.abilities) {
        for (var abilityKey in unitKv.abilities) {
            var ability = unitKv.abilities[abilityKey];
            if (ability && ability !== "0") {
                CreateAbilityDisplay(abilitiesPanel, ability);
                hasAbilities = true;
            }
        }
    }

    // Show or hide the ability section
    if (!hasAbilities) {
        abilitiesSection.AddClass("Hidden");
    } else {
        abilitiesSection.RemoveClass("Hidden");
    }
}


// Refresh the King details
function UpdateKingDetail(category) {
    var titleMap = {
        "upgrades": "#ui_upgrades",
        "innate": "#ui_innate",
        "abilities": "#ui_abilities"
    };

    $("#kingCategoryTitle").text = $.Localize(titleMap[category]);

    var abilitiesList = $("#kingAbilitiesList");
    // Clear the old data
    abilitiesList.RemoveAndDeleteChildren();

    // Pull the King ability data from GAME_META
    if (!GAME_META || !GAME_META.king) {
        $.Msg("[WikiPro] GAME_META king data not loaded yet");
        return;
    }

    var kingData = GAME_META.king[category];
    if (!kingData) {
        $.Msg("[WikiPro] King category data not found: " + category);
        return;
    }

    // Walk and render the abilities
    for (var key in kingData) {
        var abilityName = kingData[key];
        CreateKingAbilityDisplay(abilitiesList, abilityName, category);
    }
}

// Build one King ability entry
function CreateKingAbilityDisplay(parent, abilityName, category) {
    var container = $.CreatePanel("Panel", parent, "");
    container.AddClass("kingAbilityItem");

    // Ability icon
    var icon = $.CreatePanel("DOTAAbilityImage", container, "");
    icon.AddClass("kingAbilityIcon");
    icon.abilityname = abilityName;
    icon.SetPanelEvent("onmouseover", function() {
        $.DispatchEvent("DOTAShowAbilityTooltip", icon, abilityName);
    });
    icon.SetPanelEvent("onmouseout", function() {
        $.DispatchEvent("DOTAHideAbilityTooltip", icon);
    });

    // Ability name label
    var nameLabel = $.CreatePanel("Label", container, "");
    nameLabel.AddClass("kingAbilityName");
    nameLabel.text = $.Localize("#DOTA_Tooltip_ability_" + abilityName);
}

// Refresh the command details
function UpdateCommandsDetail(category) {
    var titleMap = {
        "general": "#ui_general_commands",
        "cheats": "#ui_cheatcodes",
        "whitelist": "#ui_whitelist_commands"
    };

    $("#commandsCategoryTitle").text = $.Localize(titleMap[category]);

    var commandsList = $("#commandsList");
    // Clear the old data
    commandsList.RemoveAndDeleteChildren();

    // Command categories mirror the refactored cmd.lua
    var commands = {
        "general": [
            { cmd: "-info <wave>", desc: "View specified wave information" },
            { cmd: "-next", desc: "View next wave information" },
            { cmd: "-air", desc: "View all flying unit waves" },
            { cmd: "-range", desc: "View all ranged unit waves" },
            { cmd: "-boss", desc: "View all BOSS waves" },
            { cmd: "-normal/-pierce/-siege/-magic/-chaos/-hero", desc: "View specific attack type waves" },
            { cmd: "-light/-medium/-heavy/-fortified/-unarmored/-hero", desc: "View specific armor type waves" },

            { cmd: "-help", desc: "Display help information" },
            { cmd: "-tp", desc: "Teleport function" },
            { cmd: "-king", desc: "Control king unit" },
            { cmd: "-zoom <50-450>", desc: "Adjust camera zoom" },

            { cmd: "-kick <playerID>", desc: "Kick player (requires team approval)" },
            { cmd: "-votekick <playerID>", desc: "Initiate vote kick" },

            { cmd: "-debug", desc: "Enable debug mode (single or cheat mode)" },
            { cmd: "-debug <0/1>", desc: "Toggle debug mode" }
        ],
        "cheats": [
            { cmd: "-gold <amount>", desc: "Set gold amount" },
            { cmd: "-lumber <amount>", desc: "Set lumber amount" },
            { cmd: "-food <amount>", desc: "Set food limit" },
            { cmd: "-income <amount>", desc: "Set income" },

            { cmd: "-fast <0/1>", desc: "Toggle fast round mode" },
            { cmd: "-start", desc: "Start immediately (pre-round state)" },
            { cmd: "-pause / -p", desc: "Pause round" },
            { cmd: "-resume", desc: "Resume round" },
            { cmd: "-round <number>", desc: "Jump to specified round" },
            { cmd: "-duel <1/2/3>", desc: "Jump to duel round (11/22/33)" },

            { cmd: "-clear / -c", desc: "Clear all enemies" },
            { cmd: "-clearw", desc: "Clear west enemies" },
            { cmd: "-cleare", desc: "Clear east enemies" },
            { cmd: "-heal", desc: "Heal all kings" },
            { cmd: "-healw", desc: "Heal west king" },
            { cmd: "-heale", desc: "Heal east king" },

            { cmd: "-buildall", desc: "Build in other players' areas" },
            { cmd: "-builder [playerID]", desc: "Reselect builder" },
            { cmd: "-repick", desc: "Repick builder" },
            { cmd: "-whosyourdaddy", desc: "Invincible mode" },
            { cmd: "-whosyourdaddy <0/1>", desc: "Set invincible mode" },
            { cmd: "-kingmax", desc: "Max level and stats for king" },
            { cmd: "-westwin", desc: "West team victory" },
            { cmd: "-eastwin", desc: "East team victory" },
            { cmd: "-abil <1-4>", desc: "Add ability to king" }
        ],
        "whitelist": [
            { cmd: "-send_self", desc: "Toggle send to self mode" },
            { cmd: "-send_free", desc: "Toggle free send mode" },
            { cmd: "-send <unit>", desc: "Send specified unit" },

            { cmd: "-fight_test <character>", desc: "Combat test preset" },
            { cmd: "-greedisgood <gold> <lumber> <food>", desc: "Add resources" },
            { cmd: "-forcekick <playerID>", desc: "Force kick player" },
            { cmd: "-killcreep", desc: "Kill all sent creeps" },
            { cmd: "-abandon <playerID>", desc: "Force player abandon" },

            { cmd: "-gohome [all/playerID]", desc: "Teleport hero home" },
            { cmd: "-add <all/playerID> <unit> [count]", desc: "Add unit to specified player" },
            { cmd: "-ptest", desc: "Random unit test" },
            { cmd: "-ptest2", desc: "Race unit test" },
            { cmd: "-pclear", desc: "Clear all towers" },

            { cmd: "-r", desc: "Reload scripts" },
            { cmd: "-rkv", desc: "Reload KV files" },
            { cmd: "-playerid", desc: "Display Steam ID" },
            { cmd: "-act <action>", desc: "Unit perform action" },
            { cmd: "-sound <effect>", desc: "Play sound effect" }
        ]
    };

    var cmdList = commands[category] || [];
    for (var i = 0; i < cmdList.length; i++) {
        CreateCommandItem(commandsList, cmdList[i].cmd, cmdList[i].desc);
    }
}

// Build one attribute row
function CreateAttributeRow(parent, label, value, fullWidth) {
    var row = $.CreatePanel("Panel", parent, "");
    row.AddClass("attributeRow");
    if (fullWidth) {
        row.AddClass("fullWidth");
    }

    var labelPanel = $.CreatePanel("Panel", row, "");
    labelPanel.AddClass("attrLabel");

    var labelText = $.CreatePanel("Label", labelPanel, "");
    labelText.text = label;

    var valueText = $.CreatePanel("Label", row, "");
    valueText.AddClass("attrValue");
    valueText.text = value;
}

// Build an attribute row with an icon, used for attack and armour types
function CreateAttributeRowWithIcon(parent, label, value, abilityName) {
    var row = $.CreatePanel("Panel", parent, "");
    row.AddClass("attributeRow");

    var labelPanel = $.CreatePanel("Panel", row, "");
    labelPanel.AddClass("attrLabel");

    var labelText = $.CreatePanel("Label", labelPanel, "");
    labelText.text = label;

    var valuePanel = $.CreatePanel("Panel", row, "");
    valuePanel.AddClass("attrValue");
    valuePanel.style.flowChildren = "right";
    valuePanel.style.horizontalAlign = "right";

    // Icon only, no text
    var icon = $.CreatePanel("DOTAAbilityImage", valuePanel, "");
    icon.abilityname = abilityName;
    icon.style.width = "24px";
    icon.style.height = "24px";
    icon.style.verticalAlign = "middle";
    // The tooltip carries the full text
    icon.SetPanelEvent("onmouseover", function() {
        $.DispatchEvent("DOTAShowAbilityTooltip", icon, abilityName);
    });
    icon.SetPanelEvent("onmouseout", function() {
        $.DispatchEvent("DOTAHideAbilityTooltip", icon);
    });
}

// Build one ability entry
function CreateAbilityDisplay(parent, abilityName) {
    // Icon only
    var icon = $.CreatePanel("DOTAAbilityImage", parent, "");
    icon.AddClass("abilityIcon");
    icon.abilityname = abilityName;
    icon.SetPanelEvent("onmouseover", function() {
        $.DispatchEvent("DOTAShowAbilityTooltip", icon, abilityName);
    });
    icon.SetPanelEvent("onmouseout", function() {
        $.DispatchEvent("DOTAHideAbilityTooltip", icon);
    });
}

// Build one command entry
function CreateCommandItem(parent, command, description) {
    var item = $.CreatePanel("Panel", parent, "");
    item.AddClass("commandItem");

    var title = $.CreatePanel("Label", item, "");
    title.AddClass("commandTitle");
    title.text = command;

    var desc = $.CreatePanel("Label", item, "");
    desc.AddClass("commandDesc");
    desc.text = description;
}

// Select the first entry by default
function SelectFirstItems() {
    // Select the first summoned unit
    var summonsList = $("#summonsList");
    if (summonsList.GetChildCount() > 0) {
        var firstSummon = summonsList.GetChild(0);
        firstSummon.AddClass("active");
        if (GAME_META && GAME_META.summons) {
            var firstUnitName = GAME_META.summons["1"];
            if (firstUnitName) {
                onSelectSummon(firstUnitName);
            }
        }
    }

    // Select the first wave
    var wavesList = $("#wavesList");
    if (wavesList.GetChildCount() > 0) {
        var firstWave = wavesList.GetChild(0);
        firstWave.AddClass("active");
        onSelectWave("1");
    }

    // Select the first builder
    var buildersList = $("#buildersList");
    if (buildersList.GetChildCount() > 0) {
        var firstBuilder = buildersList.GetChild(0);
        firstBuilder.AddClass("active");
        selectedItems.Builders = 0;
        UpdateBuilderDetail(0);
    }
}

// Toggle the wiki pro panel
function ToggleWikiPro() {
    if (mainPanel) {
        mainPanel.ToggleClass("Hidden");
        if (!mainPanel.BHasClass("Hidden")) {
            // Initialise when the wiki pro panel opens
            InitWikiPro();
            Game.EmitSound("ui_topmenu_activate");
        } else {
            // Close the wiki pro panel
            Game.EmitSound("ui_generic_button_click");
        }
    }
}

// Handle the top button events
function OnTopButtonsEvent(data) {
    if (data && data.name === "wiki_pro") {
        ToggleWikiPro();
    }
}

// Initialisation
(function() {
    // Make sure the panel starts hidden
    if (mainPanel && !mainPanel.BHasClass("Hidden")) {
        mainPanel.AddClass("Hidden");
    }

    // Subscribe to events
    GameEvents.Subscribe("top_buttons", OnTopButtonsEvent);
})();
