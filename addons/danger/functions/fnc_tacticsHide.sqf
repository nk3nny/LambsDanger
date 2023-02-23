#include "script_component.hpp"
/*
 * Author: nkenny
 * Leader calls for group to disperse into cover a special mode with optional anti-armour tactics
 *
 * Arguments:
 * 0: group executing tactics <GROUP> or group leader <UNIT>
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

params ["_group", "_target", ["_antiTank", false], ["_cover", []], ["_delay", 240]];

// group is missing
if (isNull _group) exitWith {false};

// get leader
if (_group isEqualType objNull) then {_group = group _group;};
if ((units _group) isEqualTo []) exitWith {false};
private _unit = leader _group;

// find target
_target = _target call CBA_fnc_getPos;

// reset tactics
[
    {
        params [["_group", grpNull], ["_combatMode", "YELLOW"], ["_enableAttack", false], ["_formation", "WEDGE"]];
        if (!isNull _group) then {
            _group setVariable [QGVAR(isExecutingTactic), nil];
            _group setVariable [QEGVAR(main,currentTactic), nil];
            _group setCombatMode _combatMode;
            _group enableAttack _enableAttack;
            _group setFormation _formation;
            {_x doFollow (leader _x)} foreach units _group;
        };
    },
    [_group, combatMode _group, attackEnabled _group, formation _group],
    _delay
] call CBA_fnc_waitAndExecute;

// hold-fire combat mode
_group setFormation "DIAMOND";
_group setCombatMode "GREEN";
_group enableAttack false;

_unit setVariable [QEGVAR(main,currentTarget), _target, EGVAR(main,debug_functions)];
_unit setVariable [QEGVAR(main,currentTask), "Leader Hide", EGVAR(main,debug_functions)];

// set group task
_group setVariable [QEGVAR(main,currentTactic), "Hiding", EGVAR(main,debug_functions)];

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

// disperse and hide unit ~ notice that cover is added as building positions nkenny
[_units, _target, _cover] call EFUNC(main,doGroupHide);

// find launcher and armour
private _launchers = _units select {(secondaryWeapon _x) isNotEqualTo ""};

// find enemy air/tanks
private _enemies = _unit targets [true, 600, [], 0, _target];
private _tankAir = _enemies findIf {(vehicle _x) isKindOf "Tank" || {(vehicle _x) isKindOf "Air"}};

if (_antiTank && { _tankAir != -1 } && { _launchers isNotEqualTo [] }) then {
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
    private _m = [_unit, "tactics hide", _unit call EFUNC(main,debugMarkerColor), "hd_ambush"] call EFUNC(main,dotMarker);
    _m setMarkerSizeLocal [0.6, 0.6];
    _m setMarkerDirLocal ((_unit getDir _target) - 90);
    [{{deleteMarker _x;true} count _this;}, [_m], _delay + 30] call CBA_fnc_waitAndExecute;
};

// end
true
