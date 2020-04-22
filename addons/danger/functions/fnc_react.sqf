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
 * [bob, getPos angryJoe, false] call lambs_danger_fnc_react;
 *
 * Public: No
*/
params ["_unit", "_pos", ["_enemy", objNull]];

// leadermode update
[_unit, 1, _pos] call FUNC(leaderMode);

// disable Reaction phase for player group
if (isPlayer (leader _unit) && {GVAR(disableAIPlayerGroupReaction)}) exitWith {false};

// set range
private _range = linearConversion [ 0, 150, (_unit distance2d _pos), 12, 35, true];
private _stealth = behaviour _unit isEqualTo "STEALTH";

// drop down!
private _stance = [selectRandom ["DOWN", "DOWN", "MIDDLE"], "MIDDLE"] select (_unit distance2d (nearestBuilding _unit) < _range || {_unit call FUNC(indoor)});
_unit setUnitPos _stance;

// sort enemy
if (isNull _enemy) then {_enemy = _unit findNearestEnemy _pos;};

// Share information!
[_unit, _enemy, GVAR(radio_shout), true] call FUNC(shareInformation);

// leaders gestures
if (count units _unit > 1) then {[formationLeader _unit, ["gestureFreeze"]] call FUNC(gesture);};

// Callout
_enemy = vehicle _enemy;
private _callout = if (isText (configFile >> "CfgVehicles" >> typeOf _enemy >> "nameSound")) then {
    getText (configFile >> "CfgVehicles" >> typeOf _enemy >> "nameSound")
} else {
    "contact"
};
[ [formationLeader _unit, _unit] select (RND(0.33)), ["Combat", "Stealth"] select _stealth, _callout, 100] call FUNC(doCallout);

// stealth ~ exits early to retain sneakiness or speed
if (_stealth || {speedMode _unit isEqualTo "FULL"}) exitWith {
    true
};

// get units
private _units = [_unit] call FUNC(findReadyUnits);
_units = _units select { currentCommand _x isEqualTo "" };

// leaders get their subordinates to hide!
private _buildings = [_unit, _range + 5, true, true] call FUNC(findBuildings);
{

    [_x, _pos, _range, _buildings] call FUNC(hideInside);

} foreach _units;

// caller slowdown!
if (count _units > 1) then {

    (leader _unit) forceSpeed 1;

};

// end
true
