#include "script_component.hpp"
#define DANGER_MODE_ARR ["disabled", "enabled"]
params ["_logic", "", "_activated"];

if (_activated && local _logic) then {

    //--- Terminate when remote control is already in progress
    if !(isNull (missionNamespace getVariable ["bis_fnc_moduleRemoteControl_unit", objNull])) exitWith {};

    //--- Get unit under cursor
    private _group = grpNull;
    private _mouseOver = missionNamespace getVariable ["BIS_fnc_curatorObjectPlaced_mouseOver", [""]];
    if ((_mouseOver select 0) isEqualTo (typeName objNull)) then { _group = group (_mouseOver select 1); };
    if ((_mouseOver select 0) isEqualTo (typeName grpNull)) then { _group = _mouseOver select 1; };

    //--- Check if the unit is suitable
    private _error = "";

    if (isNull _group) then {
        _error = "No Group Selected";
    };

    if (_error == "") then {
        private _mode = _unit getVariable [QGVAR(dangerAI), 0];
        private _index = DANGER_MODE_ARR find _mode;
        if (_index == -1) then {
            _index = 0;
        };

        ["Lambs Danger AI Mode",
            [
                ["Lambs AI Mode", "DROPDOWN", "Disables Lambs AI", DANGER_MODE_ARR,  _index]
            ], {
                params ["_data", "_args"];
                _args params ["_unit", "_logic"];
                _data params ["_mode"];
                _unit setVariable [QGVAR(dangerAI), DANGER_MODE_ARR select _mode, true];
                deleteVehicle _logic;
            }, {}, {}, [_unit, _logic]
        ] call EFUNC(main,showDialog);
    } else {
        [objNull, _error] call BIS_fnc_showCuratorFeedbackMessage;
        deleteVehicle _logic;
    };
};
