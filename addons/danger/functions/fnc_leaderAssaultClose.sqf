#include "script_component.hpp"
/*
 * Author: nkenny
 * Leader rallies troops and assaults unit into nearby buildings or location
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
 * [bob, angryJoe] call lambs_danger_fnc_leaderAssault;
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
    _units = (units _unit) select {_x call FUNC(isAlive) && {!isPlayer _x} && {_x distance _unit < 120}};
};

// sort building locations
private _pos = [_target, 12, true, false] call FUNC(findBuildings);
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

    // execute move
    _x doMove selectRandom _pos;
    _x forceSpeed 3;
    _x setVariable [QGVAR(forceMove), true];

    true

} count _units;

// end
true
