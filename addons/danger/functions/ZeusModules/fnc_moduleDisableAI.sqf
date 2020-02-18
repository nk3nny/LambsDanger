#include "script_component.hpp"

params ["_logic", "", "_activated"];

if (_activated && local _logic) then {

    //--- Terminate when remote control is already in progress
    if !(isNull (missionNamespace getVariable ["bis_fnc_moduleRemoteControl_unit", objNull])) exitWith {};

    //--- Get unit under cursor
    private _unit = objNull;
    private _mouseOver = missionNamespace getVariable ["BIS_fnc_curatorObjectPlaced_mouseOver", [""]];
    if ((_mouseOver select 0) isEqualTo (typeName objNull)) then { _unit = _mouseOver select 1; };

    //--- Check if the unit is suitable
    private _error = "";
    if (isNull _unit) then {
        _error = "No Unit Selected";
    };
    if (_error == "") then {
        ["Disable LAMBS AI",
            [
                ["Disable LAMBS unit AI", "BOOLEAN", "Toggle advanced danger.fsm features on this unit", _unit getVariable [QGVAR(disableAI), false]]
            ], {
                params ["_data", "_args"];
                _args params ["_unit", "_logic"];
                _data params ["_disableAI"];
                _unit setVariable [QGVAR(disableAI), _disableAI, true];
                deleteVehicle _logic;
            }, {
                params ["_logic"];
                deleteVehicle _logic;
            }, {
                params ["_logic"];
                deleteVehicle _logic;
            }, [_unit, _logic]
        ] call EFUNC(main,showDialog);
    } else {
        [objNull, _error] call BIS_fnc_showCuratorFeedbackMessage;
        deleteVehicle _logic;
    };
};
