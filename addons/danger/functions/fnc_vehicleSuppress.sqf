#include "script_component.hpp"
/*
 * Author: nkenny
 * Vehicle performs suppressive fire on target location
 *
 * Arguments:
 * 0: vehicle suppressing <OBJECT>
 * 1: Target position <ARRAY>
 *
 * Return Value:
 * success
 *
 * Example:
 * [bob, getpos angryJoe] call lambs_danger_fnc_vehicleSuppress;
 *
 * Public: No
*/
params ["_unit", "_pos"];

// too close + high speed
if (_unit distance2d _pos < GVAR(minSuppression_range)) exitWith {false};
private _vehicle = vehicle _unit;
if (speed _vehicle > 12) exitWith {false};

// artillery (no tactical options)
if (_vehicle getVariable [QGVAR(isArtillery), getNumber (configFile >> "CfgVehicles" >> (typeOf (vehicle _unit)) >> "artilleryScanner") > 0]) exitWith {
    _vehicle setVariable [QGVAR(isArtillery), true];
    false
};

// raytrace + adjust pos
_pos = ((AGLtoASL _pos) vectorAdd [0.5 - random 1, 0.5 - random 1, 0.3 + random 1.3]);
private _vis = lineIntersectsSurfaces [eyePos _unit, _pos, _unit, vehicle _unit, true, 2];
if (count _vis > 1) then {_pos = (_vis select 0) select 0;};

_unit setVariable [QGVAR(currentTarget), _pos];
_unit setVariable [QGVAR(currentTask), "Vehicle Suppress"];

// do it
_vehicle doSuppressiveFire _pos;

// debug
if (GVAR(debug_functions)) then {

    format ["%1 suppression (%2 @ %3m)", side _unit, getText (configFile >> "CfgVehicles" >> (typeOf _vehicle) >> "displayName"), round (_unit distance _pos)] call FUNC(debugLog);

    private _sphere = createSimpleObject ["Sign_Sphere100cm_F", AGLtoASL _pos, true];
    _sphere setObjectTexture [0, [_unit] call FUNC(debugObjectColor)];
    [{deleteVehicle _this}, _sphere, 20] call cba_fnc_waitAndExecute;
};

// end
true
