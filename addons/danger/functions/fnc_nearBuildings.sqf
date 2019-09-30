#include "script_component.hpp"
// Find nearby buildings
// version 1.41
// by nkenny

/*
    Arguments
    0, _unit 		Unit in question			[Object]
    1, _range 		Range buildings are found 	[Number] (Default 100m)
    2, _housePos	Return house positions 		[Boolean] (default false)
    3, _indoor		sort indoor house positions [Boolean] (default false)
*/

// init
params ["_unit",["_range",100],["_housePos",false],["_indoor",false]];

// houses
_houses = nearestObjects [_unit,["House","Strategic","Ruins"],_range,true];
_houses = _houses select {count (_x buildingPos -1) > 0};

// house pos
if (_housePos) then {
    _housePos = [];
    {_housePos append (_x buildingPos -1);true} count _houses;

    // sort indoor
    if (_indoor) then {
        _housePos = _housePos select {lineIntersects [AGLToASL _x, (AGLToASL _x) vectorAdd [0,0,6]]};
    };

    // update array
    _houses = _housePos;
};

// return
_houses


