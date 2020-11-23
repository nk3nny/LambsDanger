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

params ["_unit", ["_type", 0], ["_pos", [0, 0, 0]]];

// timeout
private _timeout = time + 5;

// look at problem  ~ looking at sky syndrome. - nkenny
_unit lookAt _pos;

// check if stopped
if (!(_unit checkAIFeature "PATH")) exitWith {_unit doWatch _pos; -1};

// indoor units exit
if (RND(0.05) && {_unit call EFUNC(main,isIndoor)}) exitWith {
    //_unit forceSpeed 0;
    _timeout
};

// check bodies ~ own group!
if (_type isEqualTo DANGER_DEADBODYGROUP) exitWith {

    // check body
    [_unit, _pos] call FUNC(doCheckBody);

    // pop smoke
    [{_this call EFUNC(main,doSmoke)}, [_unit, _pos], random 2] call CBA_fnc_waitAndExecute;

    // end
    _timeout + 3
};

// check bodies ~ enemy group!
private _group = group _unit;
private _groupMemory = _group getVariable [QGVAR(groupMemory), []];
if (_type isEqualTo DANGER_DEADBODY) exitWith {

    // communicate danger!
    [{_this call FUNC(shareInformation)}, [_unit, objNull, GVAR(radioShout), true], 2 + random 3] call CBA_fnc_waitAndExecute;

    // add body to move routine
    _groupMemory pushBack _pos;
    _group setVariable [QGVAR(groupMemory), _groupMemory, false];

    _unit setVariable [QGVAR(currentTarget), _pos, EGVAR(main,debug_functions)];
    _unit setVariable [QGVAR(currentTask), "Checking bodies (unknown)", EGVAR(main,debug_functions)];

    // end
    _timeout + 3
};

// speed
_unit forceSpeed -1;

// find cover
[{_this call FUNC(doHide)}, [_unit, _pos], random 1] call CBA_fnc_waitAndExecute;

// end
_timeout
