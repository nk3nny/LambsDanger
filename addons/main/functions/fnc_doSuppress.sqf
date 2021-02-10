#include "script_component.hpp"
/*
 * Author: nkenny
 * Unit performs suppressive fire on target location
 *
 * Arguments:
 * 0: unit suppressing <OBJECT>
 * 1: target position <ARRAY> (ASL position)
 *
 * Return Value:
 * success
 *
 * Example:
 * [bob, eyePos angryJoe] call lambs_main_fnc_suppress;
 *
 * Public: No
*/
params ["_unit", "_pos"];

// no primary weapons exit? Player led groups do not auto-suppress
private _eyePos = eyePos _unit;
if (
    getSuppression _unit > 0.75
    || {(primaryWeapon _unit) isEqualTo ""}
    || {(currentCommand _unit) isEqualTo "Suppress"}
    || {terrainIntersectASL [_eyePos, _pos]}
    || {isPlayer (leader _unit) && {GVAR(disablePlayerGroupSuppression)}}
) exitWith {false};

// check for friendlies
private _friendlies = [_unit, (ASLToAGL _pos), GVAR(minFriendlySuppressionDistance)] call FUNC(findNearbyFriendlies);
if !(_friendlies isEqualTo []) exitWith {false};

// adjust pos
private _vis = lineIntersectsSurfaces [_eyePos, _pos, _unit, vehicle _unit, true, 1];
if !(_vis isEqualTo []) then {_pos = (_vis select 0) select 0;};

// max range pos
private _distance = (_eyePos vectorDistance _pos) min 280;
_pos = (_eyePos vectorAdd ((_eyePos vectorFromTo _pos) vectorMultiply _distance));

// final range check
if (_eyePos vectorDistance _pos < GVAR(minSuppressionRange)) exitWith {false};

// Callout!
if (RND(0.4) && {count (units _unit) > 1}) then {
    [_unit, "Combat", "suppress", 75] call FUNC(doCallout);
};

// do it!
_unit doWatch (ASLtoAGL _pos);
_unit doSuppressiveFire _pos;

// Suppressive fire
_unit setVariable [QGVAR(currentTask), "Suppress!", GVAR(debug_functions)];
_unit setVariable [QGVAR(currentTarget), _pos, GVAR(debug_functions)];

// debug
if (GVAR(debug_functions)) then {
    ["%1 Suppression (%2 @ %3m)", side _unit, name _unit, round (_eyePos vectorDistance _pos)] call FUNC(debugLog);

    private _sphere = createSimpleObject ["Sign_Sphere100cm_F", _pos, true];
    _sphere setObjectTexture [0, [_unit] call FUNC(debugObjectColor)];
    [{deleteVehicle _this}, _sphere, 20] call CBA_fnc_waitAndExecute;
};

// end
true