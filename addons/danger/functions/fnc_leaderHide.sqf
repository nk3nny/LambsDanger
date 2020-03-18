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
 * [bob, angryJoe] call lambs_danger_fnc_leaderHide;
 *
 * Public: No
*/
params ["_unit", "_target", ["_buildings", []]];

// check if target remains a threat or is invalid
if (_target isEqualType [] || {isNull _target} || {!alive _target}) exitWith {false};

_unit setVariable [QGVAR(currentTarget), _target];
_unit setVariable [QGVAR(currentTask), "Leader Hide"];

// gesture
[_unit, ["gestureCover"]] call FUNC(gesture);

// callout
[_unit, behaviour _unit, "TakeCover", 125] call FUNC(doCallout);

// sort units
private _units = units _unit;
_units = _units select {_x call FUNC(isAlive) && {isNull objectParent _x}};

// find launcher ~ if present, exit with preparation for armoured/air contact
private _launchers = _units select {(secondaryWeapon _x) isEqualTo ""};
if !(_launchers isEqualTo []) exitWith {
    {

        // launcher units target air/tank
        _x commandTarget _target;

        // extra impetuous to select launcher
        _x selectWeapon (secondaryWeapon _x);
        _x setUnitPosWeak "MIDDLE";

    } foreach _launchers;

    // extra aggression from unit
    _unit doFire _target;

    // end
    true

};

// find buildings
if (_buildings isEqualTo []) then {
    _buildings = [_unit getPos [10, _target getDir _unit], 45, true, true] call FUNC(findBuildings);
};

// groups without launchers hide!
{
    // add suppression
    _x setSuppression ((getSuppression _x) + random 1);

    // hide
    _x setVariable [QGVAR(forceMove), true];
    [_x, _target, 45, _buildings] call FUNC(hideInside);

} foreach _units;

// end
true
