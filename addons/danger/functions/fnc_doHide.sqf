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
 * [bob, angryJoe, 30] call lambs_danger_fnc_doHide;
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
) exitWith {false};

// already inside -- exit
if (RND(0.05) && {_unit call EFUNC(main,isIndoor)}) exitWith {
    if (stance _unit isEqualTo "STAND") then {_unit setUnitPosWeak "MIDDLE"};
    //_unit doWatch _danger;
    false
};

// define buildings
if (_buildings isEqualTo []) then {
    _buildings = [_unit, _range, true, true] call EFUNC(main,findBuildings);
};

// variables
_unit setVariable [QGVAR(currentTarget), _danger, EGVAR(main,debug_functions)];
_unit setVariable [QGVAR(currentTask), "Hide", EGVAR(main,debug_functions)];

// settings
_unit forceSpeed 24;

// Randomly scatter into buildings or hide!
if (!(_buildings isEqualTo []) && { RND(0.05) }) then {

    _unit setVariable [QGVAR(currentTask), "Hide (inside)", EGVAR(main,debug_functions)];

    // hide
    doStop _unit;
    _unit setUnitPosWeak "MIDDLE";

    // execute move
    _unit doMove ((selectRandom _buildings) vectorAdd [0.7 - random 1.4, 0.7 - random 1.4, 0]);
    if (EGVAR(main,debug_functions)) then {format ["%1 hide in building", side _unit] call EFUNC(main,debugLog);};

} else {

    // hide
    _unit setUnitPosWeak "DOWN";
    //[_unit, ["DOWN"], true] call EFUNC(main,doGesture);

    // find cover
    private _cover = nearestTerrainObjects [ _unit getPos [20, getDir _unit + 180], ["BUSH", "TREE", "SMALL TREE", "HIDE"], 15, false, true ];

    // targetPos
    private _targetPos = [getPosASL (selectRandom _cover), _unit getPos [10 + random _range, (_danger getDir _unit) + 45 - random 90]] select (_cover isEqualTo []);

    // water means hold
    if (surfaceIsWater _targetPos) then { _targetPos = getPosASL _unit;};

    // execute move
    _unit doMove _targetPos;
    if (EGVAR(main,debug_functions)) then {format ["%1 hide in bush", side _unit] call EFUNC(main,debugLog);};
};

// end
true
