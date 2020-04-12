#include "script_component.hpp"
/*
 * Author: joko // Jonas
 *
 *
 * Arguments:
 *
 *
 * Return Value:
 *
 *
 * Example:
 *
 *
 * Public: No
*/
params ["_side", "_pos"];

private _artillery = [GVAR(SideArtilleryHash), _side] call CBA_fnc_hashGet;
if !(isNil "_pos") then {
    _artillery = _artillery select {
        canFire _x
        && {unitReady _x}
        && {_pos inRangeOfArtillery [[_x], getArtilleryAmmo [_x] param [0, ""]]};
    };
};

!(_artillery isEqualTo [])
