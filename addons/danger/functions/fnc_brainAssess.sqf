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
    [{_this call EFUNC(main,doShareInformation)}, [_unit, objNull, EGVAR(main,radioShout), true], 2 + random 3] call CBA_fnc_waitAndExecute;

    // check danger
    _unit doWatch _pos;
    _unit setVariable [QEGVAR(main,currentTarget), _pos, EGVAR(main,debug_functions)];
    _unit setVariable [QEGVAR(main,currentTask), "Heard scream!", EGVAR(main,debug_functions)];

    // exit
    _timeout - 1
};

// check if stopped
if (!(_unit checkAIFeature "PATH")) exitWith {_timeout};

// assigned target
private _assignedTarget = assignedTarget _unit;
private _canMove = _unit checkAIFeature "PATH";
if (
    !isNull _assignedTarget
    && {_unit distance2D _assignedTarget < GVAR(cqbRange)}
    && {_assignedTarget call EFUNC(main,isAlive)}
    && {(vehicle _assignedTarget) isKindOf "CAManBase"}
    && {!(typeOf _assignedTarget isEqualTo "SuppressTarget")}
) exitWith {
    [_unit, _assignedTarget] call EFUNC(main,doAssault);
    _timeout + 2
};

// group memory
private _groupMemory = (group _unit) getVariable [QEGVAR(main,groupMemory), []];

// sympathetic CQB/suppressive fire
if (_canMove && {_groupMemory isNotEqualTo []}) exitWith {
    [_unit, _groupMemory] call EFUNC(main,doAssaultMemory);
    _timeout + 2
};

// stance
private _stance = stance _unit;
if (_stance isEqualTo "STAND") then {_unit setUnitPosWeak "MIDDLE";};
if (_stance isEqualTo "CROUCH" && {getSuppression _unit > 0}) then {_unit setUnitPosWeak "DOWN";};

// check self
private _indoor = _unit call EFUNC(main,isIndoor);

// building
if (_indoor && {RND(EGVAR(main,indoorMove))}) exitWith {
    [_unit, _target] call EFUNC(main,doReposition);
    _timeout + 1
};

// cover
if (speed _unit < 1 && {_unit distance2D (formationLeader _unit) < 32}) then {
    [_unit] call EFUNC(main,doCover);
};

// end
_timeout
