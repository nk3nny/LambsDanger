#include "script_component.hpp"
/*
 * Author: joko // Jonas
 * Checks if unit has friendlies nearby
 *
 * Arguments:
 * 0: side being checked <OBJECT>
 * 1: Position checked  <ARRAY>, <OBJECT>
 * 2: radius being checked within <NUMBER>
 *
 * Return Value:
 * Array
 *
 * Example:
 * [bob, getPos angryBob] call lambs_main_fnc_findNearbyFriendlies
 *
 * Public: Yes
*/
params [
    ["_unit", objNull, [objNull]],
    ["_pos", [0, 0, 0], [[], objNull]],
    ["_distance", 5, [0]]
];
private _side = side _unit;
private _friendSides = [west, east, independent, civilian] select {_x getFriend _side > 0.6};
(_pos nearEntities ["CAManBase", _distance]) select {
    (side _x) in _friendSides
};
