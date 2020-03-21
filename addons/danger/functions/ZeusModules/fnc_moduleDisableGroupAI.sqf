#include "script_component.hpp"

params ["_logic", "", "_activated"];
diag_log _this;
if (_activated && local _logic) then {

    //--- Get unit under cursor
    private _group = GET_CURATOR_GRP_UNDER_CURSOR;

    //--- Check if the unit is suitable
    private _error = "";
    if (isNull _group) then {
        _error = "No Group Selected";
    };

    if (_error == "") then {
        ["Configure Group AI",
            [
                ["Disable LAMBS group AI", "BOOLEAN", "Disables LAMBS group AI\nDisabling this feature prevents autonomous building assaults and clearing, as well as hiding from aircraft and tanks", _group getVariable [QGVAR(disableGroupAI), false], ""]
            ], {
                params ["_data", "_args"];
                _args params ["_group", "_logic"];
                _data params ["_disableGroupAI"];
                _group setVariable [QGVAR(disableGroupAI), _disableGroupAI, true];
                deleteVehicle _logic;
            }, {
                params ["", "_logic"];
                deleteVehicle _logic;
            }, {
                params ["", "_logic"];
                deleteVehicle _logic;
            }, [_group, _logic]
        ] call EFUNC(main,showDialog);
    } else {
        [objNull, _error] call BIS_fnc_showCuratorFeedbackMessage;
        deleteVehicle _logic;
    };
};
