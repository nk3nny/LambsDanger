#include "script_component.hpp"
/*
 * Author: nkenny
 * Actions on forced movement
 *
 * Arguments:
 * 0: Unit toggled <OBJECT>
 *
 * Return Value:
 * Bool
 *
 * Example:
 * [bob] call lambs_danger_fnc_brainForced;
 *
 * Public: No
*/
params ["_unit"];

// timeout
private _timeout = time + 3;

// unconscious or dead
if !(_unit call EFUNC(main,isAlive)) exitWith {
    -1
};

// fleeing
if (fleeing _unit) exitWith {
    [_unit] call FUNC(doFleeing);
    _timeout + 1
};

// vehicles are simpler
if (!isNull objectParent _unit) exitWith {_timeout + 6};

// suppression -- high go prone
if (getSuppression _unit > 0.9) exitWith {
    _unit setUnitPosWeak "DOWN";
    _timeout + 1
};

// mid -- go crouched
if (getSuppression _unit > 0) then {
    _unit setUnitPosWeak "MIDDLE";
};

// attack speed
if ((currentCommand _unit) isEqualTo "ATTACK") then {
    private _attackTarget = getAttackTarget _unit;
    // dodge if pressed
    if (getSuppression _unit > 0.8) exitWith {
        [_unit, getPosASL _attackTarget] call FUNC(doDodge);
        _timeout = time + random 1;
    };
    // tactical movement if not
    [_unit, _attackTarget] call FUNC(assaultSpeed);
};

// end
_timeout
