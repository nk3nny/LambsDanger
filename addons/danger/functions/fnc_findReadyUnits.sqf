#include "script_component.hpp"
/*
 * Author: nkenny
 * Finds units ready for group actions
 *
 * Arguments:
 * 0: Originating unit <OBJECT>
 * 1: Find units within range <NUMBER>, default 200
 * 2: Find units within given pool <ARRAY>, default []
 *
 * Return Value:
 * available units (only infantry)
 *
 * Example:
 * [bob, 200] call lambs_danger_fnc_findReadyUnits;
 *
 * Public: Yes
*/

params ["_unit", ["_range", 200], ["_units", []]];

if (_units isEqualTo []) then {
    _units = units _unit;
};

// sort
_units = _units select {
    //unitReady _x
    _x distance2d _unit < _range
    && { isNull objectParent _x }
    && { _x call FUNC(isAlive) }
    && { !(_x getVariable [QGVAR(forceMove), false]) }
    && { !isPlayer _x }
    && { !fleeing _x }
    && { _x checkAIFeature "PATH" }
    && { _x checkAIFeature "MOVE" }
};

_units