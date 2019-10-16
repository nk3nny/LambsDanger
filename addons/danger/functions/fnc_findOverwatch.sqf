#include "script_component.hpp"
/*
 * Author: jokoho482
 * Returns Overwatch Positions
 *
 * Warning:
 * It is possible that this function does not Generate any Posisions and Returns a Empty Array!
 *
 * Arguments:
 * 0: Target Position <Vector3>
 * 1: Maximum distance from Target in meters <Vector3>
 * 2: Minimum distance from Target in meters <Number>
 * 3: Minimum height in relation to Target in meters <Number>
 * 4: Position to start looking from <Number>
 *
 * Return Value:
 * Position of a Possible Overwatch Position
 *
 * Example:
 * [getPos bob, 10, 50, 8, getPos jonny] call lambs_danger_fnc_findOverwatch;
 *
 * Public: No
*/
scriptName QGVAR(findOverwatch);
scopeName QGVAR(findOverwatch);

params ["_targetPos", "_maxRange", "_minRange", "_minHeight", "_centerPos"];
private _refObj = nearestObject [_targetPos, "All"];
private _result = [];
private _selectedPositions = [];

private _fnc_selectResult = {
    //Found position(s)
    _result = _selectedPositions select 0;
    private _maximum = (_refObj worldToModel _result) select 2;
    {
        private _height = (_refObj worldToModel _x) select 2;
        if (_height > _maximum) then {
            _result = _x;
            _maximum = _height;
        };
    } forEach _selectedPositions;
    _result breakOut QGVAR(findOverwatch);
};

for "_i" from 0 to 300 do {
    private _checkPos = [_centerPos, 0, _maxRange, 3, 0, 50, 0, [], []] call BIS_fnc_findSafePos;
    private _height = (_refObj worldToModel _checkPos) select 2;
    private _dis = _checkPos distance _targetPos;

    private _terrainBlocked = terrainIntersect [_targetPos,_checkPos];

    private _distCheck = (_dis > _minRange);
    // Get atleast one Fallback Position
    if (_result isEqualTo [] && _distCheck) then {
        if !(_terrainBlocked) then {
            _result = _checkPos;
        };
    };

    if ((_height > _minHeight) && _distCheck) then {
        if !(_terrainBlocked) then {
            _selectedPositions pushback _checkPos;
        };
    };
    if (count _selectedPositions >= 5) then {
        call _fnc_selectResult;
    };
};

if !(_selectedPositions isEqualTo []) then {
    call _fnc_selectResult;
} else {
    if (_result isEqualTo []) then {
        _result = _centerPos;
    };
};
_result
