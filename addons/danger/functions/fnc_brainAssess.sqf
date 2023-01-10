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
    10 Assess
*/

params ["_unit", "", "", ["_target", objNull]];

// timeout
private _timeout = time + 3;

// check if stopped
if (!(_unit checkAIFeature "PATH")) exitWith {_timeout};

// group memory
private _groupMemory = (group _unit) getVariable [QEGVAR(main,groupMemory), []];

// sympathetic CQB/suppressive fire
if (_groupMemory isNotEqualTo []) exitWith {
    [_unit, _groupMemory] call EFUNC(main,doAssaultMemory);
    _timeout
};

// building
if (RND(EGVAR(main,indoorMove)) && {_unit call EFUNC(main,isIndoor)}) exitWith {
    [_unit, _target] call EFUNC(main,doReposition);
    _timeout - 1
};

// reset look
_unit setUnitPosWeak "MIDDLE";
//_unit doWatch objNull;

// end
_timeout
