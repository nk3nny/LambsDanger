#include "script_component.hpp"
/*
 * Author: nkenny
 * handles hiding from danger!
 *
 * Arguments:
 * 0: unit doing the avaluation <OBJECT>
 * 1: type of data <NUMBER>
 * 2: position of danger<OBJECT>
 *
 * Return Value:
 * bool
 *
 * Example:
 * [bob, 0, getPos angryBob] call lambs_danger_fnc_brainHide;
 *
 * Public: No
*/

/*
    Hide actions
    0 Enemy detected (but far)
    4 Explosion
    7 Scream
*/

params ["_unit", ["_type", 0], ["_pos", [0, 0, 0]]];

// timeout
private _timeout = time + 5;

// look at problem  ~ looking at sky syndrome. - nkenny
//_unit lookAt _pos;

// indoor units exit
if (RND(0.05) && {_unit call EFUNC(main,isIndoor)}) exitWith {
    //_unit forceSpeed 0;
    _timeout
};

// cover move when explosion
if (_type == 4) exitWith {
    [_unit] call FUNC(doCover);
    time + random 5
};

// speed
_unit forceSpeed -1;

// find cover
[{_this call FUNC(doHide)}, [_unit, _pos], random 1] call CBA_fnc_waitAndExecute;

// end
_timeout
