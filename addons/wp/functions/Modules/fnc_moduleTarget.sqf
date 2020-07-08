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
    private _name = "Something Broke";
    if !(isNull _unit) then {
        _logic attachTo [_unit, [0,0,0]];
        if (_unit isKindOf "CAManBase") then {
            _name = format ["Dynamic Target %1", name _unit];
        } else {
            _name = format ["Dynamic Target %1", getText (configFile >> "CfgVehicles" >> typeOf _unit >> "displayName")];
        };
    } else {
        GVAR(TargetIndex) = GVAR(TargetIndex) + 1;
        private _callName = [
            [GVAR(TargetIndex)] call BIS_fnc_phoneticalWord,
            format ["%1 %2", localize "STR_A3_RADIO_Z", GVAR(TargetIndex)]
        ] select (GVAR(TargetIndex) > 26);
         _name = format ["Dynamic Target %1", _callName];
    };
    _logic setVehicleVarName _name;
    [objNull, format ["%1 created", vehicleVarName _logic]] call BIS_fnc_showCuratorFeedbackMessage;
    GVAR(ModuleTargets) pushBack _logic;
    GVAR(ModuleTargets) = GVAR(ModuleTargets) - [objNull];
};
