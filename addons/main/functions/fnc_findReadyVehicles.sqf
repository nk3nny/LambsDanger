#include "script_component.hpp"
/*
 * Author: nkenny
 * Finds and sorts ground vehicles ready for group actions
 *
 * Arguments:
 * 0: Originating unit <OBJECT>
 * 1: Find units within range <NUMBER>, default 200
 *
 * Return Value:
 * available vehicles, array
 *
 * Example:
 * [bob, 200] call lambs_main_fnc_findReadyVehicles;
 *
 * Public: Yes
*/
params [
    ["_unit", objNull, [objNull]],
    ["_range", 350, [0]]
];

// get vehicles
private _vehicles = (units _unit) select {
    (_unit distance2D _x) < _range
    && { !(isNull objectParent _x) }
    && { canFire vehicle _x }
    && { (magazines vehicle _x) isNotEqualTo [] }
    && { isTouchingGround vehicle _x }
};

// sort vehicles
_vehicles = _vehicles apply { vehicle _x };
_vehicles = _vehicles arrayIntersect _vehicles;

// return
_vehicles
