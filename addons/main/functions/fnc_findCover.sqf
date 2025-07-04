#include "script_component.hpp"
/*
 * Author: diwako
 * Returns position and stance of closest possible cover location.
 *
 * Arguments:
 * 0: Unit seeking cover <OBJECT>
 * 1: Enemy <OBJECT> or Enemy Position (AGL) <ARRAY>
 * 2: Range to find cover, default 15 <NUMBER>
 * 3: Sort mode <STRING>, default "ASCEND", possible values: ASCEND, DESCEND, RANDOM. ASCEND returns closest possible location
 * 4: Max Results <Number>, default 1, Maximum amount of results that can be returned, -1 for all (warning may be slow)
 *
 * Return Value:
 * Array of format [_posAGL, _stance], when no cover found then an empty array is returned
 * Stance can be "UP", "MIDDLE" or "DOWN"
 *
 * Example:
 * [bob, angryJoe, 50] call lambs_main_fnc_findCover
 *
 * Public: Yes
*/
params [
    ["_unit", objNull, [objNull]],
    ["_enemy", objNull, [objNull, []]],
    ["_range", 15, [0]],
    ["_sortMode", "ASCEND", [""]],
    ["_maxResults", 1, [0]]
];

_maxResults = floor _maxResults;
private _ret = [];
if (_maxResults isEqualTo 0) exitWith {_ret};

private _dangerPos = (_enemy call CBA_fnc_getPos) vectorAdd [0, 0, 1.8];
if (_dangerPos isEqualTo [0,0,1.8]) exitWith {_ret};

_dangerPos = AGLToASL _dangerPos;

// Pre-filter objects using bounding-sphere logic, only once
private _terrainObjs = nearestTerrainObjects [_unit, ["BUSH", "TREE", "SMALL TREE", "HIDE", "BUILDING"], _range, false, true];
private _vehicles = nearestObjects [_unit, ["building", "Car"], _range];

// Merge and sort by distance only if not RANDOM
private _allObjs = _terrainObjs + _vehicles;
if (_sortMode in ["ASCEND", "DESCEND"]) then {
    _allObjs = [_allObjs, [], {_unit distance2D _x}, _sortMode] call BIS_fnc_sortBy;
} else {
    _allObjs = _allObjs call BIS_fnc_arrayShuffle;
};

private _found = false;
private _numFound = 0;

// Loop through objects, early exit if max found
{
    private _obj = _x;
    // Use CBA_fnc_buildingPositions (fast, returns [] if not a building)
    private _bPos = [_obj, 5] call CBA_fnc_buildingPositions;
    if (_bPos isEqualTo []) then {
        // Fallback: Calculate a single candidate pos using bounding box corners
        (boundingBox _obj) params ["_a", "_b"];
        private _pos = (getPos _obj) vectorAdd (_a vectorAdd _b) vectorMultiply 0.5;
        _bPos = [_pos];
    };

    // Use only a single candidate per object for max performance
    private _pos = _bPos select 0;
    if (!isNil "_pos" && {(_dangerPos distance2D _pos) > 20}) then {
        private _posASL = AGLToASL _pos;
        // Only check DOWN stance first for performance
        if (lineIntersects [_dangerPos, _posASL vectorAdd [0,0,0.1], _unit]) then {
            _ret pushBack [_pos, "DOWN"];
            _numFound = _numFound + 1;
            if ((_maxResults != -1) && {_numFound >= _maxResults}) exitWith {_found = true};
        };
    };
    if (_found) exitWith {};
} forEach _allObjs;

if (GVAR(debug_functions) && {(_ret isNotEqualTo [])}) then {
    ["Found %1 cover positions", count _ret] call FUNC(debugLog);
};

_ret
