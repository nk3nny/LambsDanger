#include "script_component.hpp"

params ["_logic", "", "_activated"];

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
                ["Unit Has Radio", "BOOLEAN", "If a Unit has a Radio it has a Boosted Communication Range", _unit getVariable [QGVAR(dangerRadio), false]]
            ], {
                params ["_data", "_args"];
                _args params ["_unit", "_logic"];
                _data params ["_hasRadio"];
                _unit setVariable [QGVAR(dangerRadio), _hasRadio, true];
                deleteVehicle _logic;
            }, {}, {}, [_unit, _logic]
        ] call EFUNC(main,showDialog);
    } else {
        [objNull, _error] call BIS_fnc_showCuratorFeedbackMessage;
        deleteVehicle _logic;
    };
};
