#include "script_component.hpp"
/*
 * Author: nkenny
 * Actualises assault cycle
 *
 * Arguments:
 * 0: cycles <NUMBER>
 * 1: units list <ARRAY>
 * 2: list of building/enemy positions <ARRAY>
 *
 * Return Value:
 * bool
 *
 * Example:
 * [units bob] call lambs_main_fnc_doGroupAssault;
 *
 * Public: No
*/
params ["_cycle", "_units", "_pos"];

// update
_units = _units select {_x call FUNC(isAlive) && {!isPlayer _x} && {!fleeing _x}};
if (_units isEqualTo [] || {_pos isEqualTo []}) exitWith {
    // early reset
    {
        _x setVariable [QGVAR(forceMove), nil];
        _x doFollow leader _x;
        _x forceSpeed -1;
    } foreach _units;
    false
};

private _targetPos = _pos select 0;

{
    // manoeuvre
    _x forceSpeed 3;
    _x setUnitPosWeak (["UP", "MIDDLE"] select (getSuppression _x isNotEqualTo 0));
    _x setVariable [QGVAR(currentTask), "Group Assault", GVAR(debug_functions)];
    _x setVariable [QEGVAR(danger,forceMove), true];

    // check enemy
    private _enemy = _x findNearestEnemy _x;
    if (
        _x distance2D _enemy < 12
        && {(vehicle _enemy) isKindOf "CAManBase"}
        && {_enemy call FUNC(isAlive)}
    ) then {
        _targetPos = getPosATL _enemy;
        _x setDestination [_targetPos, "LEADER PLANNED", false]; // added to reduce cover bounding - nkenny
    };

    // set movement
    if (RND(0.75) || {(currentCommand _x) isNotEqualTo "MOVE"}) then {
        _x doWatch objNull;
        _x doMove (_targetPos vectorAdd [-1 + random 2, -1 + random 2, 0.1]);
    };
} foreach _units;

// remove  positions
private _unit = _units select 0;
_pos = _pos select {_unit distance _x > 5 || {[objNull, "VIEW", objNull] checkVisibility [eyePos _unit, (AGLToASL _x) vectorAdd [0, 0, 1]] isEqualTo 0}};

// recursive cyclic
if !(_cycle <= 1 || {_units isEqualTo []}) then {
    [
        {_this call FUNC(doGroupAssault)},
        [_cycle - 1, _units, _pos],
        3
    ] call CBA_fnc_waitAndExecute;
};

// end
true
