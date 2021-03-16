#include "script_component.hpp"
/*
 * Author: nkenny
 * Vehicle performs suppressive fire on target location
 *
 * Arguments:
 * 0: vehicle suppressing <OBJECT>
 * 1: target position <ARRAY>
 *
 * Return Value:
 * success
 *
 * Example:
 * [bob, getPos angryJoe] call lambs_main_fnc_doVehicleSuppress;
 *
 * Public: No
*/
params ["_unit", ["_pos", [0, 0, 0]]];

private _vehicle = vehicle _unit;
private _pos = _pos call CBA_fnc_getPos;

// exit if vehicle is moving too fast or target is too high
if (speed _vehicle > 30 || {(_pos select 2) > 100}) exitWith {false};

// pos
private _eyePos = eyePos _unit;
_pos = (AGLtoASL _pos) vectorAdd [0.5 - random 1, 0.5 - random 1, 0.3 + random 1.3];

// target oo close or terrain occludes target
if (
    (_eyePos vectorDistance _pos) < GVAR(minSuppressionRange)
    || {terrainIntersectASL [_eyePos, _pos]}
) exitWith {false};

// artillery (no tactical options)
if (_vehicle getVariable [QGVAR(isArtillery), getNumber (configOf (vehicle _unit) >> "artilleryScanner") > 0]) exitWith {
    _vehicle setVariable [QGVAR(isArtillery), true];
    false
};

// set task
_unit setVariable [QGVAR(currentTarget), _pos, GVAR(debug_functions)];
_unit setVariable [QGVAR(currentTask), "Vehicle Suppress", GVAR(debug_functions)];

// trace
private _vis = lineIntersectsSurfaces [_eyePos, _pos, _unit, vehicle _unit, true, 1];
if !(_vis isEqualTo []) then {_pos = (_vis select 0) select 0;};

// reAdjust
private _distance = (_eyePos vectorDistance _pos) - 4;
_pos = (_eyePos vectorAdd ((_eyePos vectorFromTo _pos) vectorMultiply _distance));

// recheck
if (_eyePos vectorDistance _pos < GVAR(minSuppressionRange)) exitWith {false};
private _friendlies = [_vehicle, (ASLToAGL _pos), GVAR(minFriendlySuppressionDistance) + 4] call FUNC(findNearbyFriendlies);
if !(_friendlies isEqualTo []) exitWith {false};

// do it
_vehicle doSuppressiveFire _pos;

// debug
if (GVAR(debug_functions)) then {
    [
        "%1 suppression (%2 @ %3m)",
        side _unit, getText (configOf _vehicle >> "displayName"),
        round (_unit distance ASLToAGL _pos)
    ] call FUNC(debugLog);
    private _sphere = createSimpleObject ["Sign_Sphere100cm_F", _pos, true];
    _sphere setObjectTexture [0, [_unit] call FUNC(debugObjectColor)];
    [{deleteVehicle _this}, _sphere, 20] call CBA_fnc_waitAndExecute;
};

// end
true
