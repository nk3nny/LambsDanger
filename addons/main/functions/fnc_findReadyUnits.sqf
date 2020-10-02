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
 * [bob, 200] call lambs_main_fnc_findReadyUnits;
 *
 * Public: Yes
*/

params [
    ["_unit", objNull, [objNull]],
    ["_range", 200, [0]],
    ["_units", [], [[]]]
];

if (_units isEqualTo []) then {
    _units = units _unit;
};

// sort
_units = _units select {
    //unitReady _x
    _x distance2D _unit < _range
    && { isNull objectParent _x }
    && { _x call EFUNC(main,isAlive) }
    && { !(_x getVariable [QGVAR(forceMove), false]) }
    && { !isPlayer _x }
    && { !fleeing _x }
    && { _x checkAIFeature "PATH" }
    && { _x checkAIFeature "MOVE" }
};

_units
