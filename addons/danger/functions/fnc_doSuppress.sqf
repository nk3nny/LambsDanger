#include "script_component.hpp"
/*
 * Author: nkenny
 * Unit performs suppressive fire on target location
 *
 * Arguments:
 * 0: unit suppressing <OBJECT>
 * 1: target position <ARRAY> (ASL position)
 * 2: override target search <BOOL>
 *
 * Return Value:
 * success
 *
 * Example:
 * [bob, getPosASL angryJoe, false] call lambs_danger_fnc_suppress;
 *
 * Public: No
*/
params ["_unit", "_pos", ["_override", false]];

// no primary weapons exit? Player led groups do not auto-suppress
private _eyePos = eyePos _unit;
if (
    getSuppression _unit > 0.75
    || {terrainIntersectASL [_eyePos, _pos]}
    || {(primaryWeapon _unit) isEqualTo ""}
    || {(currentCommand _unit) isEqualTo "Suppress"}
    || {isPlayer (leader _unit) && {GVAR(disableAIPlayerGroupSuppression)}}
) exitWith {false};

// override
if (!_override) then {
    private _enemy = _unit findNearestEnemy (ASLToAGL _pos);
    if (isNull _enemy) exitWith {};
    _pos = ATLToASL (_unit getHideFrom _enemy);
};

// adjust pos
private _vis = lineIntersectsSurfaces [_eyePos, _pos, _unit, vehicle _unit, true, 1];
if !(_vis isEqualTo []) then {_pos = (_vis select 0) select 0;};

// max range pos
private _distance = (_eyePos vectorDistance _pos) min 280;
_pos = (_eyePos vectorAdd ((_eyePos vectorFromTo _pos) vectorMultiply _distance));

// final range check
if (!_override && {_eyePos vectorDistance _pos < GVAR(minSuppressionRange)}) exitWith {false};

private _friendlies = [_unit, (ASLToAGL _pos), GVAR(minFriendlySuppressionDistance)] call EFUNC(main,findNearbyFriendlies);
if !(_friendlies isEqualTo []) exitWith {false};

// Callout!
if (RND(0.4) && {count (units _unit) > 1}) then {
    [_unit, "Combat", "suppress", 75] call EFUNC(main,doCallout);
};

// do it!
_unit doSuppressiveFire _pos;

// Suppressive fire
_unit setVariable [QGVAR(currentTask), "Suppress!", EGVAR(main,debug_functions)];
_unit setVariable [QGVAR(currentTarget), _pos, EGVAR(main,debug_functions)];

// extend suppressive fire for machineguns
if (_unit ammo (currentWeapon _unit) > 32) then {
    _unit suppressFor (7 + random 20);
};

// debug
if (EGVAR(main,debug_functions)) then {
    ["%1 Suppression (%2 @ %3m)", side _unit, name _unit, round (_eyePos vectorDistance _pos)] call EFUNC(main,debugLog);

    private _sphere = createSimpleObject ["Sign_Sphere100cm_F", _pos, true];
    _sphere setObjectTexture [0, [_unit] call EFUNC(main,debugObjectColor)];
    [{deleteVehicle _this}, _sphere, 20] call CBA_fnc_waitAndExecute;
};

// end
true
