#include "script_component.hpp"
/*
 * Author: nkenny
 * handles immediate reaction responses by forcing animation on unit
 *
 * Arguments:
 * 0: unit doing the avaluation <OBJECT>
 * 1: type of danger <NUMBER>
 * 2: position of danger <ARRAY>
 *
 * Return Value:
 * timeout
 *
 * Example:
 * [bob, getPos angryBob] call lambs_danger_fnc_brainReact;
 *
 * Public: No
*/

/*
    Immediate actions
    1 Fire
    2 Hit
    4 Explosion
    9 BulletClose
*/

params ["_unit", ["_type", -1], ["_pos", [0, 0, 0]]];

// timeout
private _timeout = time + 1.4;

// ACE3
_unit setVariable ["ace_medical_ai_lastHit", CBA_missionTime];

// Move to cover if it's relatively safe
if (
    getSuppression _unit < 0.4
    && {RND(0.67)} // Add some randomness so they aren't taking cover all the time
    && {(speed _unit) isEqualTo 0}
    && {!(_unit call EFUNC(main,isIndoor))} // Don't try anything indoors
) exitWith {
    [_unit, _pos] call EFUNC(main,doCover);
    _timeout + 2
};

// dodge!
[_unit, _pos] call EFUNC(main,doDodge);

// end
_timeout
