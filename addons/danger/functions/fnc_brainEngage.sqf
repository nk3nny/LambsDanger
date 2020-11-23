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
if (isNull _target) exitWith {
    _unit forceSpeed 2;
    _timeout
};

// look at_this
if (_unit knowsAbout _target > 3.5) then {
    _unit lookAt _target;
};

// distance
private _distance = _unit distance2D _target;

// near, go for CQB
if (_distance < GVAR(cqbRange)) exitWith {
    // execute assault
    [_unit, _target] call FUNC(doAssault);
    // dynamic delay
    private _delay = linearConversion [0, GVAR(cqbRange), _distance, 0, 3, true];
    _timeout + _delay
};

// far, try to suppress
if (_type in [DANGER_ENEMYDETECTED, DANGER_CANFIRE] && {needReload _unit < 0.4} && {_distance < 800}) exitWith {
    _unit forceSpeed ([1, 2] select (_type isEqualTo DANGER_ENEMYDETECTED));
    [_unit, ATLtoASL ((_unit getHideFrom _target) vectorAdd [0, 0, 1.2])] call FUNC(doSuppress);
    _timeout + random 6
};

// end
_timeout
