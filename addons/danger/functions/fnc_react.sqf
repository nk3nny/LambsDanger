#include "script_component.hpp"
// React to contact 
// version 1.43
// by nkenny 

// init
params ["_unit","_pos","_leader"];

// set range 
private _range = linearConversion [ 0, 150, (_unit distance2d _pos), 12, 55, true];

// drop down!
_stance = (if (_unit distance2d (nearestBuilding _unit) < ( 20 + random 20 ) || {_unit call FUNC(indoor)}) then {"MIDDLE"} else {selectRandom ["DOWN","DOWN","MIDDLE"]});
_unit setUnitPos _stance;

// Share information!
[_unit, (_unit findNearestEnemy _pos), GVAR(radio_shout) + random 100, true] call FUNC(shareInformation);

// leaders gestures
[formationLeader _unit,["GestureCover","GestureCeaseFire"]] call FUNC(gesture);

// leaders tell their subordinates!
if (_leader) then {

    // leaders get their subordinates to hide!
    private _buildings = [_unit,_range,true,true] call FUNC(findBuildings);
    {
        [_x,_pos,_range,_buildings] call FUNC(hideInside);
        _timeout = _timeout + 3;
    } foreach ((units group _unit) select {_x distance2d _unit < 80 && { unitReady _x } && { isNull objectParent _x }});
} else {
    [_unit,_pos,_range] call FUNC(hideInside);
};

// delcare contact!
[_unit,1,_pos] call FUNC(leaderMode);

// end
true