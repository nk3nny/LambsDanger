#include "script_component.hpp"
/*
 * Author: nkenny
 * Leader calls for group to hide. Units with launchers are unaffected
 *
 * Arguments:
 * 0: Group leader <OBJECT>
 * 1: Group threat unit <OBJECT> or position <ARRAY>
 * 2: Predefined buildings, default none <ARRAY>
 *
 * Return Value:
 * success
 *
 * Example:
 * [bob, getpos angryJoe] call lambs_danger_fnc_leaderHide;
 *
 * Public: No
*/
params ["_unit", "_target", ["_buildings", []]];

if (_buildings isEqualTo []) then {
    _buildings = [_unit getPos [10, _target getDir _unit], 45, true, true] call FUNC(findBuildings);
};

_unit setVariable [QGVAR(currentTarget), _target];
_unit setVariable [QGVAR(currentTask), "Leader Hide"];

// gesture
[_unit, ["gestureCover"]] call FUNC(gesture);

// units
private _units = units _unit;
_units = _units select {isNull ObjectParent _x && {(secondaryWeapon _x) isEqualTo ""}};

// units without launchers hide!
{
    // add suppression
    _x setSuppression ((getSuppression _x) + random 1);

    // hide
    [_x, _target, 45, _buildings] call FUNC(hideInside);

    // end
    true

} count _units;

// end
true
