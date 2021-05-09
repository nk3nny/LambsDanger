#include "script_component.hpp"
/*
 * Author: diwako
 * LOS check if suppression should be done
 *
 * Arguments:
 * 0: _unit <OBJECT>
 * 1: _target <OBJECT> or position <ARRAY> (ASL position)
 *
 * Return Value:
 * success
 *
 * Example:
 * [bob, angryJoe] call lambs_main_fnc_shouldSuppressPosition;
 *
 * Public: No
*/
params ["_unit", "_target"];

#define NUM_PROBES 2

private _targetASL = if (_target isEqualType objNull) then {
    systemChat (str time + "Run LIS check on unit");
    ATLtoASL (_target call CBA_fnc_getPos)
} else {
    _target
};
private _unitASL = (eyePos _unit) vectorAdd [0, 0, 0.5];

private _fnc_checkIfBlocked = {
    params ["_unit", "_startPos", "_endPos"];

    private _vis = lineIntersectsSurfaces [_startPos, _endPos vectorAdd [0, 0, 2], _unit, objNull, true, NUM_PROBES, "FIRE", "GEOM"];
    private _index = _vis findIf {
        private _obj = (_x select 2);
        isNull _obj || // terrain geom
        {_obj isKindOf "Building" || // normal object that is a building
        {GVAR(buildingModelCache) getVariable [((getModelInfo _obj) select 1), false]}} // super simple object that has a model of a building
    };

    _index isNotEqualTo -1
};

// check from unit pos to end pos
if ([_unit, _unitASL, _targetASL] call _fnc_checkIfBlocked) exitWith { false };
// reverse check
if ([_unit, _targetASL, _unitASL] call _fnc_checkIfBlocked) exitWith { false };
true
