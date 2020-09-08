#include "script_component.hpp"
/*
 * Author: nkenny
 * Leader calls for group to hide a special mode adds anti-armour tactics
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

params ["_unit", "_target", ["_antiTank", false], ["_buildings", []], ["_Zzz", 180]];

// find target
_target = _target call CBA_fnc_getPos;

// reset tactics
[
    {
        params "_group";
        if (!isNull _group) then {
            _group setVariable [QGVAR(tactics), nil];
        };
    },
    group _unit,
    _Zzz
] call CBA_fnc_waitAndExecute;

// alive unit
if (!alive _unit) exitWith {false};

_unit setVariable [QGVAR(currentTarget), _target, EGVAR(main,debug_functions)];
_unit setVariable [QGVAR(currentTask), "Leader Hide", EGVAR(main,debug_functions)];

// gesture
[_unit, ["gestureCover"]] call EFUNC(main,doGesture);

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

    // end
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

// end
true
