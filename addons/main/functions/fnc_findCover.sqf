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

if !(_dangerPos isEqualTo [0, 0, 1.8]) then {
    _dangerPos = AGLToASL _dangerPos;
    private _terrainObjects = nearestTerrainObjects [_unit, ["BUSH", "TREE", "SMALL TREE", "HIDE", "BUILDING"], _range, false, true];
    private _vehicles = nearestObjects  [_unit, ["building", "Car"], _range];

    private _allObjs = [];
    if(_sortMode in ["ASCEND", "DESCEND"]) then {
        _allObjs = [_terrainObjects + _vehicles, [], {_unit distance2D _x}, _sortMode] call BIS_fnc_sortBy;
    } else {
       _allObjs = (_terrainObjects + _vehicles) call BIS_fnc_arrayShuffle;
    };

    private _found = false;
    private _numFound = 0;
    private _obj = objNull;
    private _pos = [];
    private _posASL = [];
    private _buildingPos = [];

    while {!_found && {!(_allObjs isEqualTo [])}} do {
        _obj = _allObjs deleteAt 0;
        _buildingPos = [_obj, 5] call CBA_fnc_buildingPositions;
        if (_buildingPos isEqualTo []) then {
            (boundingBox _obj) params ["_boundA", "_boundB"];
            _pos = (getPos _obj) vectorAdd (selectRandom [_boundA, _boundB]);
            // there is no building pos, so this is either vegetation or some building without building pos
            // set height to 0 otherwise the pos will be right above the object
            _pos set [2, 0.1];
            _buildingPos = [_pos];
        };

        {
            if (_found) exitWith {};
            if ((_dangerPos distance2d _x) > 20) then {
                _pos = _x;
                _posASL = AGLToASL _x;

                // check down position
                if (lineIntersects [_dangerPos, _posASL vectorAdd [0, 0, 0.1], _unit]) exitWith {
                    private _stances = ["DOWN"];
                    // check middle position
                    if (lineIntersects [_dangerPos, _posASL vectorAdd [0, 0, 1], _unit]) then {
                        _stances pushBack "MIDDLE";
                        // check up position
                        if (lineIntersects [_dangerPos, _posASL vectorAdd [0, 0, 1], _unit]) then {
                            _stances pushBack "UP";
                        };
                    };
                    _ret pushback [_pos, selectRandom _stances];
                    _numFound = _numFound + 1;

                    _found = (!(_maxResults isEqualTo -1) && {_numFound isEqualTo _maxResults});
                };
            };
        } forEach _buildingPos
    };
};

if (GVAR(debug_functions) && {!(_ret isEqualTo [])}) then {
    format ["Found %1 cover positions", count _ret] call FUNC(debugLog);
    {
        "Sign_Arrow_Large_F" createVehicleLocal ((_enemy call CBA_fnc_getPos) vectorAdd [0, 0, 1.8]);
        private _add = if ((_x select 1) isEqualTo "UP") then {
            2
        } else {
            if ((_x select 1) isEqualTo "MIDDLE") then {
                1
            } else {
                0.2
            };
        };
        "Sign_Arrow_Large_Blue_F" createVehicleLocal ((_x select 0) vectorAdd [0, 0, _add]);
    } forEach _ret;
};

_ret
