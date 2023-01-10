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
 * [bob, 0, angryBob] call lambs_danger_fnc_brainEngage;
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
private _timeout = time + 0.5;

// check
if (
    isNull _target
    || {_unit knowsAbout _target isEqualTo 0}
    || {(speed _target) > 20}
    || {(weapons _unit) isEqualTo []}
    || {(combatMode _unit) in ["BLUE", "GREEN"]}
) exitWith {
    _timeout + 1
};

// distance + group memory
private _distance = _unit distance2D _target;

// near, go for CQB
if (
    _distance < GVAR(cqbRange)
    && {_unit checkAIFeature "PATH"}
    && {(vehicle _target) isKindOf "CAManBase"}
    // && {_target call EFUNC(main,isAlive)}
) exitWith {
    _unit setVariable ["ace_medical_ai_lastFired", CBA_missionTime]; // ACE3
    [_unit, _target] call EFUNC(main,doAssault);
    _timeout + 1.4
};

// far, try to suppress
if (
    _distance < 500
    && {unitReady _unit}
    && {speed _unit < 5}
    && {RND(getSuppression _unit)}
    && {_type isEqualTo DANGER_CANFIRE}
) exitWith {
    private _posASL = ATLtoASL (_unit getHideFrom _target);
    if (((ASLtoAGL _posASL) select 2) > 6) exitWith {
        _timeout + 3
    };
    _unit forceSpeed 0;
    _unit setUnitPosWeak "MIDDLE";
    _unit suppressFor 4;
    [_unit, _posASL vectorAdd [0, 0, 0.8], true] call EFUNC(main,doSuppress);
    _timeout + 4
};

// end
_timeout
