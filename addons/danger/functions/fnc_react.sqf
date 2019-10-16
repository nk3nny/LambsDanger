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
 * [bob,getpos angryJoe, false] call lambs_danger_fnc_react;
 *
 * Public: Yes
*/
params ["_unit", "_pos", ["_leader",false]];

// set range
private _range = linearConversion [ 0, 150, (_unit distance2d _pos), 12, 55, true];

// drop down!
private _stance = (if (_unit distance2d (nearestBuilding _unit) < ( 20 + random 20 ) || {_unit call FUNC(indoor)}) then {"MIDDLE"} else {selectRandom ["DOWN","DOWN","MIDDLE"]});
_unit setUnitPos _stance;

// Share information!
[_unit, (_unit findNearestEnemy _pos), GVAR(radio_shout) + random 100, true] call FUNC(shareInformation);

// leaders gestures
[formationLeader _unit, ["GestureCover", "GestureCeaseFire"]] call FUNC(gesture);

// leaders tell their subordinates!
if (_leader) then {

    // get units
    private _units = ((units _unit) select {_x distance2d _unit < 100 && { unitReady _x } && { isNull objectParent _x }});

    // leaders get their subordinates to hide!
    private _buildings = [_unit, _range, true, true] call FUNC(findBuildings);
    {
        [_x, _pos, _range, _buildings] call FUNC(hideInside);
    } foreach _units;
} else {
    [_unit, _pos, _range] call FUNC(hideInside);
};

// declare contact!
[_unit, 1, _pos] call FUNC(leaderMode);

// end
true
