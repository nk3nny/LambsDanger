#include "script_component.hpp"
// Task Camp (defense)
// version 2.1
// by nkenny


/*
** NOT CURRENTLY IMPLEMENTED **

Nice little halfcircle of troops
populate one turret and one building if nearby.

*/
if !(canSuspend) exitWith {
    _this spawn FUNC(taskCamp);
};
// init
params ["_group", ["_range", 62], ["_area", [], [[]]]];

// sort grp ---
if (!local _group) exitWith {false};
if (_group isEqualType objNull) then {_group = group _group};
private _units = units _group;

// orders ---
_group setBehaviour "SAFE";
_group setSpeedMode "LIMITED";
_group setCombatMode "YELLOW";
_group setFormation selectRandom ["STAG COLUMN", "WEDGE", "ECH LEFT", "ECH RIGHT", "VEE"];
//_group enableGunLights "forceOn";

// pos
private _pos = getPos (leader _group);

// find buildings ---
private _buildings = nearestObjects [_pos, ["house", "strategic"], _range, true];
_buildings = _buildings select {count (_x buildingpos -1) > 0};
[_buildings, true] call CBA_fnc_shuffle;

// find guns ---
private _gun = nearestObjects [_pos, ["Landvehicle"], _range, true];
_gun = _gun select {(_x emptyPositions "Gunner") > 0};
if !(_area isEqualTo []) then {
    _area params ["_a", "_b", "_angle", "_isRectangle"];
    _gun = _gun select {(getPos _x) inArea [_pos, _a, _b, _angle, _isRectangle]};
    _buildings = _buildings select {(getPos _x) inArea [_pos, _a, _b, _angle, _isRectangle]};
};

// STAGE 1 - PATROL --------------------------

if (count _units > 4) then {
    private _group2 = createGroup (side _group);
    [selectRandom _units] join _group2;
    if (count _units > 6)  then { [selectRandom units _group] join _group2; };

    // performance
    _group2 enableDynamicSimulation true;
    _group2 deleteGroupWhenEmpty true;

    // id
    _group2 setGroupIDGlobal [format ["Patrol (%1)", groupId _group2]];

    // orders
    if (_area isEqualTo []) then {
        [_group2, _range * 2] call FUNC(taskPatrol);
    } else {
        private _area2 = +_area;
        _area2 set [0, (_area2 select 0) * 2];
        _area2 set [0, (_area2 select 1) * 2];
        [_group2, _range * 2, 4, _area2] call FUNC(taskPatrol);
    };

    // update
    _units = units _group;
};

// STAGE 2 - GUNS & BUILDINGS ---------------
reverse _units;
{
    // gun
    if (count _gun > 0) then {
        _x moveInGunner (_gun deleteAt 0);
        _units set [_foreachIndex, objNull];
    };

    if (!(_buildings isEqualTo []) && { RND(0.3) }) then {
        doStop _x;
        _x setUnitPos "UP";
        _x setPos selectRandom ((_buildings deleteAt 0) buildingPos -1);
        _units set [_foreachIndex, objNull];
    };

    if (count _units < count units _group/2) exitWith {};

} forEach _units;

_units = _units - [objNull];

// STAGE 3 - STAND ABOUT ----------------
{
    private _dir = random 360;
    private _range = 1.3 + random 3.3;
    private _pos2 = [(_pos select 0) + (sin _dir) * _range, (_pos select 1) + (cos _dir) * _range, 0];
    _x move _pos2;
    _x disableAI "ANIM";
    _x playActionNow selectRandom ["SitDown", "SitDown", "SitDown", "Relax", "stand"];
    _x addEventHandler ["Hit", {(_this select 0) enableAI "ANIM";}];
    true
} count _units;

// TRIGGER!
waitUntil { (behaviour (leader _group)) isEqualTo "COMBAT" || {!((leader _group) call EFUNC(danger,isAlive))}};
_group setCombatMode "RED";
{
    //_x switchmove "";
    _x playActionNow selectRandom ["Stand", "Up", "EvasiveLeft", "EvasiveRight", "MountOptic", "MountSide", "Down", "Default"];
    _x enableAI "ANIM";
    if (RND(0.5)) then { _x suppressFor (3 + random 7); };
    true
} count _units;

// end
true
