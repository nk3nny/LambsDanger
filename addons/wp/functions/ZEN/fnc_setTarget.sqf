#include "script_component.hpp"

params ["_objects", "_pos"];

private _unit = _objects select 0;
private _logic = QGVAR(Target) createVehicleLocal _pos;
_logic setVariable [QEGVAR(main,skipInit), true];
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

(getAssignedCuratorLogic player) addCuratorEditableObjects [[_logic], false];
