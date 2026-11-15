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
 * [bob, angryJoe] call lambs_main_fnc_doHide;
 *
 * Public: No
*/
params ["_unit", "_pos", ["_range", 35], ["_buildings", []]];

// stopped -- exit
if (
    (currentCommand _unit) in ["GET IN", "ACTION", "HEAL"]
    || !(_unit checkAIFeature "PATH")
    || !(_unit checkAIFeature "MOVE")
) exitWith {false};

// Reset stance hard stance changes
[_unit, true] call FUNC(doStanceReset);

// do nothing when already inside
if (RND(GVAR(indoorMove)) && {_unit call FUNC(isIndoor)}) exitWith {
    _unit setUnitPos "DOWN";
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

// set speed
_unit forceSpeed 24;

// Randomly scatter into buildings or hide!
if ( RND(0.2) && { _buildings isNotEqualTo [] } ) exitWith {

    // update variable
    _unit setVariable [QGVAR(currentTask), "Hide (inside)", GVAR(debug_functions)];

    // execute move
    _unit setUnitPos "MIDDLE";
    _unit doMove (_buildings selectRandomWeighted (_buildings apply { 100 - ( _unit distance2D _x ) }) );

    // debug
    if (GVAR(debug_functions)) then {
        ["%1 hide in building (%2 - %3x positions)", side _unit, name _unit, count _buildings] call FUNC(debugLog);
    };
};

// check for cover
private _cover = nearestTerrainObjects [ _unit, ["BUSH", "TREE", "SMALL TREE", "HIDE", "WALL", "FENCE"], 15, true, true ];

// targetPos
private _targetPos = if (_cover isEqualTo []) then {
    _unit getPos [25 + random _range, (_pos getDir _unit) + 20 - random 40]
} else {
    (_cover select 0) getPos [1, _pos getDir (_cover select 0)]
};

// water means hold
if (surfaceIsWater _targetPos) exitWith {
    false
};

// cover move or stay put
if (_unit distanceSqr _targetPos > 1.5) then {
    _unit doMove _targetPos;
    [{unitReady _this}, {doStop _this; _this setUnitPos "DOWN";}, _unit, 2, {_this setUnitPos "DOWN";}] call CBA_fnc_waitUntilAndExecute;
} else {
    doStop _unit;
};

// debug
if (GVAR(debug_functions)) then {
    ["%1 hide in bush (%2)", side _unit, name _unit] call FUNC(debugLog);
};

// end
true
