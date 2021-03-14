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
if (_units isEqualTo []) exitWith {};

{
    private _targetPos = selectRandom _pos;
    // setpos
    if ((currentCommand _x) isNotEqualTo "MOVE") then {
        _x doMove _targetPos;
        _x setDestination [_targetPos, "FORMATION PLANNED", false]; // added to reduce cover bounding - nkenny
        _x doWatch _targetPos;
    };

    // manoeuvre
    //_x forceSpeed ([2, 4] select (getSuppression _x > 0 || {_x distance _targetPos < 45} || {terrainIntersectASL [eyePos _x, AGLtoASL _targetPos]}));
    _x forceSpeed 4;
    _x setUnitPosWeak (["UP", "MIDDLE"] select (getSuppression _x > 0));
    _x setVariable [QGVAR(currentTask), "Group Assault", GVAR(debug_functions)];
    _x setVariable [QEGVAR(danger,forceMove), true];

    // brave!
    _x setSuppression 0;
} foreach _units;

// recursive cyclic
if !(_cycle <= 1 || {_units isEqualTo []}) then {
    [
        {_this call FUNC(doGroupAssault)},
        [_cycle - 1, _units, _pos],
        5
    ] call CBA_fnc_waitAndExecute;
};

// end
true
