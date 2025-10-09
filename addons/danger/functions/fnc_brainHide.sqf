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
    7 Scream
    - Panic
*/

params ["_unit", ["_type", -1], ["_pos", [0, 0, 0]]];

// timeout
private _timeout = time + 2;

// check screams
if (_type isEqualTo DANGER_SCREAM) exitWith {

    // communicate danger!
    [{_this call EFUNC(main,doShareInformation)}, [_unit, objNull, EGVAR(main,radioShout), true], 2 + random 3] call CBA_fnc_waitAndExecute;

    // check danger
    _unit doWatch _pos;
    _unit setVariable [QEGVAR(main,currentTarget), _pos, EGVAR(main,debug_functions)];
    _unit setVariable [QEGVAR(main,currentTask), "Heard scream!", EGVAR(main,debug_functions)];

    // exit
    _timeout - 1
};

// check if stopped
if (!(_unit checkAIFeature "PATH")) exitWith {-1};

// is indoor
private _indoor = _unit call EFUNC(main,isIndoor);

// check bodies ~ own group!
if (_type isEqualTo DANGER_DEADBODYGROUP) exitWith {

    // check body
    [_unit, _pos] call EFUNC(main,doCheckBody);

    // end
    _timeout + 3
};

// indoor units exit
if (RND(0.05) && {_indoor} && {RND(EGVAR(main,indoorMove))}) exitWith {
    [_unit, _pos] call EFUNC(main,doReposition);
    _timeout
};

// check bodies ~ enemy group!
if (_type isEqualTo DANGER_DEADBODY) exitWith {

    // if dead body found -- check nearby buildings!
    private _group = group _unit;
    private _groupMemory = _group getVariable [QEGVAR(main,groupMemory), []];
    if (_groupMemory isEqualTo []) then {
        _group setVariable [QEGVAR(main,groupMemory), [_pos, 15, true] call EFUNC(main,findBuildings)];
    };

    // gesture
    _unit doWatch _pos;
    [_unit, "gestureGoB"] call EFUNC(main,doGesture);

    _unit setVariable [QEGVAR(main,currentTarget), _pos, EGVAR(main,debug_functions)];
    _unit setVariable [QEGVAR(main,currentTask), "Checking bodies (unknown)", EGVAR(main,debug_functions)];

    // end
    _timeout
};

// drop down into cover
_unit setUnitPosWeak "DOWN";

// end
_timeout
