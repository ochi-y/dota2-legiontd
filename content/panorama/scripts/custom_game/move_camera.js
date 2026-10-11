function MoveCamera(data) {
    var cameraTarget = [];
    if (data.unitTargetEntIndex) {
        cameraTarget = Entities.GetAbsOrigin(data.unitTargetEntIndex)
    } else if (data.cameraTarget) {
        var cameraTargetString = data.cameraTarget.split(" ");
        cameraTarget[0] = parseFloat(cameraTargetString[0]);
        cameraTarget[1] = parseFloat(cameraTargetString[1]);
        cameraTarget[2] = parseFloat(cameraTargetString[2]);
    }
    GameUI.SetCameraTargetPosition(cameraTarget, data.lerp);
}

function SetCamera(data) {
    GameUI.MoveCameraToEntity(data.target);
}

function CameraLookat(data) {
    GameUI.SetCameraTarget(data.target);
}

function SelectUnit(data) {
    $.Msg("SelectUnit")
    $.Msg(data)

    var iPlayerID = Players.GetLocalPlayer()
    var selectedEntities = Players.GetSelectedEntities(iPlayerID)
    var numEntities = Object.keys(selectedEntities).length;

    if (numEntities == 1) {
        for (var i = 0; i < numEntities; i++) {
            var entindex = selectedEntities[i];
            if (entindex == -1)
                continue;
            var alive = Entities.IsAlive(entindex);
            $.Msg("ent alive", entindex, alive)
            if (!alive) {
                GameUI.SelectUnit(data.target, false);
                return
            }
        }
    }
    if (data.single) {
        $.Msg("SelectUnit false")
        GameUI.SelectUnit(data.target, false);
    } else {
        $.Msg("SelectUnit true")
        GameUI.SelectUnit(data.target, true);
    }
}

(function () {
    GameEvents.Subscribe("move_camera", MoveCamera);
    GameEvents.Subscribe("set_camera", SetCamera);
    GameEvents.Subscribe("camera_lookat", CameraLookat);
    GameEvents.Subscribe("select_unit", SelectUnit);

})();