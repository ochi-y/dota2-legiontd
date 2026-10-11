
var PlayerTables = GameUI.CustomUIConfig().PlayerTables;
let Util = GameUI.CustomUIConfig().Util;

let meta = null

let raceList = []



let mainPanel = $.GetContextPanel().FindChildInLayoutFile("skinRoot");
let playerInfo = null;
function onCloseBtn() {
    Game.EmitSound("ui_find_match_cancel");
    mainPanel.AddClass("Hidden");
}

function onApplySkin() {
    Game.EmitSound("ui_generic_button_click");
}

function updateStatusText(text) {
    const statusText = $("#skinStatusText");
    if (statusText) {
        statusText.text = $.Localize(text);
        statusText.RemoveClass("fadeIn");
        statusText.AddClass("fadeIn");
        $.Schedule(0.01, function() {
            statusText.RemoveClass("fadeIn");
        });
    }
}

function updateSelectedSkinName(skin) {
    const nameLabel = $("#selectedSkinName");
    if (nameLabel) {
        nameLabel.text = "Selected: " + $.Localize("#" + skin);
    }
}

let localSteamId = null

function calRaceList() {
    raceList = []
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
        // panel = $.CreatePanel(`DOTAScenePanel`, panelToAttach, panel_id_name, {
        //     camera: panelData.camera,
        //     particleonly: panelData.particleonly,
        //     map: panelData.map,
        //     antialias: panelData.antialias,
        //     light: panelData.light,
        // });
        panel = $.CreatePanel(`DOTAScenePanel`, panelToAttach, panel_id_name, panelData);
    } else if (type == "DOTAAvatarImage") {
        panel = $.CreatePanel(`DOTAAvatarImage`, panelToAttach, panel_id_name, {
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

let g_selectedRace = null
let g_selectedUnit = null
let g_selectedSkin = null


let racePanels = []
let unitPanels = []
let skinPanels = []


function renderRace(selectedRace) {
    const raceListPanel = $.GetContextPanel().FindChildInLayoutFile("raceList");
    if (g_selectedRace == null) {
        raceListPanel.RemoveAndDeleteChildren()
        racePanels = []
        for (const key in raceList) {
            let raceData = raceList[key]

            var node = null
            node = $.CreatePanel("Panel", raceListPanel, "");
            node.BLoadLayoutSnippet("snippet_raceBtn");
            node.SetDialogVariable("text_race", $.Localize("#ui_race_" + raceData.race))

            // Add animation delay
            node.style.animationDelay = `${key * 0.05}s`;

            let btn = node.FindChildTraverse("btn")
            btn.SetPanelEvent("onactivate", function () {
                Game.EmitSound("ui_generic_button_click")
                render(raceData.race, null, null)
            });


            btn.race = raceData.race
            racePanels.push(btn)
        }
    }
    for (const panel of racePanels) {
        if (panel.race == selectedRace) {
            panel.AddClass("selected")
        } else {
            panel.RemoveClass("selected")
        }
    }
}


function renderUnit(selectedRace, selectedUnit) {
    const unitListPanel = $.GetContextPanel().FindChildInLayoutFile("unitList");
    if (selectedRace != g_selectedRace) {
        unitListPanel.RemoveAndDeleteChildren()
        const raceData = raceList.find(function (v) {
            return v.race == selectedRace
        })
        let units = raceData.units
        units.sort(function (a,b) {
            if(a.unit<b.unit){
                return -1
            }
            if(a.unit>b.unit){
                return 1
            }
            return 0
        })
        unitPanels = []
        let delay = 0;
        for (const key in units) {
            let unitData = units[key]
            var node = null
            node = $.CreatePanel("Panel", unitListPanel, "");
            node.BLoadLayoutSnippet("snippet_unitBtn");
            node.SetDialogVariable("text_unit", $.Localize("#" + unitData.unit))

            // Add animation delay
            node.style.animationDelay = `${delay * 0.05}s`;
            delay++;

            let btn = node.FindChildTraverse("btn")
            btn.SetPanelEvent("onactivate", function () {
                Game.EmitSound("ui_generic_button_click")
                render(raceData.race, unitData.unit, null)
                updateStatusText(unitData.unit)
            });

            btn.unit = unitData.unit
            unitPanels.push(btn)
        }
    }
    for (const panel of unitPanels) {
        if (panel.unit == selectedUnit) {
            panel.AddClass("selected")
        } else {
            panel.RemoveClass("selected")
        }
    }
}
function renderSkin(selectedRace, selectedUnit, selectedSkin) {
    const skinListPanel = $.GetContextPanel().FindChildInLayoutFile("skinList");
    const raceData = raceList.find(function (v) {
        return v.race == selectedRace
    })
    const unitData = raceData.units.find(function (v) {
        return v.unit == selectedUnit
    })

    if (selectedUnit != g_selectedUnit) {
        skinListPanel.RemoveAndDeleteChildren()

        let unitVariants = unitData.skinList
        skinPanels = []
        let delay = 0;

        for (const key in unitVariants) {
            let skin = unitVariants[key]

            var node = null
            node = $.CreatePanel("Panel", skinListPanel, "");
            node.BLoadLayoutSnippet("snippet_skinBtn");

            // Add staggered animation
            node.style.animationDelay = `${delay * 0.08}s`;
            delay++;

            let btn = node.FindChildTraverse("btn")
            btn.SetPanelEvent("onactivate", function () {
                Game.EmitSound("ui_generic_button_click")
                render(raceData.race, unitData.unit, skin)
                updateSelectedSkinName(skin)
            });

            if (skin == selectedSkin) {
                btn.AddClass("selected")
            }
            btn.skin = skin
            skinPanels.push(btn)

            // Set skin name
            let skinDisplayName = skin == selectedUnit ? "Default" : $.Localize("#" + skin)
            node.SetDialogVariable("text_skin", skinDisplayName)

            // Set 3D model
            node.FindChildTraverse("smallUnitScene").SetUnit(skin, "default_camera", false)
        }
    }

    for (const panel of skinPanels) {
        if (panel.skin == selectedSkin) {
            panel.AddClass("selected")
        } else {
            panel.RemoveClass("selected")
        }
    }
}
function render(selectedRace, selectedUnit, selectedSkin) {
    const raceListPanel = $.GetContextPanel().FindChildInLayoutFile("raceList");
    const unitListPanel = $.GetContextPanel().FindChildInLayoutFile("unitList");
    const skinListPanel = $.GetContextPanel().FindChildInLayoutFile("skinList");

    // raceListPanel.RemoveAndDeleteChildren()
    // unitListPanel.RemoveAndDeleteChildren()

    // if (selectedUnit != g_selectedUnit) {
    //     skinListPanel.RemoveAndDeleteChildren()
    // }

    calRaceList()

    if (raceList.length == 0) {
        raceListPanel.RemoveAndDeleteChildren()
        unitListPanel.RemoveAndDeleteChildren()
        skinListPanel.RemoveAndDeleteChildren()
        return
    }

    if (!selectedRace) {
        selectedRace = raceList[0].race
    }

    const raceData = raceList.find(function (v) {
        return v.race == selectedRace
    })

    if (!selectedUnit) {
        selectedUnit = raceData.units[0].unit
    }
    const unitData = raceData.units.find(function (v) {
        return v.unit == selectedUnit
    })

    renderRace(selectedRace)
    renderUnit(selectedRace, selectedUnit)
    renderSkin(selectedRace, selectedUnit, selectedSkin)
    // bigUnitScene.SetUnit(selectedSkin, "default_camera", false)
    g_selectedRace = selectedRace
    g_selectedUnit = selectedUnit
    g_selectedSkin = selectedSkin
}

function loadData() {
    meta = GAME_META
    if (mainPanel) {
        mainPanel.AddClass("Hidden")
    }
    render(g_selectedRace, g_selectedUnit, g_selectedSkin)
}


function CreateErrorMessage(msg) {
    var reason = msg.reason || 80;
    if (msg.message) {
        GameEvents.SendEventClientSide("dota_hud_error_message", { "splitscreenplayer": 0, "reason": reason, "message": msg.message });
    } else {
        GameEvents.SendEventClientSide("dota_hud_error_message", { "splitscreenplayer": 0, "reason": reason });
    }
}

function top_buttons(data) {
    if (data && data.name && data.name == "skin") {
        mainPanel.AddClass("Hidden");
    }
}

function init() {
    playerInfo = Game.GetLocalPlayerInfo();
    if (!playerInfo) {
        $.Schedule(0.1, init);
        return
    }
}

(function () {
    const raceListPanel = $.GetContextPanel().FindChildInLayoutFile("raceList");
    const unitListPanel = $.GetContextPanel().FindChildInLayoutFile("unitList");
    const skinListPanel = $.GetContextPanel().FindChildInLayoutFile("skinList");
    raceListPanel.RemoveAndDeleteChildren()
    unitListPanel.RemoveAndDeleteChildren()
    skinListPanel.RemoveAndDeleteChildren()
    GameEvents.Subscribe("top_buttons", top_buttons)
    // GameEvents.Subscribe("show_profile", top_buttons)
    init()
})();
