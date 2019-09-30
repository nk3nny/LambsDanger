#include "script_component.hpp"
// Finds and declares nearest building as assault position
// version 1.0
// by nkenny

// init
params ["_unit",["_range",GVAR(CQB_range)]];

// new variable + distance check
_inCQC = group _unit getVariable ["inCQC",[]];
_inCQC = _inCQC select {_x distance2d _unit < 250};

// buildings present? ignore
if (count _inCQC > 0) exitWith {};

// define buildings
private _buildings = [_unit,_range] call FUNC(nearBuildings);
_buildings = _buildings select {count (_x getVariable ["LAMBS_CQB_cleared_" + str (side _unit),[0,0]]) > 0};

// update variable
{
    _inCQC pushBackUnique _x;
    true
} count _buildings;
group _unit setVariable ["inCQC",_inCQC];

// end
_buildings

