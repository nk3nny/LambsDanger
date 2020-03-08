#include "script_component.hpp"

params ["_logic", "", "_activated"];

if (_activated && local _logic) then {

    //--- Get unit under cursor
    GET_CURATOR_UNIT_UNDER_CURSOR(_unit);

    //--- Check if the unit is suitable
    private _error = "";
    if (isNull _unit) then {
        _error = "No Unit Selected";
    };
    if (isPlayer _unit) then {
        _error = "Players are not Valid Selections";
    };
    if (_error == "") then {
        ["Disable Unit AI",
            [
                ["Disable LAMBS unit AI", "BOOLEAN", "Toggle advanced danger.fsm features on this unit", _unit getVariable [QGVAR(disableAI), false]]
            ], {
                params ["_data", "_args"];
                _args params ["_unit", "_logic"];
                _data params ["_disableAI"];
                _unit setVariable [QGVAR(disableAI), _disableAI, true];
                deleteVehicle _logic;
            }, {
                params ["", "_logic"];
                deleteVehicle _logic;
            }, {
                params ["", "_logic"];
                deleteVehicle _logic;
            }, [_unit, _logic]
        ] call EFUNC(main,showDialog);
    } else {
        [objNull, _error] call BIS_fnc_showCuratorFeedbackMessage;
        deleteVehicle _logic;
    };
};
