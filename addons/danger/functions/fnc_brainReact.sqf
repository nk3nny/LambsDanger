#include "script_component.hpp"
/*
 * Author: nkenny
 * handles immediate reaction responses by forcing animation on unit
 *
 * Arguments:
 * 0: unit doing the avaluation <OBJECT>
 * 2: target threatening unit <ARRAY>
 *
 * Return Value:
 * timeout
 *
 * Example:
 * [bob, angryBob] call lambs_danger_fnc_brainReact;
 *
 * Public: No
*/

/*
    Immediate actions
    2 Hit
    9 BulletClose
*/

params ["_unit", ["_pos", [0, 0, 0]]];

// dodge!
[_unit, _pos] call FUNC(doDodge);

// end
time + random 1