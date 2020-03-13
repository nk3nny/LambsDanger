#include "script_component.hpp"
/*
 * Author: nkenny
 * FSM level reaction to contact
 *
 * Arguments:
 * 0: Unit in panic <OBJECT>
 * 1: Position of danger <ARRAY>
 * 2: Is unit the leader, default false <BOOLEAN>
 *
 * Return Value:
 * success
 *
 * Example:
 * [bob, getpos angryJoe, false] call lambs_danger_fnc_react;
 *
 * Public: No
*/
params ["_unit", "_pos", ["_enemy", objNull]];

// disable Reaction phase for player group
if (isPlayer (leader _unit) && {GVAR(disableAIPlayerGroupReaction)}) exitWith {false};

// set range
private _range = linearConversion [ 0, 150, (_unit distance2d _pos), 12, 35, true];

// drop down!
private _stance = ["MIDDLE", selectRandom ["DOWN", "DOWN", "MIDDLE"]] select (_unit distance2d (nearestBuilding _unit) < _range || {_unit call FUNC(indoor)});
_unit setUnitPos _stance;

// sort enemy
if (isNull _enemy) then {_enemy = _unit findNearestEnemy _pos;};

// Share information!
[_unit, _enemy, GVAR(radio_shout), true] call FUNC(shareInformation);

// Callout
_enemy = vehicle _enemy;
private _callout = if (isText (configFile >> "CfgVehicles" >> typeOf _enemy >> "nameSound")) then {
    getText (configFile >> "CfgVehicles" >> typeOf _enemy >> "nameSound")
} else {
    "contact"
};
[ [formationLeader _unit, _unit] select (RND(0.5)), "Combat", _callout, 100] call FUNC(doCallout);

// leaders gestures
[formationLeader _unit, ["GestureCover", "GestureCeaseFire"]] call FUNC(gesture);

// get units
private _units = ((units _unit) select { _x call FUNC(isAlive) && {_x distance2d _unit < 120} && { unitReady _x } && { isNull objectParent _x } && {!isPlayer _x}});

// leaders get their subordinates to hide!
private _buildings = [_unit, _range, true, true] call FUNC(findBuildings);
{
    [_x, _pos, _range + 15, _buildings] call FUNC(hideInside);
} foreach _units;

// caller slowdown!
if (count _units > 1) then {
    (leader _unit) forceSpeed 1;
};

// leadermode update
[_unit, 1, _pos] call FUNC(leaderMode);

// end
true
