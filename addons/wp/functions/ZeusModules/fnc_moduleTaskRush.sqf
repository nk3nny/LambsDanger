#include "script_component.hpp"
diag_log _this;

_this params ["_logic", "", "_activated"];

if (_activated && local _logic) then {

    //--- Terminate when remote control is already in progress
    if !(isNull (missionNamespace getVariable ["bis_fnc_moduleRemoteControl_unit", objNull])) exitWith {};

    //--- Get unit under cursor
    private _group = grpNull;
    private _mouseOver = missionNamespace getVariable ["BIS_fnc_curatorObjectPlaced_mouseOver", [""]];
    if ((_mouseOver select 0) isEqualTo (typeName objNull)) then { _group = group (effectiveCommander (_mouseOver select 1)); };
    if ((_mouseOver select 0) isEqualTo (typeName grpNull)) then { _group = _mouseOver select 1; };

    //--- Check if the unit is suitable
    private _error = "";
    if (isNull _group) then { _error = "Error: No Group Selected"; };

    if (_error == "") then {
        
    } else {
        [objNull, _error] call BIS_fnc_showCuratorFeedbackMessage;
    };
    deleteVehicle _logic;
};
