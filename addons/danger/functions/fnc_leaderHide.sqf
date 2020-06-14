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

_unit setVariable [QGVAR(currentTarget), _target, EGVAR(main,debug_functions)];
_unit setVariable [QGVAR(currentTask), "Leader Hide", EGVAR(main,debug_functions)];

// gesture
[_unit, ["gestureCover"]] call EFUNC(main,doGesture);

// callout
[_unit, behaviour _unit, "TakeCover", 125] call EFUNC(main,doCallout);

// sort units
private _units = units _unit;
_units = _units select {_x call EFUNC(main,isAlive) && {isNull objectParent _x}};
if (_units isEqualTo []) exitWith {false};

// find launcher ~ if present, exit with preparation for armoured/air contact
private _launchers = _units select {(secondaryWeapon _x) isEqualTo ""};
if !(_launchers isEqualTo []) exitWith {
    {

        // launcher units target air/tank
        _x commandTarget _target;

        // extra impetuous to select launcher
        _x selectWeapon (secondaryWeapon _x);
        _x setUnitPosWeak "MIDDLE";

    } forEach _launchers;

    // extra aggression from unit
    _unit doFire _target;

    // leaders rally troops in preparation
    if !( GVAR(disableAIAutonomousManoeuvres) || { (speedMode _unit) isEqualTo "FULL" } ) then {
        [_unit, 8, getpos _unit] call FUNC(leaderMode);
    };

    // end
    true

};

// find buildings
if (_buildings isEqualTo []) then {
    _buildings = [_unit getPos [10, _target getDir _unit], 45, true, true] call EFUNC(main,findBuildings);
};

// groups without launchers hide!
{

    // ready
    doStop _x;

    // add suppression
    _x setSuppression 1;

    // hide
    _x setVariable [QGVAR(forceMove), true];
    [_x, _target, 45, _buildings] call FUNC(doHide);

} forEach _units;

// end
true
