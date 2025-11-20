#include "script_component.hpp"
/*
 * Author: jokoho482
 * Returns Overwatch Positions
 *
 *
 * Arguments:
 * 0: Target Position <ARRAY>
 * 1: Maximum distance from Target in meters <NUMBER>
 * 2: Minimum distance from Target in meters <NUMBER>
 * 3: Minimum height in relation to Target in meters <NUMBER>
 * 4: Position to start looking from <ARRAY>
 * 5: Select the lowest position <BOOL>
 *
 * Return Value:
 * Position of a Possible Overwatch Position
 *
 * Example:
 * [getPos bob, 10, 50, 8, getPos jonny] call lambs_main_fnc_findOverwatch;
 *
 * Public: Yes
*/
scriptName QGVAR(findOverwatch);
scopeName QGVAR(findOverwatch);

params [
    ["_targetPos", [0, 0, 0], [[]]],
    ["_maxRange", 50, [0]],
    ["_minRange", 10, [0]],
    ["_minHeight", 8, [0]],
    ["_centerPos", [0, 0, 0], [[]]],
    ["_lowestPosition", true, [true]]
];
private _refObj = nearestObject [_targetPos, "All"];
private _result = [];
private _selectedPositions = [];

// sort found position(s)
private _fnc_selectResult = {
    _selectedPositions sort _lowestPosition;

    _result = (_selectedPositions param [0]) param [1, _centerPos];

    _result breakOut QGVAR(findOverwatch);
};

for "_i" from 0 to 15 do {
    private _checkPos = [_centerPos, 0, _maxRange, 0, 0, 50, 0, [], [_centerPos, _centerPos]] call BIS_fnc_findSafePos;

    private _distCheck = (_checkPos distance _targetPos) > _minRange;
    private _terrainBlocked = terrainIntersect [_targetPos, _checkPos vectorAdd [0, 0, 2]];
    if (_distCheck && !_terrainBlocked) then {

        // Get at least one Fallback Position
        if (_result isEqualTo []) then {
            _result = _checkPos;
        };

        // check height
        private _height = (_refObj worldToModel _checkPos) select 2;
        if (_height > _minHeight) then {
            _selectedPositions pushBack [_height, _checkPos];
        };

    };

    // exit on 3 positions
    if ((count _selectedPositions) isEqualTo 3) then {
        call _fnc_selectResult;
    };
};

if (_selectedPositions isNotEqualTo []) then {
    call _fnc_selectResult;
} else {
    if (_result isEqualTo []) then {
        _result = _centerPos;
    };
};
_result
