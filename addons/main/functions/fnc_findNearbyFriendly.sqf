#include "script_component.hpp"
/*
 * Author: joko // Jonas
 * Checks if unit has friendlies nearby
 *
 * Arguments:
 * 0: side being checked <OBJECT>
 * 1: Position checked  <ARRAY>
 * 2: radius being checked within <NUMBER>
 *
 * Return Value:
 * Array
 *
 * Example:
 * [bob, getpos angryBob] call lambs_main_fnc_nearbyFriendly
 *
 * Public: Yes
*/
params [
    ["_unit", objNull, [objNull]],
    ["_pos", [0, 0, 0], [[]]],
    ["_distance", 5, [0]]
];
if (_distance isEqualTo 0) exitWith {[]};
private _ignoredSides = (side _unit) call BIS_fnc_enemySides;
_ignoredSides append [sideUnknown, sideEmpty, sideEnemy, sideLogic, sideFriendly, sideAmbientLife];
(_pos nearEntities ["CAManBase", _distance*1.5]) select {
    // Exit if side
    if ((side _x) in _ignoredSides) then {
        false
    } else {
        private _targetPos = (_unit targetKnowledge _x) select 6; // Dont use Actual position but use AI Estimated position
        (_unit distance2D _targetPos) < _distance
    };
};
