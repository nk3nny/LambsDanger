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

params ["_unit", ["_type", -1], ["_pos", [0, 0, 0]], ["_target", objNull]];

// timeout
private _timeout = time + 2;

// check if stopped
if (!(_unit checkAIFeature "PATH")) exitWith {_timeout};

// assigned target
private _assignedTarget = assignedTarget _unit;
if (
    !isNull _assignedTarget
    && {_unit distance2D _assignedTarget < GVAR(cqbRange)}
    && {(_unit knowsAbout _assignedTarget) isNotEqualTo 0}
) exitWith {
    [_unit, _assignedTarget] call EFUNC(main,doAssault);
    _timeout + 2
};

// group memory
private _groupMemory = (group _unit) getVariable [QEGVAR(main,groupMemory), []];

// sympathetic CQB/suppressive fire
if (_groupMemory isNotEqualTo []) exitWith {
    [_unit, _groupMemory] call EFUNC(main,doAssaultMemory);
    _timeout + 2
};

// stance
private _stance = stance _unit;
if (_stance isEqualTo "STAND") then {_unit setUnitPosWeak "MIDDLE";};
if (getSuppression _unit > 0.9 && {_stance isEqualTo "CROUCH"}) then {_unit setUnitPosWeak "DOWN";};

// building
if (RND(EGVAR(main,indoorMove)) && {_unit call EFUNC(main,isIndoor)}) exitWith {
    [_unit, _target] call EFUNC(main,doReposition);
    _timeout + 1
};

// cover
if ((speed _unit) isEqualTo 0 && {_unit distance2D (leader _unit) < 40}) then {
    [_unit] call EFUNC(main,doCover);
};

// end
_timeout
