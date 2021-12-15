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
_units = _units select {_x call FUNC(isAlive) && {!isPlayer _x}};
if (_units isEqualTo [] || {_pos isEqualTo []}) exitWith {false};

private _targetPos = _pos deleteAt 0;
{
    // manoeuvre
    _x forceSpeed 3;
    _x setUnitPosWeak (["UP", "MIDDLE"] select (getSuppression _x isNotEqualTo 0));
    _x setVariable [QGVAR(currentTask), "Group Assault", GVAR(debug_functions)];
    _x setVariable [QEGVAR(danger,forceMove), true];

    // check enemy
    private _enemy = _x findNearestEnemy _x;
    if (_x distance2D _enemy < 12) then {_targetPos = getPosATL _enemy;};

    // setpos
    if (RND(0.75) || {(currentCommand _x) isNotEqualTo "MOVE"}) then {
        _x lookAt _targetPos;
        _x doMove _targetPos;
        _x setDestination [_targetPos, "LEADER PLANNED", false]; // added to reduce cover bounding - nkenny
    };
} foreach _units;

// recursive cyclic
if !(_cycle <= 1 || {_units isEqualTo []}) then {
    [
        {_this call FUNC(doGroupAssault)},
        [_cycle - 1, _units, _pos],
        8
    ] call CBA_fnc_waitAndExecute;
};

// end
true
