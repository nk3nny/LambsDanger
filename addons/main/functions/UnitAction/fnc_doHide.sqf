#include "script_component.hpp"
/*
 * Author: nkenny
 * Unit hides inside building or in nearby cover position
 *
 * Arguments:
 * 0: unit hiding <OBJECT>
 * 1: source of danger <OBJECT> or position <ARRAY>
 * 2: range to search for cover and concealment, default is 50 <NUMBER>
 * 3: array of predetermined building positions <ARRAY>
 *
 * Return Value:
 * boolean
 *
 * Example:
 * [bob, angryJoe, 30] call lambs_main_fnc_doHide;
 *
 * Public: No
*/
params ["_unit", "_pos", ["_range", 35], ["_buildings", []]];

// stopped -- exit
if (
    (currentCommand _unit) in ["GET IN", "ACTION", "HEAL"]
    || {!(_unit checkAIFeature "PATH")}
    || {!(_unit checkAIFeature "MOVE")}
) exitWith {false};

// do nothing when already inside
if (RND(GVAR(indoorMove)) && {_unit call FUNC(isIndoor)}) exitWith {
    doStop _unit;
    false
};

// define buildings
if (_buildings isEqualTo []) then {
    _buildings = [_unit, _range, true, true] call FUNC(findBuildings);
};

// variables
_unit setVariable [QGVAR(currentTarget), _pos, GVAR(debug_functions)];
_unit setVariable [QGVAR(currentTask), "Hide!", GVAR(debug_functions)];

// stop
doStop _unit;
_unit forceSpeed 24;

// Randomly scatter into buildings or hide!
if (RND(0.1) && { _buildings isNotEqualTo [] }) exitWith {

    // update variable
    _unit setVariable [QGVAR(currentTask), "Hide (inside)", GVAR(debug_functions)];

    // execute move
    _unit setUnitPosWeak "MIDDLE";
    _unit doMove (selectRandom _buildings);

    // debug
    if (GVAR(debug_functions)) then {
        ["%1 hide in building (%2 - %3x positions)", side _unit, name _unit, count _buildings] call FUNC(debugLog);
    };
};

// hide
_unit setUnitPosWeak "DOWN";

// check for rear-cover
private _cover = nearestTerrainObjects [ _unit getPos [1, getDir _unit], ["BUSH", "TREE", "SMALL TREE", "HIDE", "ROCK", "WALL", "FENCE"], 9, true, true ];

// targetPos
private _targetPos = if (_cover isEqualTo []) then {
    _unit getPos [10 + random _range, (_pos getDir _unit) + 45 - random 90]
} else {
    (_cover select 0) getPos [-1.2, _unit getDir (_cover select 0)]
};

// water means hold
if (surfaceIsWater _targetPos) then {_targetPos = getPosASL _unit;};

// cover move
//[_unit, _targetPos] call FUNC(doCover);
_unit doMove _targetPos;

// debug
if (GVAR(debug_functions)) then {
    ["%1 hide in bush (%2)", side _unit, name _unit] call FUNC(debugLog);
};

// end
true
