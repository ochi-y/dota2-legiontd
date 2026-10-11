function refreshGold(data) {
    var gold = data.gold;
    $('#GoldText').text = gold;
}

var gPlayerData = CustomNetTables.GetAllTableValues("player")
CustomNetTables.SubscribeNetTableListener("player", function() {
    gPlayerData = CustomNetTables.GetAllTableValues("player")
    UpdateResourceBoard()
})

function getPlayerData(pid) {
    var v = gPlayerData.find(v => {
        return parseInt(v.key) == pid
    })
    if (v) {
        return v.value
    }
    return null
}


function btnGoldClicked() {
    GameEvents.SendEventClientSide("show_give_gold", {});
}

function UpdateResourceBoard(params) {
    var queryUnit = Players.GetLocalPlayerPortraitUnit();
    var id = Entities.GetPlayerOwnerID(queryUnit);
    var localPid = Players.GetLocalPlayer()

    let show=true

    if(Players.GetTeam(id) != Players.GetTeam(localPid)){
        show=false
    }

    var dota_legiontd_debug = null
    if(CustomNetTables.GetTableValue("dev", "dota_legiontd_debug")){
        dota_legiontd_debug=CustomNetTables.GetTableValue("dev", "dota_legiontd_debug").value
    }

    if(dota_legiontd_debug==1){
        show=true
    }
    

    if(show){
        var pdata = getPlayerData(id)
        if (id >= 0 && pdata) {
            var wood = pdata.wood || 0;
            $('#LumberText').text = wood;
            var gold = pdata.gold || 0
            $('#GoldText').text = gold;
            var food = pdata.food || 0
            var maxFood = pdata.maxFood || 0
            var foodRemain = maxFood - food
            $('#CheeseText').text = foodRemain + "/" + maxFood;
        }
    }else{
        $('#LumberText').text = "-";
        $('#GoldText').text = "-";
        $('#CheeseText').text = "-/-";
    }

}

(function() {
    UpdateResourceBoard();
    GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_GOLD, false);
    GameEvents.Subscribe("dota_player_update_selected_unit", UpdateResourceBoard);
    GameEvents.Subscribe("dota_player_update_query_unit", UpdateResourceBoard);
})();