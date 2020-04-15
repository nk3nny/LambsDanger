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
 * BOOLEAN
 *
 * Example:
 * [bob, getpos angryBob] call lambs_danger_fnc_nearbyFriendly
 *
 * Public: No
*/
params ["_unit", "_pos", ["_distance", GVAR(minFriendlySuppressionDistance)]];
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
