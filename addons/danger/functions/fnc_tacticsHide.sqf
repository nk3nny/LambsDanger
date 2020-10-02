#include "script_component.hpp"
/*
 * Author: nkenny
 * Leader calls for group to hide a special mode with optional anti-armour tactics
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
params ["_unit", "_target", ["_antiTank", false], ["_buildings", []], ["_delay", 180]];

// find target
_target = _target call CBA_fnc_getPos;

// reset tactics
private _group = group _unit;
[
    {
        params [["_group", grpNull]];
        if (!isNull _group) then {
            _group setVariable [QGVAR(tactics), nil];
            _group setVariable [QGVAR(tacticsTask), nil];
        };
    },
    _group,
    _delay
] call CBA_fnc_waitAndExecute;

// alive unit
if !(_unit call EFUNC(main,isAlive)) exitWith {false};

_unit setVariable [QGVAR(currentTarget), _target, EGVAR(main,debug_functions)];
_unit setVariable [QGVAR(currentTask), "Leader Hide", EGVAR(main,debug_functions)];

// set group task
_group setVariable [QGVAR(tacticsTask), "Hiding", EGVAR(main,debug_functions)];

// gesture
[_unit, "gestureCover"] call EFUNC(main,doGesture);

// callout
[_unit, behaviour _unit, "TakeCover", 125] call EFUNC(main,doCallout);

// sort units
private _units = units _unit;
_units = _units select {_x call EFUNC(main,isAlive) && {isNull objectParent _x}};
_units = _units select {!(_x call EFUNC(main,isIndoor))};
if (_units isEqualTo []) exitWith {false};

// find launcher ~ if present, exit with preparation for armoured/air contact
private _launchers = _units select {(secondaryWeapon _x) isEqualTo ""};
if (_antiTank && {!(_launchers isEqualTo [])}) exitWith {
    {
        // launcher units target air/tank
        _x commandTarget _target;

        // extra impetuous to select launcher
        _x selectWeapon (secondaryWeapon _x);
        _x setUnitPosWeak "MIDDLE";
    } forEach _launchers;

    // extra aggression from unit
    _unit doFire _target;
    true
};

// find buildings
if (_buildings isEqualTo []) then {
    _buildings = [_unit getPos [10, _target getDir _unit], 45, true, true] call EFUNC(main,findBuildings);
};

// hide for the rest
{
    // ready
    doStop _x;

    // hide
    [_x, _target, 45, _buildings] call FUNC(doHide);
} forEach _units;
true
