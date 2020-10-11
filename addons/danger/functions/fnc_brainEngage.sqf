#include "script_component.hpp"
/*
 * Author: nkenny
 * handles responses while engaging
 *
 * Arguments:
 * 0: unit doing the avaluation <OBJECT>
 * 1: yype of data <NUMBER>
 * 2: yarget <OBJECT>
 * 3: distance to target <NUMBER>
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
    0 Enemy detected (but near)
    1 Fire
    3 Enemy near
    8 CanFire
*/

params ["_unit", ["_type", 0], ["_target", objNull]];

// timeout
private _timeout = time + 4;

// check
if (isNull _target || {stopped _unit}) exitWith {
    _unit forceSpeed 1;
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
    private _delay = linearConversion [0, GVAR(cqbRange), _distance, 0, 4, true];
    _timeout + _delay
};

// far, try to suppress
if (_type in [0, 8] && {needReload _unit < 0.4}) exitWith {
    _unit forceSpeed ([1, 3] select (_type isEqualTo 0));
    [_unit, ATLtoASL (_unit getHideFrom _target) vectorAdd [0, 0, 1.2]] call FUNC(doSuppress);
    _timeout + 3
};

// end
_timeout
