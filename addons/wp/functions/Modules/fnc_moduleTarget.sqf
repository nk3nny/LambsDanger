#include "script_component.hpp"
/*
 * Author: jokoho482
 * TODO
 *
 * Arguments:
 * TODO
 *
 * Return Value:
 * TODO
 *
 * Example:
 * TODO
 *
 * Public: No
*/
params ["_logic", "", "_activated"];

if(local _logic && _activated) then {
    private _unit = objNull;
    private _mouseOver = missionNamespace getVariable ["BIS_fnc_curatorObjectPlaced_mouseOver", [""]];
    if ((_mouseOver select 0) isEqualTo (typeName objNull)) then { _unit = group (_mouseOver select 1); };

    if !(isNull _unit) then {
        _logic attachTo [_unit, [0,0,0]];
    };
    _logic setVehicleVarName format ["Lambs Target %1", GVAR(TargetIndex)];
    GVAR(TargetIndex) = GVAR(TargetIndex) + 1;
};
