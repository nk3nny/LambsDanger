#include "script_component.hpp"
/*
 * Author: nkenny
 * Leader calls for group to disperse into cover a special mode with optional anti-armour tactics
 *
 * Arguments:
 * 0: group leader <OBJECT>
 * 1: group threat unit <OBJECT> or position <ARRAY>
 * 2: ready anti-tank weapons <BOOL>
 * 3: predefined pieces of cover <ARRAY>
 * 4: delay until unit is ready again <NUMBER>
 *
 * Return Value:
 * success
 *
 * Example:
 * [bob, angryJoe] call lambs_danger_fnc_leaderHide;
 *
 * Public: No
*/
params ["_unit", "_target", ["_antiTank", false], ["_cover", []], ["_delay", 240]];

// find target
_target = _target call CBA_fnc_getPos;

// reset tactics
private _group = group _unit;
[
    {
        params [["_group", grpNull], ["_combatMode", "YELLOW"]];
        if (!isNull _group) then {
            _group setVariable [QGVAR(isExecutingTactic), nil];
            _group setVariable [QGVAR(tacticsTask), nil];
            _group setCombatMode _combatMode;
        };
    },
    [_group, combatMode _group],
    _delay
] call CBA_fnc_waitAndExecute;

// hold-fire combat mode
_group setCombatMode "GREEN";

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

// find cover
if (_cover isEqualTo []) then {
    private _coverPos = _unit getPos [10, _target getDir _unit];
    // find bushes
    _cover = (nearestTerrainObjects [ _coverPos, ["BUSH", "TREE", "SMALL TREE", "HIDE"], 45, true, true]) apply {_x getPos [1.2, _target getDir _x]};

    // add buildings
    _cover append ([_coverPos, 35, true, true] call EFUNC(main,findBuildings));
};

// disperse and hide unit
{
    // ready
    doStop _x;
    _x setUnitPosWeak "DOWN";
    _x doWatch _target;

    // disperse!
    if !(_cover isEqualTo []) then {
        _x doMove (_cover deleteAt 0);
        _x setVariable [QGVAR(currentTask), "Group Hide!", EGVAR(main,debug_functions)];
    };
} forEach _units;

// find launcher and armour
private _launchers = _units select {(secondaryWeapon _x) isEqualTo ""};

// find enemy air/tanks
private _enemies = _unit targets [true, 600, [], 0, _target];
private _tankAir = _enemies findIf {(vehicle _x) isKindOf "Tank" || {(vehicle _x) isKindOf "Air"}};

if (_antiTank && { _tankAir != -1 } && { !(_launchers isEqualTo []) }) then {
    {
        // launcher units target air/tank
        _x setCombatMode "RED";
        _x commandTarget (_enemies select _tankAir);

        // extra impetuous to select launcher
        _x selectWeapon (secondaryWeapon _x);
        _x setUnitPosWeak "MIDDLE";
    } forEach _launchers;

    // extra aggression from unit
    _unit doFire (_enemies select _tankAir);
};

// debug
if (EGVAR(main,debug_functions)) then {
    ["%1 TACTICS HIDE %2 (cover %3)", side _unit, groupId _group, count _cover] call EFUNC(main,debugLog);
    private _m = [_unit, "", _unit call EFUNC(main,debugMarkerColor), "hd_ambush"] call EFUNC(main,dotMarker);
    _m setMarkerSizeLocal [0.6, 0.6];
    _m setMarkerDirLocal ((_unit getDir _target) - 90);
    [{{deleteMarker _x;true} count _this;}, [_m], _delay + 30] call CBA_fnc_waitAndExecute;
};

// end
true
