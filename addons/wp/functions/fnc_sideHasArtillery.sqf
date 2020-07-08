#include "script_component.hpp"
/*
 * Author: joko // Jonas
 * Checks if a side has available artillery
 *
 * Arguments:
 * 0: side of unit to check <SIDE>
 * 1: Position being attacked <ARRAY>, optional
 *
 * Return Value:
 * BOOL
 *
 * Example:
 * [side bob] call lambs_wp_fnc_sideHasArtillery
 *
 * Public: Yes
*/
params [
    ["_side", sideUnknown, [sideUnknown]],
    ["_pos", [], [[]]]
];

private _artillery = [GVAR(SideArtilleryHash), _side] call CBA_fnc_hashGet;
if !(_pos isEqualTo []) then {
    _artillery = _artillery select {
        canFire _x
        && {unitReady _x}
        && {_pos inRangeOfArtillery [[_x], getArtilleryAmmo [_x] param [0, ""]]};
    };
};

!(_artillery isEqualTo [])
