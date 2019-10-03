#include "script_component.hpp"
// Find nearby buildings
// version 1.41
// by nkenny

/*
    Arguments
    0, _unit         Unit in question            [Object]
    1, _range         Range buildings are found     [Number] (Default 100m)
    2, _housePos    Return house positions         [Boolean] (default false)
    3, _indoor        sort indoor house positions [Boolean] (default false)
*/

// init
params ["_unit", ["_range", 100], ["_housePos", false], ["_onlyIndoor", false]];

// houses
_houses = nearestObjects [_unit, ["House", "Strategic", "Ruins"], _range, true];
_houses = _houses select {count (_x buildingPos -1) > 0};

// house pos
if (_housePos) exitWith {
    _housePos = _houses apply { (_x buildingPos -1) };

    // sort indoor
    if (_onlyIndoor) then {
        _housePos = _housePos select { lineIntersects [AGLToASL _x, (AGLToASL _x) vectorAdd [0, 0, 6]] };
    };
    // return
    _housePos;
};

// return
_houses
