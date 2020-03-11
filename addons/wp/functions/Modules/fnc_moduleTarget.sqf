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
    private _unit = GET_CURATOR_UNIT_UNDER_CURSOR;
    if !(isNull _unit) then {
        _logic attachTo [_unit, [0,0,0]];
    };
    _logic setVehicleVarName format ["Lambs Target %1", GVAR(TargetIndex)];
    GVAR(TargetIndex) = GVAR(TargetIndex) + 1;
    GVAR(ModuleTargets) pushBack _logic;
    GVAR(ModuleTargets) = GVAR(ModuleTargets) - [objNull];
};
