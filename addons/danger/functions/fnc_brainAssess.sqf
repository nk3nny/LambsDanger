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

// check if stopped
if (!(_unit checkAIFeature "PATH")) exitWith {_timeout};

// assigned target
private _assignedTarget = assignedTarget _unit;
if (
    !isNull _assignedTarget
    && {_unit distance2D _assignedTarget < GVAR(cqbRange)}
    && {_assignedTarget call EFUNC(main,isAlive)}
    && {(vehicle _assignedTarget) isKindOf "CAManBase"}
    && {!(typeOf _assignedTarget isEqualTo "SuppressTarget")}
) exitWith {
    [_unit, _assignedTarget] call FUNC(doAssault);
    _timeout + 2
};

// group memory
private _group = group _unit;
private _groupMemory = _group getVariable [QGVAR(groupMemory), []];

// sympathetic CQB/suppressive fire
if !(_groupMemory isEqualTo []) exitWith {
    [_unit, _groupMemory] call FUNC(doAssaultMemory);
    _timeout + 2
};

// stance
private _stance = stance _unit;
if (_stance isEqualTo "STAND") then {_unit setUnitPosWeak "MIDDLE";};
if (_stance isEqualTo "CROUCH" && {getSuppression _unit > 0}) then {_unit setUnitPosWeak "DOWN";};

// check self
private _indoor = _unit call EFUNC(main,isIndoor);

// building
if (_indoor && {RND(GVAR(indoorMove))}) exitWith {
    [_unit, _target] call FUNC(doReposition);
    _timeout + 1
};

// cover
if (speed _unit < 1 && {_unit distance2D (formationLeader _unit) < 32}) then {
    [_unit] call FUNC(doCover);
};

// end
_timeout
