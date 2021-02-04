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
 * [bob, angryJoe] call lambs_danger_fnc_tacticsHide;
 *
 * Public: No
*/
#define RETREAT_DISTANCE 8
#define COVER_DISTANCE 15
#define BUILDING_DISTANCE 25

params ["_unit", "_target", ["_antiTank", false], ["_cover", []], ["_delay", 240]];

// find target
_target = _target call CBA_fnc_getPos;

// reset tactics
private _group = group _unit;
[
    {
        params [["_group", grpNull], ["_combatMode", "YELLOW"], ["_enableAttack", false], ["_formation", "WEDGE"]];
        if (!isNull _group) then {
            _group setVariable [QGVAR(isExecutingTactic), nil];
            _group setVariable [QGVAR(tacticsTask), nil];
            _group setCombatMode _combatMode;
            _group enableAttack _enableAttack;
            _group setFormation _formation;
            {_x doFollow (leader _x)} foreach units _group;
        };
    },
    [_group, combatMode _group, attackEnabled _group, formation _group],
    _delay
] call CBA_fnc_waitAndExecute;

// alive unit
if !(_unit call EFUNC(main,isAlive)) exitWith {false};

// hold-fire combat mode
_unit setBehaviour "COMBAT";
_group setFormation "DIAMOND";
_group setCombatMode "GREEN";
_group enableAttack false;

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
_units = _units select {
    _x call EFUNC(main,isAlive)
    && {isNull objectParent _x}
    && {_x checkAIFeature "PATH"}
    && {_x checkAIFeature "MOVE"}
    && {!(_x call EFUNC(main,isIndoor))}
};
if (_units isEqualTo []) exitWith {false};

// find cover
if (_cover isEqualTo []) then {
    private _coverPos = _unit getPos [RETREAT_DISTANCE, _target getDir _unit];
    // find bushes
    _cover = (nearestTerrainObjects [ _unit, ["BUSH", "TREE", "SMALL TREE", "HIDE"], COVER_DISTANCE, true, true]) apply {_x getPos [1.5, _target getDir _x]};

    // add buildings
    _cover append ([_coverPos, BUILDING_DISTANCE, true, true] call EFUNC(main,findBuildings));

    // remove those closer to enemy
    private _distance2D = (_unit distance2D _target) + 2;
    _cover = _cover select {_x distance2D _target > _distance2D;};
};

// unit commands
_units doWatch objNull;
doStop _units;

// disperse and hide unit
{
    // ready
    _x setUnitPosWeak "DOWN";

    // disperse!
    if !(_cover isEqualTo []) then {
        [
            {
                params ["_unit", "_pos"];
                _unit moveTo _pos;
                _unit setDestination [_pos, "FORMATION PLANNED", true];
            }, [_x, _cover deleteAt 0], random 2
        ] call CBA_fnc_waitAndExecute;
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
    ["%1 TACTICS HIDE %2 (cover %3)%4", side _unit, groupId _group, count _cover, ["", " (anti tank/air)"] select _antiTank] call EFUNC(main,debugLog);
    private _m = [_unit, "", _unit call EFUNC(main,debugMarkerColor), "hd_ambush"] call EFUNC(main,dotMarker);
    _m setMarkerSizeLocal [0.6, 0.6];
    _m setMarkerDirLocal ((_unit getDir _target) - 90);
    [{{deleteMarker _x;true} count _this;}, [_m], _delay + 30] call CBA_fnc_waitAndExecute;
};

// end
true
