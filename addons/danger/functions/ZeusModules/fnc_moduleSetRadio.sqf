#include "script_component.hpp"
diag_log _this;

_this params ["_logic", "", "_activated"];

if (_activated && local _logic) then {

    //--- Terminate when remote control is already in progress
    if !(isNull (missionNamespace getVariable ["bis_fnc_moduleRemoteControl_unit", objNull])) exitWith {};

    //--- Get unit under cursor
    private _unit = objNull;
    private _mouseOver = missionNamespace getVariable ["BIS_fnc_curatorObjectPlaced_mouseOver", [""]];
    if ((_mouseOver select 0) isEqualTo (typeName objNull)) then { _unit = _mouseOver select 1; };

    _unit = effectiveCommander _unit;


    //--- Check if the unit is suitable
    private _error = "";

    if (_error == "") then {
        ["Set Radio Module",
            [
                ["Unit Has Radio", "BOOLEAN"]
            ], {
                
            }, {

            }, {

            }
        ] call EFUNC(main,showDialog);
    } else {
        [objNull, _error] call BIS_fnc_showCuratorFeedbackMessage;
    };
    deleteVehicle _logic;
};
