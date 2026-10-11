var SoundText = $.GetContextPanel().FindChildInLayoutFile("SoundText");
var SoundList = $.GetContextPanel().FindChildInLayoutFile("SoundList");
var SoundText1 = $.GetContextPanel().FindChildInLayoutFile("SoundText1");
var ParticleType = $.GetContextPanel().FindChildInLayoutFile("ParticleType");

var ParticleText = $.GetContextPanel().FindChildInLayoutFile("ParticleText");
var ParticleText1 = $.GetContextPanel().FindChildInLayoutFile("ParticleText1");
var ParticleText2 = $.GetContextPanel().FindChildInLayoutFile("ParticleText2");
var ParticleTextColor = $.GetContextPanel().FindChildInLayoutFile("ParticleTextColor");

var ParticleColor = $.GetContextPanel().FindChildInLayoutFile("ParticleColor");

var ParticleList = $.GetContextPanel().FindChildInLayoutFile("ParticleList");
var particleTypeMap = {

}
var UnitSelectScene1 = $.GetContextPanel().FindChildInLayoutFile("UnitSelectScene1");
var UnitSelectScene2 = $.GetContextPanel().FindChildInLayoutFile("UnitSelectScene2");
var UnitSelectScene3 = $.GetContextPanel().FindChildInLayoutFile("UnitSelectScene3");

var SpawnUnitName1 = $.GetContextPanel().FindChildInLayoutFile("SpawnUnitName1");
var SpawnUnitName2 = $.GetContextPanel().FindChildInLayoutFile("SpawnUnitName2");
var SpawnUnitName3 = $.GetContextPanel().FindChildInLayoutFile("SpawnUnitName3");

var AbilitySelectName = $.GetContextPanel().FindChildInLayoutFile("AbilitySelectName");
var AbilitySelectImage = $.GetContextPanel().FindChildInLayoutFile("AbilitySelectImage");

var particlePage = 1

var UnitText = $.GetContextPanel().FindChildInLayoutFile("UnitText");
var UnitText2 = $.GetContextPanel().FindChildInLayoutFile("UnitText2");
var UnitList = $.GetContextPanel().FindChildInLayoutFile("UnitList");


var gUnitList = CustomNetTables.GetTableValue("dev", "units")
var defaultSpawnUnitSlots = {
    slot1: "wave_rock_golem_6",
    slot2: "wave_aoclyte_8",
    slot3: "wave_gaint_spider_19",
}
var spawnUnitName1 = defaultSpawnUnitSlots.slot1
var spawnUnitName2 = defaultSpawnUnitSlots.slot2
var spawnUnitName3 = defaultSpawnUnitSlots.slot3
var currentUnitSlot = 1 // unit slot currently being edited


var gAbilityList = CustomNetTables.GetTableValue("dev", "abilities")
var spawnAbilityName = CustomNetTables.GetTableValue("dev", "selectedAbility").abilityName


//$.Msg("spawnAbilityName", CustomNetTables.GetTableValue("dev", "selectedAbility"))


//ability picker
var AbilityText = $.GetContextPanel().FindChildInLayoutFile("AbilityText");
var AbilityText2 = $.GetContextPanel().FindChildInLayoutFile("AbilityText2");
var AbilityList = $.GetContextPanel().FindChildInLayoutFile("AbilityList");

function ApplySpawnUnitSlots(slots) {
    slots = slots || defaultSpawnUnitSlots

    spawnUnitName1 = slots.slot1 || defaultSpawnUnitSlots.slot1
    spawnUnitName2 = slots.slot2 || defaultSpawnUnitSlots.slot2
    spawnUnitName3 = slots.slot3 || defaultSpawnUnitSlots.slot3

    UnitSelectScene1.SetUnit(spawnUnitName1, "default_camera", true);
    SpawnUnitName1.text = $.Localize('#' + spawnUnitName1)

    UnitSelectScene2.SetUnit(spawnUnitName2, "default_camera", true);
    SpawnUnitName2.text = $.Localize('#' + spawnUnitName2)

    UnitSelectScene3.SetUnit(spawnUnitName3, "default_camera", true);
    SpawnUnitName3.text = $.Localize('#' + spawnUnitName3)
}

CustomNetTables.SubscribeNetTableListener("dev", function(tableName, key, data) {
    $.Msg("refresh")
    if (key === "units") {
        gUnitList = CustomNetTables.GetTableValue("dev", "units")
        UpdateUnitPicker()
    } else if (key === "spawn_unit_slots") {
        ApplySpawnUnitSlots(data)
    }
})


function patternMatch(text, pattern) {
    const texts = pattern.trim().toLowerCase().split(" ")
    return matchStringArray(text, texts)
}
var gToolTipAbility = null

var ShowAbilityTooltip = (function(ability) {
    return function() {
        gToolTipAbility = ability
        if (ability.abilityname && ability.abilityname != "") {
            $.DispatchEvent("DOTAShowAbilityTooltip", ability, ability.abilityname);
        }
    }
});
var HideAbilityTooltip = (function(ability) {
    return function() {
        gToolTipAbility = null
        $.DispatchEvent("DOTAHideAbilityTooltip", ability);
        $.DispatchEvent("DOTAHideTextTooltip", ability);
        $.DispatchEvent("UIHideCustomLayoutTooltip", ability, "id1");
    }
});


function UpdateAbilityPicker() {

    AbilityList.RemoveAndDeleteChildren()

    var str = AbilityText.text

    var abilityNames = []

    for (const key in gAbilityList.abilities) {
        const name = gAbilityList.abilities[key]
        if (patternMatch(name, str) && name != "Version") {
            abilityNames.push(name)
        }
    }
    abilityNames.sort()



    for (const key in abilityNames) {
        const abilityName = abilityNames[key]

        var newLine = $.CreatePanel("Panel", AbilityList, "");
        newLine.BLoadLayoutSnippet("snippet_ability");
        newLine.SetDialogVariable("ability_name", $.Localize('#' + abilityName))
        const ability_image = newLine.FindChildInLayoutFile("ability_image");
        ability_image.abilityname = abilityName


        ability_image.SetPanelEvent("onmouseover", ShowAbilityTooltip(ability_image));
        ability_image.SetPanelEvent("onmouseout", HideAbilityTooltip(ability_image));


        newLine.SetPanelEvent("onactivate", function() {
            const nameLocal = $.Localize('#DOTA_Tooltip_ability_' + abilityName)
            spawnAbilityName = abilityName
                // UnitSelectScene.SetUnit(unitName, "default_camera", true);
            AbilitySelectImage.abilityname = abilityName
            AbilityText2.text = abilityName
            AbilitySelectName.text = nameLocal
            $.DispatchEvent('FireCustomGameEvent_Str', 'DemoSelectAbility', abilityName);


        });
    }



    spawnAbilityName = CustomNetTables.GetTableValue("dev", "selectedAbility").abilityName
    $.Msg(spawnAbilityName)
    const nameLocal = $.Localize('#DOTA_Tooltip_ability_' + spawnAbilityName)
    AbilitySelectName.text = nameLocal
    AbilitySelectImage.abilityname = spawnAbilityName
}

function UpdateUnitPicker() {
    $.Msg("UpdateUnitPicker")
    UnitList.RemoveAndDeleteChildren()

    var str = UnitText.text

    var unitNames = []

    for (const key in gUnitList.units) {
        const unitName = gUnitList.units[key]
        if (unitName != "Version" && patternMatch(unitName, str)) {
            unitNames.push(unitName)
        }
    }
    unitNames.sort()

    for (const key in unitNames) {
        const unitName = unitNames[key]

        var newLine = $.CreatePanel("Panel", UnitList, "");
        newLine.BLoadLayoutSnippet("snippet_unit");
        newLine.SetDialogVariable("unit_name", $.Localize('#' + unitName))

        const unitScene = newLine.FindChildInLayoutFile("unitScene");
        unitScene.SetUnit(unitName, "default_camera", true);
        newLine.SetPanelEvent("onactivate", function() {
            const nameLocal = $.Localize('#' + unitName)

            // Assign the unit that belongs to the current slot
            if (currentUnitSlot === 1) {
                spawnUnitName1 = unitName
                UnitSelectScene1.SetUnit(unitName, "default_camera", true);
                SpawnUnitName1.text = nameLocal
                $.DispatchEvent('FireCustomGameEvent_Str', 'DemoSelectSpawnUnit_1', unitName);
            } else if (currentUnitSlot === 2) {
                spawnUnitName2 = unitName
                UnitSelectScene2.SetUnit(unitName, "default_camera", true);
                SpawnUnitName2.text = nameLocal
                $.DispatchEvent('FireCustomGameEvent_Str', 'DemoSelectSpawnUnit_2', unitName);
            } else if (currentUnitSlot === 3) {
                spawnUnitName3 = unitName
                UnitSelectScene3.SetUnit(unitName, "default_camera", true);
                SpawnUnitName3.text = nameLocal
                $.DispatchEvent('FireCustomGameEvent_Str', 'DemoSelectSpawnUnit_3', unitName);
            }

            UnitText2.text = unitName
        });
    }

    // Initialise the unit scenes for all three slots
    UnitSelectScene1.SetUnit(spawnUnitName1, "default_camera", true);
    SpawnUnitName1.text = $.Localize('#' + spawnUnitName1)

    UnitSelectScene2.SetUnit(spawnUnitName2, "default_camera", true);
    SpawnUnitName2.text = $.Localize('#' + spawnUnitName2)

    UnitSelectScene3.SetUnit(spawnUnitName3, "default_camera", true);
    SpawnUnitName3.text = $.Localize('#' + spawnUnitName3)
}


function dumpStatusEffect() {
    var c = 0
    $.Msg("dumpStatusEffect")
    for (const key in particleList) {
        const particle = particleList[key]
        const name = particle.name.toLowerCase()
        if (particle.isStatusEffect) {
            $.Msg('"' + name + '",')
        }
    }
    $.Msg("dumpStatusEffect end")
}

function initParticlePicker() {

    ParticleType.RemoveAndDeleteChildren()

    const ks = {
        "isTracking": false,
        "isLinear": false,
        "isLink": false,
        "isExplode": false,
        "isWithHand": false,
        "isWithBody": false,
        "isContinue": true,
        "isWithHead": false,
        "isStatusEffect": false,
        "isLockBody": false,
        "isWithFeet": false,
        "isScalabel": false,
        "isSphere": false,
        "isWithWeapon": false,
    }
    for (const key in ks) {
        var newLine = $.CreatePanel("Panel", ParticleType, "");
        newLine.BLoadLayoutSnippet("snippet_particle_type");
        newLine.SetDialogVariable("particle_type", key)
        const btn = newLine.FindChildTraverse("particle_type_btn")
        btn.SetPanelEvent("onactivate", function() {
            particleTypeMap[key] = !particleTypeMap[key]
            UpdateParticle()
        });
    }
}

// Refresh the UI button state
function UpdateUIDefaults() {
    var UiDefaults = CustomNetTables.GetTableValue("game_global", "ui_defaults");
    $.Msg("=== Traveler UiDefaults", UiDefaults);
    if (UiDefaults) {

        // Treat undefined as false
        var wtfEnabled = UiDefaults["WTFEnabled"] || 0;
        var spawnCreepsEnabled = UiDefaults["SpawnCreepsEnabled"] || 0;
        var towersEnabled = UiDefaults["TowersEnabled"] || 0;
        var attackArmorTypeDisabled = UiDefaults["AttackArmorTypeDisabled"] || false;
        var aiDisabled = UiDefaults["AIDisabled"] || false;

        $.Msg("=== Traveler, updating the button state ===");
        $.Msg("WTF mode: " + wtfEnabled);
        $.Msg("Spawn creeps: " + spawnCreepsEnabled);
        $.Msg("Towers enabled: " + towersEnabled);
        $.Msg("Attack/armor types disabled: " + attackArmorTypeDisabled);
        
        $.Msg("AI disabled: " + aiDisabled);

        $('#FreeSpellsButton').SetSelected(wtfEnabled);
        $('#AttackArmorTypeButton').SetSelected(!attackArmorTypeDisabled);
        $('#AIButton').SetSelected(!aiDisabled);

        $.Msg("=== button state updated ===");
    } else {
        $.Msg("[Warning] could not read the ui_defaults data!");
    }
}





// Watch CustomNetTables and keep the button state in sync
CustomNetTables.SubscribeNetTableListener("game_global", function(table_name, key, data) {
    if (key === "ui_defaults") {
        $.Msg("Traveler, the button state changed, syncing the UI...");
        UpdateUIDefaults();
    }
});

function Init() {
    var contextPanel = $.GetContextPanel();
    var parent = contextPanel.GetParent();
    var customRoot = parent.GetParent();
    var hudRoot = customRoot.GetParent().FindChild('HUDElements');
    var menuButtons = hudRoot.FindChild('MenuButtons');
    menuButtons.AddClass("HeroDemo");
    $.RegisterEventHandler('DOTAUIHeroPickerHeroSelected', $('#SelectHeroContainer'), SwitchToNewHero);
    $.RegisterEventHandler('DOTAUIHeroPickerHeroSelected', $('#SelectHeroContainer'), SwitchToNewHero);

    // Set the button state during initialisation
    UpdateUIDefaults();

    initParticlePicker()
    ApplySpawnUnitSlots(CustomNetTables.GetTableValue("dev", "spawn_unit_slots"))
    UpdateUnitPicker()
    UpdateAbilityPicker()
    $.DispatchEvent('FireCustomGameEvent_Str', 'RequestInitialSpawnHeroID', null);
}
Init();


var bHeroPickerVisible = false;
var bUnitPickerVisible = false;
var bAbilityPickerVisible = false;

var bSoundPickerVisible = false;
var bParticlePickerVisible = false;
var bUnitSceneVisible = false;


const soundTypeMap = {
    hero: true,
    core: true,
    music: true
}


//color compare
function deltaE(rgbA, rgbB) {
    let labA = rgb2lab(rgbA);
    let labB = rgb2lab(rgbB);
    let deltaL = labA[0] - labB[0];
    let deltaA = labA[1] - labB[1];
    let deltaB = labA[2] - labB[2];
    let c1 = Math.sqrt(labA[1] * labA[1] + labA[2] * labA[2]);
    let c2 = Math.sqrt(labB[1] * labB[1] + labB[2] * labB[2]);
    let deltaC = c1 - c2;
    let deltaH = deltaA * deltaA + deltaB * deltaB - deltaC * deltaC;
    deltaH = deltaH < 0 ? 0 : Math.sqrt(deltaH);
    let sc = 1.0 + 0.045 * c1;
    let sh = 1.0 + 0.015 * c1;
    let deltaLKlsl = deltaL / (1.0);
    let deltaCkcsc = deltaC / (sc);
    let deltaHkhsh = deltaH / (sh);
    let i = deltaLKlsl * deltaLKlsl + deltaCkcsc * deltaCkcsc + deltaHkhsh * deltaHkhsh;
    return i < 0 ? 0 : Math.sqrt(i);
}

function rgb2lab(rgb) {
    let r = rgb[0] / 255,
        g = rgb[1] / 255,
        b = rgb[2] / 255,
        x, y, z;
    r = (r > 0.04045) ? Math.pow((r + 0.055) / 1.055, 2.4) : r / 12.92;
    g = (g > 0.04045) ? Math.pow((g + 0.055) / 1.055, 2.4) : g / 12.92;
    b = (b > 0.04045) ? Math.pow((b + 0.055) / 1.055, 2.4) : b / 12.92;
    x = (r * 0.4124 + g * 0.3576 + b * 0.1805) / 0.95047;
    y = (r * 0.2126 + g * 0.7152 + b * 0.0722) / 1.00000;
    z = (r * 0.0193 + g * 0.1192 + b * 0.9505) / 1.08883;
    x = (x > 0.008856) ? Math.pow(x, 1 / 3) : (7.787 * x) + 16 / 116;
    y = (y > 0.008856) ? Math.pow(y, 1 / 3) : (7.787 * y) + 16 / 116;
    z = (z > 0.008856) ? Math.pow(z, 1 / 3) : (7.787 * z) + 16 / 116;
    return [(116 * y) - 16, 500 * (x - y), 200 * (y - z)]
}


function matchStringArray(s, strs) {
    for (const k in strs) {
        var mstr = strs[k]
        if (mstr[0] == '~') {
            if (s.indexOf(mstr.substring(1)) != -1) {
                return false
            }
        } else {
            if (s.indexOf(strs[k]) == -1) {
                return false
            }
        }

    }
    return true
}

function UpdateSound(p) {
    const texts = SoundText.text.trim().toLowerCase().split(" ")

    const res = []
    const maxCount = 1000
    for (const key in soundList) {
        const sound = soundList[key]
        const soundName = sound.sound.toLowerCase()
        if (soundTypeMap[sound.type] && matchStringArray(soundName, texts)) {
            res.push(sound)
            if (res.length >= maxCount) {
                break
            }
        }
    }
    SoundList.RemoveAndDeleteChildren()
    for (const k in res) {
        const sound = res[k]
        const soundName = sound.sound
        var newLine = $.CreatePanel("Panel", SoundList, "");
        newLine.BLoadLayoutSnippet("snippet_sound");
        newLine.SetDialogVariable("sound_name", sound.sound)
        newLine.SetPanelEvent("onactivate", function() {
            $.Msg(soundName)

            $.DispatchEvent('FireCustomGameEvent_Str', 'DemoEmitSound', soundName);
            SoundText1.text = soundName
        });
    }
}

function isMatchParticle(p) {
    for (const key in particleTypeMap) {
        if (particleTypeMap[key] && !p[key]) {
            return false
        }
    }
    return true
}

function matchColor(p) {

    var strs = ParticleColor.text.split(",")
    if (strs.length >= 4) {
        const rgb = [parseInt(strs[0]), parseInt(strs[1]), parseInt(strs[2])]
        return (deltaE(rgb, p.color)) < parseInt(strs[3])
    }
    return true
}


function UpdateParticle(p) {
    const texts = ParticleText.text.trim().toLowerCase().split(" ")
    const res = []
    const pageSize = 1000
    var page = parseInt(ParticleText2.text)
    if (isNaN(page)) {
        page = 1
    }
    var c = 0

    for (const key in particleList) {
        const particle = particleList[key]
        const soundName = particle.name.toLowerCase()
        if (isMatchParticle(particle) && matchStringArray(soundName, texts) && matchColor(particle)) {
            c = c + 1
            if (c > (page - 1) * pageSize) {
                res.push(particle)
                if (res.length >= pageSize) {
                    break
                }
            }
        }
    }
    ParticleList.RemoveAndDeleteChildren()
    for (const k in res) {
        const particle = res[k]
        const name = particle.name
        var newLine = $.CreatePanel("Panel", ParticleList, "");
        newLine.BLoadLayoutSnippet("snippet_particle");
        const shortName = name.substring(name.lastIndexOf("/"))
        newLine.SetDialogVariable("name", shortName)

        newLine.GetChild(1).style.backgroundColor = "#" + particle.colorHex

        newLine.SetPanelEvent("onactivate", function() {
            // $.Msg(JSON.stringify(particle))
            $.DispatchEvent('FireCustomGameEvent_Str', 'DemoParticle', JSON.stringify(particle));
            ParticleText1.text = name
            ParticleTextColor.text = particle.color[0] + "," + particle.color[1] + "," + particle.color[2] + ",10"
        });
    }
}

function ToggleSoundType(type) {
    soundTypeMap[type] = !soundTypeMap[type]
    $.Msg(soundTypeMap)
}

function ToggleHeroPicker(bMainHero) {
    Game.EmitSound("UI.Button.Pressed");

    $('#SelectHeroContainer').SetHasClass('PickMainHero', bMainHero);

    SetHeroPickerVisible(!bHeroPickerVisible);
}

function ToggleUnitPicker(slot) {
    Game.EmitSound("UI.Button.Pressed");
    currentUnitSlot = slot || 1; // remember the slot being edited
    $.Msg("Traveler, switching unit slot: " + currentUnitSlot);
    SetUnitPickerVisible(!bUnitPickerVisible)
}

function ToggleAbilitySelectPicker() {
    Game.EmitSound("UI.Button.Pressed");
    SetAbilityPickerVisible(!bAbilityPickerVisible)
}

function ToggleSwitchHeroPicker(bMainHero) {
    Game.EmitSound("UI.Button.Pressed");

    $('#SelectHeroContainer').SetHasClass('PickMainHero', bMainHero);

    SetHeroPickerVisible(!bHeroPickerVisible);
}

function ToggleSoundPicker(bMainHero) {
    Game.EmitSound("UI.Button.Pressed");
    SetSoundPickerVisible(!bSoundPickerVisible);
}


function ToggleParticlePicker(bMainHero) {
    Game.EmitSound("UI.Button.Pressed");
    SetParticlePickerVisible(!bParticlePickerVisible);
}



function EscapeHeroPickerSearch() {
    //if ( $( "#SelectHeroContainer" ).FindChildTraverse( "HeroSearchTextEntry" ).BHasKeyFocus() )
    //{
    //	$( "#SelectHeroContainer" ).SetFocus();
    //}
    //else
    //{
    SetHeroPickerVisible(false);
    //}
}

function EscapeSoundPickerSearch() {
    //if ( $( "#SelectHeroContainer" ).FindChildTraverse( "HeroSearchTextEntry" ).BHasKeyFocus() )
    //{
    //	$( "#SelectHeroContainer" ).SetFocus();
    //}
    //else
    //{
    SetSoundPickerVisible(false);
    //}
}

function CloseHeroPicker() {
    SetHeroPickerVisible(false);
}

function CloseSoundPicker() {
    SetSoundPickerVisible(false);
}

function CloseParticlePicker() {
    SetParticlePickerVisible(false)
}

function CloseUnitPicker() {
    SetUnitPickerVisible(false)
}

function CloseAbilityPicker() {
    SetAbilityPickerVisible(false)
}

function CloseUnitScene() {
    SetUnitSceneVisible(false)
}


function SetSoundPickerVisible(bVisible) {
    if (!bVisible) {
        $('#SelectSoundContainer').RemoveClass('SoundPickerVisible');
        // $("#SelectSoundContainer").FindChildTraverse("HeroSearchTextEntry").text = "";
    }
    if (bVisible) {
        $('#SelectSoundContainer').AddClass('SoundPickerVisible');
        //$("#SelectSoundContainer").FindChildTraverse("HeroSearchTextEntry").SetFocus();
    }
    $.Msg(bSoundPickerVisible)
    bSoundPickerVisible = bVisible;
}


function SetParticlePickerVisible(bVisible) {
    if (!bVisible) {
        $('#SelectParticleContainer').RemoveClass('SoundPickerVisible');
        // $("#SelectSoundContainer").FindChildTraverse("HeroSearchTextEntry").text = "";
    }
    if (bVisible) {
        $('#SelectParticleContainer').AddClass('SoundPickerVisible');
        //$("#SelectSoundContainer").FindChildTraverse("HeroSearchTextEntry").SetFocus();
    }
    bParticlePickerVisible = bVisible;
}

function SetUnitSceneVisible(bVisible) {
    if (bUnitSceneVisible) {
        if (!bVisible) {
            $('#UnitSceneContainer').RemoveClass('SoundPickerVisible');
            // $("#SelectSoundContainer").FindChildTraverse("HeroSearchTextEntry").text = "";
        }
    } else {
        if (bVisible) {
            $('#UnitSceneContainer').AddClass('SoundPickerVisible');
            //$("#SelectSoundContainer").FindChildTraverse("HeroSearchTextEntry").SetFocus();
        }
    }
    bUnitSceneVisible = bVisible;
}

function SetHeroPickerVisible(bVisible) {
    if (bHeroPickerVisible) {
        if (!bVisible) {
            $('#SelectHeroContainer').RemoveClass('HeroPickerVisible');
            $("#SelectHeroContainer").FindChildTraverse("HeroSearchTextEntry").text = "";
        }
    } else {
        if (bVisible) {
            $('#SelectHeroContainer').AddClass('HeroPickerVisible');
            $("#SelectHeroContainer").FindChildTraverse("HeroSearchTextEntry").SetFocus();
        }
    }
    bHeroPickerVisible = bVisible;
}

function SetUnitPickerVisible(bVisible) {
    $.Msg(bVisible)
    if (!bVisible) {
        $('#SelectUnitContainer').RemoveClass('UnitPickerVisible');
        //$("#SelectUnitContainer").FindChildTraverse("HeroSearchTextEntry").text = "";
    }
    if (bVisible) {
        $('#SelectUnitContainer').AddClass('UnitPickerVisible');
        //$("#SelectUnitContainer").FindChildTraverse("HeroSearchTextEntry").SetFocus();
    }
    bUnitPickerVisible = bVisible;
}

function SetAbilityPickerVisible(bVisible) {
    if (!bVisible) {
        $('#SelectAbilityContainer').RemoveClass('AbilityPickerVisible');
        //$("#SelectUnitContainer").FindChildTraverse("HeroSearchTextEntry").text = "";
    }
    if (bVisible) {
        $('#SelectAbilityContainer').AddClass('AbilityPickerVisible');
        //$("#SelectUnitContainer").FindChildTraverse("HeroSearchTextEntry").SetFocus();
    }
    bAbilityPickerVisible = bVisible;
}

function SwitchToNewHero(nHeroID) {
    Game.EmitSound("UI.Button.Pressed");

    $.Msg('Hero = ' + nHeroID);

    if ($('#SelectHeroContainer').BHasClass('PickMainHero')) {
        $.DispatchEvent('FireCustomGameEvent_Str', 'SelectMainHeroButtonPressed', String(nHeroID));
    } else {
        $.DispatchEvent('FireCustomGameEvent_Str', 'SelectSpawnHeroButtonPressed', String(nHeroID));
    }

    $('#SelectHeroContainer').RemoveClass('PickMainHero');

    SetHeroPickerVisible(false);
}

function OnSetPlayerHeroID(event_data) {
    $.Msg("OnSetPlayerHeroID: ", event_data);

    var HeroDemoButton = $('#HeroDemoHeroName');
    if (HeroDemoButton != null) {
        var heroName = Players.GetPlayerSelectedHero(0);
        $.Msg('HERO NAME = ' + heroName);
        HeroDemoButton.SetDialogVariable("hero_name", $.Localize('#' + heroName));
    }
}
GameEvents.Subscribe("set_player_hero_id", OnSetPlayerHeroID);

function OnSetMainHeroID(event_data) {
    $.Msg("OnSetMainHeroID: ", event_data);

    $.DispatchEvent("DOTADemoHeroEquippedItems", event_data.hero_name);
}
GameEvents.Subscribe("set_main_hero_id", OnSetMainHeroID);

function OnSetSpawnHeroID(event_data) {
    $.Msg("OnSetSpawnHeroID: ", event_data);
    var HeroPickerImage = $('#HeroPickerImage');
    if (HeroPickerImage != null) {
        HeroPickerImage.heroid = event_data.hero_id;
    }

    var SpawnHeroButton = $('#SpawnHeroButton');
    if (SpawnHeroButton != null) {
        $.Msg('HERO NAME = ' + event_data.hero_name);
        SpawnHeroButton.SetDialogVariable("hero_name", $.Localize('#' + event_data.hero_name));
    }
}
GameEvents.Subscribe("set_spawn_hero_id", OnSetSpawnHeroID);

function ToggleCategoryVisibility(str) {
    //$.Msg( "^^^ToggleCategoryVisibility() - " + str )
    $(str).ToggleClass('CollapseCategory')
}


function OnAddNewHeroEntry(event_data) {
    $.Msg("OnAddNewHeroEntry: ", event_data);

    // disabling experiment to add the spawned hero to your selection set
    //GameUI.SelectUnit( event_data.entindex, true );
}
GameEvents.Subscribe("add_new_hero_entry", OnAddNewHeroEntry);

function RemoveSelectedHeroes() {
    var entities = Players.GetSelectedEntities(Players.GetLocalPlayer());
    $.Msg("Entities = " + entities);

    var numEntities = Object.keys(entities).length;
    $.Msg("Num entities = " + numEntities);

    var bDeletionAttempted = false;
    for (var i = 0; i < numEntities; i++) {
        var entindex = entities[i];
        if (entindex == -1)
            continue;

        var PlayerOwnerID = Entities.GetPlayerOwnerID(entindex);
        var bIsRealHero = Entities.IsRealHero(entindex);
        if (PlayerOwnerID == 0 && bIsRealHero) {
            $.Msg('Skipping ent! ' + entindex);
            continue; // don't delete the player!
        }
        bDeletionAttempted = true;
        $.DispatchEvent('FireCustomGameEvent_Str', 'RemoveHeroButtonPressed', String(entindex));
    }

    if (bDeletionAttempted) {
        Game.EmitSound("UI.Button.Pressed");
    } else {
        Game.EmitSound("General.Cancel");
    }
}

function KillSelectedHeroes() {
    $.DispatchEvent('FireCustomGameEvent_Str', 'KillHeroButtonPressed', String(""));
}

function ToggleInvulnerability() {
    var entities = Players.GetSelectedEntities(Players.GetLocalPlayer());
    $.Msg("Entities = " + entities);

    var numEntities = Object.keys(entities).length;
    $.Msg("Num entities = " + numEntities);

    for (var i = 0; i < numEntities; i++) {
        var entindex = entities[i];
        if (entindex == -1)
            continue;

        $.DispatchEvent('FireCustomGameEvent_Str', 'ToggleInvulnerabilityHero', String(entindex));
    }
}

function InvulnerableOn() {
    var entities = Players.GetSelectedEntities(Players.GetLocalPlayer());
    $.Msg("Entities = " + entities);

    var numEntities = Object.keys(entities).length;
    $.Msg("Num entities = " + numEntities);

    for (var i = 0; i < numEntities; i++) {
        var entindex = entities[i];
        if (entindex == -1)
            continue;

        $.DispatchEvent('FireCustomGameEvent_Str', 'InvulnOnHero', String(entindex));
    }

    if (numEntities > 0) {
        Game.EmitSound("UI.Button.Pressed");
    }
}

function InvulnerableOff() {
    var entities = Players.GetSelectedEntities(Players.GetLocalPlayer());
    $.Msg("Entities = " + entities);

    var numEntities = Object.keys(entities).length;
    $.Msg("Num entities = " + numEntities);

    for (var i = 0; i < numEntities; i++) {
        var entindex = entities[i];
        if (entindex == -1)
            continue;

        $.DispatchEvent('FireCustomGameEvent_Str', 'InvulnOffHero', String(entindex));
    }

    if (numEntities > 0) {
        Game.EmitSound("UI.Button.Pressed");
    }
}

function LevelUpSelectedHeroes() {
    var entities = Players.GetSelectedEntities(Players.GetLocalPlayer());
    $.Msg("Entities = " + entities);

    var numEntities = Object.keys(entities).length;
    $.Msg("Num entities = " + numEntities);

    for (var i = 0; i < numEntities; i++) {
        var entindex = entities[i];
        if (entindex == -1)
            continue;
        $.DispatchEvent('FireCustomGameEvent_Str', 'LevelUpHero', String(entindex));
    }

    if (numEntities > 0) {
        Game.EmitSound("UI.Button.Pressed");
    }
}

function MaxLevelUpSelectedHeroes() {
    var entities = Players.GetSelectedEntities(Players.GetLocalPlayer());
    $.Msg("Entities = " + entities);

    var numEntities = Object.keys(entities).length;
    $.Msg("Num entities = " + numEntities);

    for (var i = 0; i < numEntities; i++) {
        var entindex = entities[i];
        if (entindex == -1)
            continue;

        $.DispatchEvent('FireCustomGameEvent_Str', 'MaxLevelUpHero', String(entindex));
    }

    if (numEntities > 0) {
        Game.EmitSound("UI.Button.Pressed");
    }
}

function ResetSelectedHeroes() {
    var entities = Players.GetSelectedEntities(Players.GetLocalPlayer());
    $.Msg("Entities = " + entities);

    var numEntities = Object.keys(entities).length;
    $.Msg("Num entities = " + numEntities);

    for (var i = 0; i < numEntities; i++) {
        var entindex = entities[i];
        if (entindex == -1)
            continue;
        $.DispatchEvent('FireCustomGameEvent_Str', 'ResetHero', String(entindex));
    }
    if (numEntities > 0) {
        Game.EmitSound("UI.Button.Pressed");
    }
}


function OpenUnitScene() {
    var entities = Players.GetSelectedEntities(Players.GetLocalPlayer());
    var numEntities = Object.keys(entities).length;
    var unitName = null
    for (var i = 0; i < numEntities; i++) {
        var entindex = entities[i];
        if (entindex == -1)
            continue;
        unitName = Entities.GetUnitName(entindex)
        break
    }

    const unitScene = $.GetContextPanel().FindChildInLayoutFile("unitSceneA");
    $.Msg(unitName, "default_camera", true)
    unitScene.SetUnit(unitName, "default_camera", true);

    // $("#RankScene").SetUnit(unitName, "default_camera", true);

    SetUnitSceneVisible(true)
}

function Clone_BUTTON() {
    var entities = Players.GetSelectedEntities(Players.GetLocalPlayer());
    $.Msg("Entities = " + entities);
    var numEntities = Object.keys(entities).length;
    $.Msg("Num entities = " + numEntities);
    for (var i = 0; i < numEntities; i++) {
        var entindex = entities[i];
        if (entindex == -1)
            continue;
        $.DispatchEvent('FireCustomGameEvent_Str', 'Clone_BUTTON', String(entindex));
    }
    if (numEntities > 0) {
        Game.EmitSound("UI.Button.Pressed");
    }
}

function ShardSelectedHeroes() {
    var entities = Players.GetSelectedEntities(Players.GetLocalPlayer());
    $.Msg("Entities = " + entities);

    var numEntities = Object.keys(entities).length;
    $.Msg("Num entities = " + numEntities);

    for (var i = 0; i < numEntities; i++) {
        var entindex = entities[i];
        if (entindex == -1)
            continue;

        $.DispatchEvent('FireCustomGameEvent_Str', 'ShardHero', String(entindex));
    }

    if (numEntities > 0) {
        Game.EmitSound("UI.Button.Pressed");
    }
}

function ScepterSelectedHeroes() {
    var entities = Players.GetSelectedEntities(Players.GetLocalPlayer());
    $.Msg("Entities = " + entities);

    var numEntities = Object.keys(entities).length;
    $.Msg("Num entities = " + numEntities);

    for (var i = 0; i < numEntities; i++) {
        var entindex = entities[i];
        if (entindex == -1)
            continue;

        $.DispatchEvent('FireCustomGameEvent_Str', 'ScepterHero', String(entindex));
    }

    if (numEntities > 0) {
        Game.EmitSound("UI.Button.Pressed");
    }
}

function ToggleHeroActive() {
    $.Msg('ToggleHeroActive()')
}

function MouseOverRune(strRuneID, strRuneTooltip) {
    var runePanel = $('#' + strRuneID);
    runePanel.StartAnimating();
    $.DispatchEvent('UIShowTextTooltip', runePanel, strRuneTooltip);
}

function MouseOutRune(strRuneID) {
    var runePanel = $('#' + strRuneID);
    runePanel.StopAnimating();
    $.DispatchEvent('UIHideTextTooltip', runePanel);
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

function dota_player_update_selected_unitCb(params) {

    // $.Msg(params)
    var entities = Players.GetSelectedEntities(Players.GetLocalPlayer());
    var numEntities = Object.keys(entities).length;

    if (numEntities > 0) {
        var entindex = entities[0];
        //
        $.DispatchEvent('FireCustomGameEvent_Str', 'SelectUnits', String(0));
        for (const key in entities) {
            $.DispatchEvent('FireCustomGameEvent_Str', 'SelectUnits', String(entities[key]));
        }
        //
    }
    if(Game.IsInToolsMode()){
        var selectedUnit = Players.GetLocalPlayerPortraitUnit()
        if (selectedUnit) {
           //  $.Msg('FireCustomGameEvent_Str', 'DemoSelectUnit',String(selectedUnit))


            $.DispatchEvent('FireCustomGameEvent_Str', 'DemoSelectUnit', String(selectedUnit));
            Game.EmitSound("UI.Button.Pressed");
        }
    }
}


GameEvents.Subscribe("dota_portrait_ability_layout_changed", dota_player_update_selected_unitCb);
GameEvents.Subscribe("dota_player_update_selected_unit", dota_player_update_selected_unitCb);
GameEvents.Subscribe("dota_player_update_query_unit", dota_player_update_selected_unitCb);
