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
    _units = [_unit, 125] call FUNC(findReadyUnits);
};

// sort building locations
private _pos = [_target, 12, true, false] call FUNC(findBuildings);
_pos = [_pos, [], { _x select 2 }, "DESCEND"] call BIS_fnc_sortBy;    // ~ top to bottom
_pos pushBack _target;

// leader ~ rally animation here
[_unit, ["gestureFollow"]] call FUNC(gesture);

// leader callout
[_unit, "combat", "RallyUp", 125] call FUNC(doCallout);

// set tasks
_unit setVariable [QGVAR(currentTarget), _target];
_unit setVariable [QGVAR(currentTask), "Leader Rally"];

// rally unit
{
    // check garrison
    if (_garrison) then {doStop _x};

    // set mode
    _x forceSpeed 3;
    _x setVariable [QGVAR(forceMove), !_garrison];

    // execute move
    if !(_pos isEqualTo []) then {
        _x doMove (_pos deleteAt 0);
    } else {
        _x doMove _target;
    };

    true

} count _units;

// end
true
