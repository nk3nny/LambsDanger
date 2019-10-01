#include "script_component.hpp"
/*
 * Author: diwako
 * Returns position and stance of closest possible cover location.
 *
 * Arguments:
 * 0: Unit seeking cover <OBJECT>
 * 1: Enemy <OBJECT> or Enemy Position (AGL) <ARRAY>
 * 2: Range to find cover, default 15 <NUMBER>
 *
 * Return Value:
 * Array of format [_posAGL, _stance], when no cover found then an empty array is returned
 * Stance can be "UP", "MIDDLE" or "DOWN"
 *
 * Example:
 * [bob, angryJoe, 50] call lambs_danger_fnc_findCover
 *
 * Public: Yes
*/
params ["_unit", ["_enemy", objNull, [objNull,[]]], ["_range", 15, [0]]];

private _ret = [];
private _dangerPos = (_enemy call CBA_fnc_getPos) vectorAdd [0,0,1.8];

if !(_dangerPos isEqualTo [0,0,1.8]) then {
    _dangerPos = AGLToASL _dangerPos;
    private _terrainObjects = nearestTerrainObjects [_unit, ["BUSH", "TREE", "SMALL TREE", "HIDE", "BUILDING"], _range, false, true];
    private _vehicles = (_unit nearObjects ["Car", _range]) select {isNull (driver _x)};

    private _allObjs = (_terrainObjects + _vehicles) apply { [_x distance2d _unit, _x] };
    _allObjs sort false;
    _allObjs = _allObjs apply {_x select 1};

    private _found = false;
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
            if !(_ret isEqualTo []) exitWith {};
            if ((_dangerPos distance2d _x) > 20) then {
                _pos = _x;
                _posASL = AGLToASL _x;

                // check down position
                if (lineIntersects [_dangerPos, _posASL vectorAdd [0,0,0.1], _unit]) exitWith {
                    private _stances = ["DOWN"];
                    // check middle position
                    if (lineIntersects [_dangerPos, _posASL vectorAdd [0,0,1], _unit]) then {
                        _stances pushBack "MIDDLE";
                        // check up position
                        if (lineIntersects [_dangerPos, _posASL vectorAdd [0,0,1], _unit]) then {
                            _stances pushBack "UP";
                        };
                    };
                    _ret = [_pos, selectRandom _stances];
                    _found = true;
                };
            };
        } forEach _buildingPos
    };
};

if (GVAR(debug_functions) && {!(_ret isEqualTo [])}) then {
	private _stance = _ret select 1;
	systemchat format ["Found cover %1m away for stance %2", _unit distance (_ret select 0), _stance];
    createVehicle ["Sign_Arrow_Large_F", (_enemy call CBA_fnc_getPos) vectorAdd [0,0,1.8],[],0,"CAN_COLLIDE"];
    private _add = if ((_stance) isEqualTo "UP") then {
        2
    } else {
        if ((_stance) isEqualTo "MIDDLE") then {
            1
        } else {
            0.2
        };
    };
    createVehicle ["Sign_Arrow_Large_Blue_F",(_ret select 0) vectorAdd [0,0,_add],[],0,"CAN_COLLIDE"];
};

_ret
