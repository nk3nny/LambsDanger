#include "script_component.hpp"
/*
 * Author: jokoho482
 * Sets a dynamic target which can be connected to other scripts
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
        if (_unit isKindOf "CAManBase") then {
            _logic setVehicleVarName format ["Dynamic Target %1", name _unit];
        } else {
            _logic setVehicleVarName format ["Dynamic Target %1", getText (configFile >> "CfgVehicles" >> typeOf _unit >> "displayName")];
        };
    } else {
        _logic setVehicleVarName format ["Dynamic Target %1",[[ GVAR(TargetIndex) + 1 ] call BIS_fnc_phoneticalWord, "Zulu " + str (GVAR(TargetIndex) + 1)] select (GVAR(TargetIndex) > 26)];
    };
    [objNull, format ["%1 created", vehicleVarName _logic]] call BIS_fnc_showCuratorFeedbackMessage;
    GVAR(TargetIndex) = GVAR(TargetIndex) + 1;
    GVAR(ModuleTargets) pushBack _logic;
    GVAR(ModuleTargets) = GVAR(ModuleTargets) - [objNull];
};
