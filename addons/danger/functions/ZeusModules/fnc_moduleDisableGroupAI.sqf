#include "script_component.hpp"

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
                params ["_logic"];
                deleteVehicle _logic;
            }, {
                params ["_logic"];
                deleteVehicle _logic;
            }, [_group, _logic]
        ] call EFUNC(main,showDialog);
    } else {
        [objNull, _error] call BIS_fnc_showCuratorFeedbackMessage;
        deleteVehicle _logic;
    };
};
