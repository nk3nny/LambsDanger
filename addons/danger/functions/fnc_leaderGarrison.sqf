#include "script_component.hpp"
/*
 * Author: nkenny
 * Leader rallies troops and garrisons nearby building from top to bottom with an option to remain firm.
 * COMMENT: Future versions of this function could leverage the more advanced Waypoint ~ nkenny
 *
 * Arguments:
 * 0: Group leader <OBJECT>
 * 1: Group threat unit <OBJECT> or position <ARRAY>
 * 2: Unit garrisons (holds position) <BOOL>
 * 3: Units in group, default all <ARRAY>
 *
 * Return Value:
 * success
 *
 * Example:
 * [bob, angryJoe] call lambs_danger_fnc_leaderGarrison;
 *
 * Public: No
*/
params ["_unit", "_target", ["_garrison", false], ["_units", []]];

// find target
_target = _target call CBA_fnc_getPos;

// stopped or static
if !(attackEnabled _unit) exitWith {false};

// find units
if (_units isEqualTo []) then {
    _units = [_unit, 125] call EFUNC(main,findReadyUnits);
};
if (_units isEqualTo []) exitWith {false};

// sort building locations
private _pos = [_target, 12, true, false] call EFUNC(main,findBuildings);
_pos = [_pos, [], { _x select 2 }, "DESCEND"] call BIS_fnc_sortBy;    // ~ top to bottom
_pos pushBack _target;

// leader ~ rally animation here
[_unit, ["gestureFollow"]] call EFUNC(main,doGesture);

// leader callout
[_unit, "combat", "RallyUp", 125] call EFUNC(main,doCallout);

// set tasks
_unit setVariable [QGVAR(currentTarget), _target, EGVAR(main,debug_functions)];
_unit setVariable [QGVAR(currentTask), "Leader Rally", EGVAR(main,debug_functions)];

// rally unit
{
    // check garrison
    if (_garrison) then {doStop _x};

    // set mode
    _x forceSpeed 3;
    _x setVariable [QGVAR(forceMove), !_garrison];
    _x setVariable [QGVAR(currentTask), "Group Garrison", EGVAR(main,debug_functions)];

    // execute move
    if !(_pos isEqualTo []) then {
        _x doMove (_pos deleteAt 0);
    } else {
        _x doMove _target;
    };
    true
} count _units;

// debug
if (EGVAR(main,debug_functions)) then {
    format ["%1 group GARRISON (%2 with %3 units @ %4m with %5 positions)", side _unit, name _unit, count _units, round (_unit distance2D _target), count _pos] call EFUNC(main,debugLog);
};

// end
true
