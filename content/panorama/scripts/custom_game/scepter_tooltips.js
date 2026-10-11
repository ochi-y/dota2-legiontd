var alt = false;
var ab;
let unit;
const context = $.GetContextPanel()

function SetupTooltip() {

    ab = context.GetAttributeInt("ability", -1)

    unit = context.GetAttributeInt("unit", -1)


    // $.Msg("ab ",ab)
    // $.Msg("unit ",unit)

    if (ab == 0) {
        ab = context.GetAttributeString("ability", -1)
    }
    if (ab && ab != -1) {
         SetupUnit()
    }
}

function SetupUnit() {

    let name = Abilities.GetAbilityName(ab)

    let unitName=Entities.GetUnitName(unit)

    //$.Msg("SetupUnit",ab,name,unitName)
    $.GetContextPanel().RemoveAndDeleteChildren();
    let tooltip = $.CreatePanel("Panel", $.GetContextPanel(), "ScepterTooltip");
    tooltip.BLoadLayoutSnippet('ScepterTooltip');
    let Util = GameUI.CustomUIConfig().Util;
    let PlayerTables = GameUI.CustomUIConfig().PlayerTables;

    let unitKvs =GAME_META.units 

    
    let unitKv=unitKvs[unitName]

    if(unitKv&&unitKv.scepterAbility){
        let scepterAbility=unitKv.scepterAbility
        //$.Msg(scepterAbility)
        $("#abilityName").text=$.Localize("#DOTA_Tooltip_ability_" + scepterAbility)
        $("#abilityIcon").abilityname=scepterAbility

        let desc = $.Localize("#DOTA_Tooltip_ability_" + scepterAbility + "_Description")
        desc = GameUI.ReplaceDOTAAbilitySpecialValues(scepterAbility, desc);

        // $.Msg(desc)
        $("#abilityDesc").text=desc

        context.SetDialogVariable("round", 16)
        context.SetDialogVariable("level", 2)
        context.SetDialogVariable("gold_cost", unitKv.ultimateAbilityGoldCost || 0)
    }

    
}
function dota_ability_changed(t) {
    if (ab == t.entityIndex) {
        SetupTooltip()
    }
}

(function() {
    GameEvents.Subscribe('dota_ability_changed', dota_ability_changed)
})()





