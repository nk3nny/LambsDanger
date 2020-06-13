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
private _range = linearConversion [ 0, 150, (_unit distance2D _pos), 12, 35, true];
private _stealth = behaviour _unit isEqualTo "STEALTH";

// drop down!
private _stance = [selectRandom ["DOWN", "DOWN", "MIDDLE"], "MIDDLE"] select (_unit distance2D (nearestBuilding _unit) < _range || {_unit call EFUNC(main,isIndoor)});
_unit setUnitPos _stance;

// sort enemy
if (isNull _enemy) then {_enemy = _unit findNearestEnemy _pos;};

// Share information!
[_unit, _enemy, GVAR(radio_shout), true] call FUNC(shareInformation);

// leaders gestures
if (count units _unit > 1) then {[formationLeader _unit, ["gestureFreeze"]] call EFUNC(main,doGesture);};

// Callout
_enemy = vehicle _enemy;
private _callout = if (isText (configFile >> "CfgVehicles" >> typeOf _enemy >> "nameSound")) then {
    getText (configFile >> "CfgVehicles" >> typeOf _enemy >> "nameSound")
} else {
    "contact"
};
[ [formationLeader _unit, _unit] select (RND(0.33)), ["Combat", "Stealth"] select _stealth, _callout, 100] call EFUNC(main,doCallout);

// stealth ~ exits early to retain sneakiness or speed
if (_stealth || {speedMode _unit isEqualTo "FULL"}) exitWith {
    true
};

// get units
private _units = [_unit] call EFUNC(main,findReadyUnits);
_units = _units select { currentCommand _x isEqualTo "" };

// leaders get their subordinates to hide!
private _buildings = [_unit, _range + 5, true, true] call EFUNC(main,findBuildings);
{
    [_x, _pos, _range, _buildings] call FUNC(doHide);
} foreach _units;

// caller slowdown!
if (count _units > 1) then {
    (leader _unit) forceSpeed 1;
};

// end
true
