#include "script_component.hpp"
/*
 * Author: diwako
 * LOS check if suppression should be done
 *
 * Arguments:
 * 0: _unit <OBJECT>
 * 1: _target <OBJECT> or position <ARRAY>
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

private _targetASL = ATLtoASL (_target call CBA_fnc_getPos);
private _unitASL = getPosASL _unit;

private _fnc_CheckIfBlocked = {
    params ["_startPos", "_endPos"];

    private _vis = lineIntersectsSurfaces [_startPos vectorAdd [0, 0, 2], _endPos vectorAdd [0, 0, 2], _unit, objNull, true, 3, "FIRE", "GEOM"];
    private _index = _vis findIf {isNull (_x select 2) || {(_x select 2) isKindOf "Building" || {GVAR(buildingModelCache) getVariable [((getModelInfo (_x select 2)) select 1), false]}}};

    // true if LIS hit terrain geom or a building which is further away than 71+ (sqr of 5041) meters from target pos
    diw_debug = _vis;
    systemChat "====================";
    if (_index isNotEqualTo -1) then {
        systemChat format ["index: %1 | null: %2 | dist: 3", _index, isNull ((_vis select _index) select 2), ((_vis select _index) select 0) vectorDistanceSqr _endPos];
    } else {
        systemChat "Nothing in LIS"
    };
    systemChat "====================";
    _index isNotEqualTo -1 && {
        isNull ((_vis select _index) select 2) || {(((_vis select _index) select 0) distanceSqr _endPos) < 5041};
    }
};

// check from unit pos to end pos
if ([_unitASL, _targetASL] call _fnc_CheckIfBlocked) exitWith { false };
// reverse check
if ([_targetASL, _unitASL] call _fnc_CheckIfBlocked) exitWith { false };

true
