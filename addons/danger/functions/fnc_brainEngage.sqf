#include "script_component.hpp"
/*
 * Author: nkenny
 * handles responses while engaging
 *
 * Arguments:
 * 0: unit doing the evaluation <OBJECT>
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
private _timeout = time + 1.5;

// hide when static and ordered to be stealthy
private _stealth = (behaviour _unit) isEqualTo "STEALTH";
private _holdFire = ((combatMode _unit) in ["BLUE", "GREEN"]) || ((weaponState _unit) select 6) isNotEqualTo 0;
private _still = (speed _unit) isEqualTo 0;
if (
    _still
    && _stealth
    && _holdFire
) exitWith {
    [_unit, _target] call EFUNC(main,doHide);
    _timeout + 2
};

// check
if (
    isNull _target
    || _stealth
    || _holdFire
    || {(speed _target) > 20 || (_unit knowsAbout _target) isEqualTo 0}
    || {(getUnitState _unit) isEqualTo "PLANNING"}
) exitWith {
    _timeout
};

// distance + group memory
private _distance = _unit distance2D _target;

// near, go for CQB
private _cqbRange = GVAR(cqbRange) * (1 - getSuppression _unit);
if (
    _distance < _cqbRange
    && _unit checkAIFeature "PATH"
    && (vehicle _target) isKindOf "CAManBase"
    && {_target call EFUNC(main,isAlive)}
) exitWith {

    // enemy outside-- but I'm inside
    // use simpler inside calculation for performance
    if (RND(EGVAR(main,indoorMove)) && { (insideBuilding _unit) isEqualTo 1 && (insideBuilding _target) isEqualTo 0 } ) exitWith {
        [_unit, _target] call EFUNC(main,doReposition);
        _timeout + 3
    };

    // execute assault!
    [_unit, _target] call EFUNC(main,doAssault);
    _timeout

};

// set low stance
if ((getSuppression _unit) isNotEqualTo 0 && (stance _unit) isEqualTo "STAND") then {
    _unit setUnitPosWeak "MIDDLE";
};

// formation is tight
if (formation _unit in ["FILE", "DIAMOND"]) exitWith {
    _timeout
};

// far, try to suppress
if (
    _still
    && _distance > EGVAR(main,minSuppressionRange)
    && unitReady _unit
    && (_type in [DANGER_CANFIRE, DANGER_ENEMYNEAR])
) exitWith {
    private _getHide = _unit getHideFrom _target;
    _getHide set [2, (getPosATL _target) select 2];
    [_unit, (ATLToASL _getHide) vectorAdd [0, 0, 0.8], true] call EFUNC(main,doSuppress);
    _timeout + 3
};

// end
_timeout
