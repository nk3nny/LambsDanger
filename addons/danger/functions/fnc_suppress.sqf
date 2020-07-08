#include "script_component.hpp"
/*
 * Author: nkenny
 * Unit performs suppressive fire on target location
 *
 * Arguments:
 * 0: Unit suppressing <OBJECT>
 * 1: Target position <ARRAY> (ASL position)
 * 2: Override target search <BOOL>
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
if (
    getSuppression _unit > 0.75
    || {terrainIntersectASL [eyePos _unit, _pos]}
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
private _vis = lineIntersectsSurfaces [eyePos _unit, _pos, _unit, vehicle _unit, true, 1];
if !(_vis isEqualTo []) then {_pos = (_vis select 0) select 0;};

// max range pos
private _distance = (_unit distance (ASLToAGL _pos)) min 280;
_pos = ((eyePos _unit) vectorAdd ((eyePos _unit vectorFromTo _pos) vectorMultiply _distance));

// final range check
if (!_override && {_distance < GVAR(minSuppression_range)}) exitWith {false};

private _friendlys = [_unit, (ASLToAGL _pos), GVAR(minFriendlySuppressionDistance)] call EFUNC(main,findNearbyFriendly);
if !(_friendlys isEqualTo []) exitWith {false};

// Callout!
if (RND(0.4) && {count units _unit > 1}) then {
    [_unit, "Combat", "suppress", 75] call EFUNC(main,doCallout);
};

// do it!
_unit forceSpeed 0;
_unit doSuppressiveFire _pos;

// Suppressive fire
_unit setVariable [QGVAR(currentTask), "Suppressive Fire", EGVAR(main,debug_functions)];
_unit setVariable [QGVAR(currentTarget), _pos, EGVAR(main,debug_functions)];

// extend suppressive fire for machineguns
if (_unit ammo (currentWeapon _unit) > 32) then {
    _unit suppressFor (7 + random 20);
};

// debug
if (EGVAR(main,debug_functions)) then {
    format ["%1 Suppression (%2 @ %3m)", side _unit, name _unit, round (_unit distance ASLtoAGL _pos)] call EFUNC(main,debugLog);

    private _sphere = createSimpleObject ["Sign_Sphere100cm_F", _pos, true];
    _sphere setObjectTexture [0, [_unit] call EFUNC(main,debugObjectColor)];
    [{deleteVehicle _this}, _sphere, 20] call CBA_fnc_waitAndExecute;
};

// end
true
