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
params ["_unit", ["_range", 100], ["_useHousePos", false], ["_onlyIndoor", false]];

// houses
private _houses = nearestObjects [_unit, ["House", "Strategic", "Ruins"], _range, true];
_houses = _houses select {!((_x buildingPos -1) isEqualTo [])};

// house pos
if (!_useHousePos) exitWith {_houses}; // return if not use House Pos
private _housePos = [];
{_housePos append (_x buildingPos -1); true} count _houses;

// sort indoor
if (_onlyIndoor) then {
    _housePos = _housePos select {
        private _pos = AGLToASL _x;
        lineIntersects [_pos, _pos vectorAdd [0, 0, 6]]
    };
};
// return
_housePos;
