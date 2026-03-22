#include "script_component.hpp"
/*
 * Author: nkenny
 * handles assessment of own situation
 *
 * Arguments:
 * 0: unit doing the evaluation <OBJECT>
 * 1: known target threatening unit <OBJECT>
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

params ["_unit", ["_target", objNull]];

// timeout
private _timeout = time + 2;
private _suppressed = (getSuppression _unit) isNotEqualTo 0;

// check if stopped
if (
    _suppressed
    || !(_unit checkAIFeature "PATH")
    || ((behaviour _unit)) isEqualTo "STEALTH"
    || (currentCommand _unit) isEqualTo "STOP"
    || (combatMode _unit) in ["BLUE", "GREEN"]
) exitWith {_timeout};

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
    _timeout
};

// reset look
_unit setUnitPosWeak "MIDDLE";
//_unit doWatch objNull;

// end
_timeout
