#include "script_component.hpp"
/*
 * Author: nkenny
 * handles hiding or investigating danger!
 *
 * Arguments:
 * 0: unit doing the avaluation <OBJECT>
 * 1: type of data <NUMBER>
 * 2: position of danger <OBJECT>
 *
 * Return Value:
 * bool
 *
 * Example:
 * [bob, 0, getPos angryBob] call lambs_danger_fnc_brainHide;
 *
 * Public: No
*/

/*
    Hide actions
    5 DeadBodyGroup
    6 DeadBody
    - Panic
*/

params ["_unit", ["_type", -1], ["_pos", [0, 0, 0]]];

// timeout
private _timeout = time + 3;

// check if stopped
if (!(_unit checkAIFeature "PATH")) exitWith {-1};

// is indoor
private _indoor = _unit call EFUNC(main,isIndoor);

// check bodies ~ own group!
if (_type isEqualTo DANGER_DEADBODYGROUP) exitWith {

    // check body
    [_unit, _pos] call FUNC(doCheckBody);

    // pop smoke
    if (!_indoor) then {[{_this call EFUNC(main,doSmoke)}, [_unit, _pos], random 2] call CBA_fnc_waitAndExecute;};

    // end
    _timeout + 3
};

// indoor units exit
if (RND(0.05) && {_indoor}) exitWith {
    //doStop _unit;   // test this more thoroughly!-- might make units too static! - nkenny
    if (RND(GVAR(indoorMove))) then {[_unit, _pos] call FUNC(doReposition);};
    _timeout
};

// check bodies ~ enemy group!
private _group = group _unit;
private _groupMemory = _group getVariable [QGVAR(groupMemory), []];
if (_type isEqualTo DANGER_DEADBODY) exitWith {

    // communicate danger!
    [{_this call FUNC(shareInformation)}, [_unit, objNull, GVAR(radioShout), true], 2 + random 3] call CBA_fnc_waitAndExecute;

    // gesture
    [_unit, "gestureGoB"] call EFUNC(main,doGesture);

    // add body to move routine
    _groupMemory pushBack _pos;
    _group setVariable [QGVAR(groupMemory), _groupMemory, false];

    _unit setVariable [QGVAR(currentTarget), _pos, EGVAR(main,debug_functions)];
    _unit setVariable [QGVAR(currentTask), "Checking bodies (unknown)", EGVAR(main,debug_functions)];

    // end
    _timeout
};

// drop down into cover
_unit setUnitPosWeak "DOWN";
[_unit, "WalkB", false] call EFUNC(main,doGesture);

// end
_timeout
