#include "script_component.hpp"
/*
 * Author: nkenny
 * handles assessment of own situation
 *
 * Arguments:
 * 0: unit doing the avaluation <OBJECT>
 * 1: type of data <NUMBER>
 * 2: position of danger <ARRAY>
 * 3: known target threatening unit <OBJECT>
 *
 * Return Value:
 * number, timeout!
 *
 * Example:
 * [bob] call lambs_danger_fnc_brainAssess;
 *
 * Public: No
*/

/*
    Assess actions
    7 Scream
    10 Assess
*/

params ["_unit", ["_type", -1], ["_pos", [0, 0, 0]], ["_target", objNull]];

// timeout
private _timeout = time + 2;

// check screams
if (_type isEqualTo DANGER_SCREAM) exitWith {

    // communicate danger!
    [{_this call FUNC(shareInformation)}, [_unit, objNull, GVAR(radioShout), true], 2 + random 3] call CBA_fnc_waitAndExecute;

    // check danger
    _unit doWatch _pos;
    _unit setVariable [QGVAR(currentTarget), _pos, EGVAR(main,debug_functions)];
    _unit setVariable [QGVAR(currentTask), "Heard scream!", EGVAR(main,debug_functions)];

    // exit
    _timeout - 1
};

// group memory
private _group = group _unit;
private _groupMemory = _group getVariable [QGVAR(groupMemory), []];

// sympathetic CQB/suppressive fire
if !(_groupMemory isEqualTo []) exitWith {
    [_unit, _groupMemory] call FUNC(doAssaultMemory);
    _timeout + 3
};

// check self
private _indoor = _unit call EFUNC(main,isIndoor);

// cover
if (!_indoor && {speed _unit < 1}) exitWith {
    [_unit] call FUNC(doCover);
    _timeout
};

// building
if (_indoor && {RND(GVAR(indoorMove))}) then {
    [_unit, _target] call FUNC(doReposition);
};

// end
_timeout
