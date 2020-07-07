#include "script_component.hpp"
/*
 * Author: nkenny
 * Finds nearby buildings
 *
 * Arguments:
 * 0: Unit checking <OBJECT> or position <ARRAY>
 * 1: Range to find buildings in meters, default 100 <NUMBER>
 * 2: Should house positions be returned, default false <BOOLEAN>
 * 3: Should only indoor positions be returned, default false <BOOLEAN>
 *
 * Return Value:
 * Array of buildings or house positions
 *
 * Example:
 * [bob, 100, true, true] call lambs_main_fnc_findBuildings;
 *
 * Public: Yes
*/
params [
    ["_unit", objNull, [objNull, []]],
    ["_range", 100, [0]],
    ["_useHousePos", false, [false]],
    ["_onlyIndoor", false, [false]]
];

// houses
private _houses = nearestObjects [_unit, ["House", "Strategic", "Ruins"], _range, true];
_houses = _houses select {!((_x buildingPos -1) isEqualTo [])};

// find house positions
if (!_useHousePos) exitWith {_houses}; // return if not use House Pos
private _housePos = [];
{_housePos append (_x buildingPos -1)} forEach _houses;

// sort indoor positions
if (_onlyIndoor) then {
    _housePos = _housePos select {
        private _pos = AGLToASL _x;
        lineIntersects [_pos, _pos vectorAdd [0, 0, 6]]
    };
};
// return
_housePos
