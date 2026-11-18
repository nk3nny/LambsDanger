#include "script_component.hpp"
/*
 * Author: nkenny
 * Actualises group level hiding
 *
 * Arguments:
 * 0: units list <ARRAY>
 * 1: danger position <ARRAY> or <OBJECT>
 * 2: reason for hiding (used in debugging) <STRING>
 *
 * Return Value:
 * bool
 *
 * Example:
 * [units bob, angryJoe] call lambs_main_fnc_doGroupHide;
 *
 * Public: No
*/
params ["_units", "_pos", ["_action", "group"]];

// pass any argument
if (_units isEqualTypeAny [grpNull, objNull]) then {_units = units _units;};

// check units
_units = _units select { _x call FUNC(isAlive) && { isNull objectParent _x } && { !isPlayer _x } };
if (_units isEqualTo []) exitWith {false};

// get buildings
private _buildings = [selectRandom _units, 35, true, true] call FUNC(findBuildings);

{
    private _unit = _x;
    [_unit, _pos, nil, _buildings] call FUNC(doHide);
    _unit setVariable [QEGVAR(main,currentTask), format ["Hide (%1)", _action], EGVAR(main,debug_functions)];

    // force movement!
    _unit forceSpeed 24;
    _unit setVariable [QEGVAR(danger,forceMove), true];
    [
        {
            params ["_unit"];
            unitReady _unit
        },
        {
            params ["_unit", ["_pos", [0, 0, 0]]];
            _unit setVariable [QEGVAR(danger,forceMove), nil];
            [_unit, _pos] call FUNC(doHide);
            _unit doWatch _pos;
            _unit setVariable [QEGVAR(main,currentTask), format ["Hide (%1)", "re-hide"], EGVAR(main,debug_functions)];
        },
        [_unit, _pos],
        20 + random 40,
        {
            params ["_unit"];
            _unit setVariable [QEGVAR(danger,forceMove), nil];
        }
    ] call CBA_fnc_waitUntilAndExecute;
} forEach _units;

// end
true
