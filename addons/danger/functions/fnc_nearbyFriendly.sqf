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
