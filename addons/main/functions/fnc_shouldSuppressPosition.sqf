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
params ["_unit", "_target", ["_doReverseCheck", true]];

#define NUM_PROBES 2
// super positions
#define OBSTACLE 0
#define NO_OBSTACLE 1
#define NO_OBSTACLE_PROXYMITY 2

if (_target isEqualType objNull) then {
    _target = eyePos _target;
};

private _unitASL = eyePos _unit;
// private _unitASL = (eyePos _unit) vectorAdd [0, 0, 0.5];

private _fnc_checkIfBlocked = {
    params ["_unit", "_startPos", "_endPos", "_targetPos"];

    private _vis = lineIntersectsSurfaces [_startPos, _endPos, _unit, objNull, true, NUM_PROBES, "FIRE", "GEOM"];
    private _index = _vis findIf {
        private _obj = (_x select 2);
        isNull _obj || // terrain geom
        {GVAR(blockSuppressionModelCache) getVariable [((getModelInfo _obj) select 1), false]} // object that has a model that blocks suppression
    };

    if (_index isEqualTo -1) exitWith {
        NO_OBSTACLE
    };

    [OBSTACLE, NO_OBSTACLE_PROXYMITY] select ((((_vis select _index) select 0) distance2D _targetPos) < GVAR(minObstacleProximity))
};

// check from unit pos to end pos
private _ret = [_unit, _unitASL, _target, _target] call _fnc_checkIfBlocked;
if (_ret isEqualTo OBSTACLE) exitWith {false};
// reverse check
if !(_doReverseCheck) exitWith {_ret > OBSTACLE};
!(_ret isEqualTo NO_OBSTACLE && {([_unit, _target, _unitASL, _target] call _fnc_checkIfBlocked) isEqualTo OBSTACLE})
