#include "script_component.hpp"
/*
 * Author: nkenny
 * handles responses while engaging
 *
 * Arguments:
 * 0: unit doing the avaluation <OBJECT>
 * 1: type of data <NUMBER>
 * 2: known target <OBJECT>
 *
 * Return Value:
 * number, timeout
 *
 * Example:
 * [bob, 0, angryBob, 100] call lambs_danger_fnc_brainEngage;
 *
 * Public: No
*/

/*
    Engage actions
    0 Enemy detected
    3 Enemy near
    8 CanFire
*/

params ["_unit", ["_type", -1], ["_target", objNull]];

// timeout
private _timeout = time + 2;

// ACE3
_unit setVariable ["ace_medical_ai_lastFired", CBA_missionTime];

// check
if (
    isNull _target
    || {(weapons _unit) isEqualTo []}
    || {needReload _unit > 0.85}
) exitWith {
    _unit forceSpeed 2;
    _timeout
};

// look at_this
if (_unit knowsAbout _target > 3.9) then {
    _unit lookAt _target;
};

// distance
private _distance = _unit distance2D _target;

// near, go for CQB
if (
    _distance < GVAR(cqbRange)
    && {_unit checkAIFeature "PATH"}
    && {(vehicle _target) isKindOf "CAManBase"}
    && {_target call EFUNC(main,isAlive)}
) exitWith {
    [_unit, _target] call FUNC(doAssault);
    _timeout + random 1
};

// far, try to suppress
if (
    _type in [DANGER_ENEMYDETECTED, DANGER_CANFIRE]
    && {_distance < 800}
    && {getSuppression _unit < 0.9}
) exitWith {
    _unit forceSpeed ([1, 2] select (_type isEqualTo DANGER_ENEMYDETECTED));
    [_unit, ATLtoASL ((_unit getHideFrom _target) vectorAdd [0, 0, random 1])] call FUNC(doSuppress);
    _timeout + 2
};

// end
_timeout
