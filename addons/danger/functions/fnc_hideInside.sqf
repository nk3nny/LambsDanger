#include "script_component.hpp"
/*
 * Author: nkenny
 * Unit hides inside building or in nearby cover position
 *
 * Arguments:
 * 0: Unit hiding <OBJECT>
 * 1: Source of danger <OBJECT> or position <ARRAY>
 * 2: Range to search for cover and concealment, default is 50 <NUMBER>
 * 3: Array of predetermined building positions <ARRAY>
 *
 * Return Value:
 * boolean
 *
 * Example:
 * [bob, angryJoe, 30] call lambs_danger_fnc_hideInside;
 *
 * Public: No
*/
params ["_unit", "_danger", ["_range", 55], ["_buildings", []]];

// stopped -- exit
if (
    stopped _unit
    || {!(_unit checkAIFeature "PATH")}
    || {!(_unit checkAIFeature "MOVE")}
    || {currentCommand _unit in ["GET IN", "ACTION", "HEAL"]}
    || {isPlayer _unit}
) exitWith {false};

if (_buildings isEqualTo []) then {
    _buildings = [_unit, _range, true, true] call FUNC(findBuildings);
};

// already inside -- exit
if (RND(0.05) && {_unit call FUNC(indoor)}) exitWith {
    if (stance _unit isEqualTo "STAND") then { _unit setUnitPosWeak "MIDDLE"; };
    _unit doWatch _danger;
    false
};

// variables
_unit setVariable [QGVAR(currentTarget), _danger];
_unit setVariable [QGVAR(currentTask), "Hide"];

// settings
_unit forceSpeed (selectRandom [-1, 24, 24]);

// Randomly scatter into buildings or hide!
if (!(_buildings isEqualTo []) && { RND(0.05) }) then {
    _unit setVariable [QGVAR(currentTask), "Hide (inside)"];
    doStop _unit;
    _unit doMove ((selectRandom _buildings) vectorAdd [0.7 - random 1.4, 0.7 - random 1.4, 0]);
    _unit setUnitPosWeak "MIDDLE";
    if (GVAR(debug_functions)) then {systemchat format ["%1 hide in building", side _unit];};

} else {
    _unit setUnitPosWeak "DOWN";
    // Get General Target Position
    private _targetPos = (_unit getPos [35 + random _range, (_danger getDir _unit) + 45 - random 90]);
    // Find Surrounding Bushes and Rocks
    private _objs = nearestTerrainObjects [_targetPos, ["BUSH", "TREE", "SMALL TREE", "HIDE"], 13, false, true];
    if !(_objs isEqualTo []) then {
        // if a Rock or Bush is found set it as target Pos
        _targetPos = getPos (selectRandom _objs);
    };

    if (surfaceIsWater _targetPos) exitWith { _unit suppressFor 5; };
    _unit doMove _targetPos;
    if (GVAR(debug_functions)) then {systemchat format ["%1 hide in bush", side _unit];};
};

// end
true
