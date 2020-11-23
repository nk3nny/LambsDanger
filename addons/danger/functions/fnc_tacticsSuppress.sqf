#include "script_component.hpp"
/*
 * Author: nkenny
 * Leader calls for extended suppressive fire towards buildings or location
 *
 * Arguments:
 * 0: group leader <OBJECT>
 * 1: group threat unit <OBJECT> or position <ARRAY>
 * 2: units in group, default all <ARRAY>
 * 3: delay until group is ready <NUMBER>
 *
 * Return Value:
 * success
 *
 * Example:
 * [bob, angryJoe] call lambs_danger_fnc_tacticsSuppress;
 *
 * Public: No
*/
params ["_unit", "_target", ["_units", []], ["_delay", 12]];

// find target
_target = _target call CBA_fnc_getPos;

// reset tactics
[
    {
        params ["_group", "_enableAttack"];
        if (!isNull _group) then {
            _group setVariable [QGVAR(isExecutingTactic), nil];
            _group enableAttack _enableAttack;
            _group setVariable [QGVAR(tacticsTask), nil];
        };
    },
    [group _unit, attackEnabled _unit],
    _delay
] call CBA_fnc_waitAndExecute;

// alive unit
if !(_unit call EFUNC(main,isAlive)) exitWith {false};

// clear attacks!
{
    if (currentCommand _x isEqualTo "ATTACK") then {
        _x forgetTarget (assignedTarget _x);
    };
    _x setUnitPosWeak "MIDDLE";
} foreach units _unit;

// find units
if (_units isEqualTo []) then {
    _units = _unit call EFUNC(main,findReadyUnits);
};
if (_units isEqualTo []) exitWith {false};

// find vehicles
private _vehicles = (units _unit) select {
    (_unit distance2D _x) < 350
    && { canFire _x }
    && { !(isNull objectParent _x) }
    && { isTouchingGround vehicle _x }
    && { canFire vehicle _x };
};
_vehicles apply { vehicle _x };
_vehicles arrayIntersect _vehicles;

// sort building locations
private _pos = [_target, 20, true, true] call EFUNC(main,findBuildings);
_pos append ((nearestTerrainObjects [ _target, ["HIDE", "TREE", "BUSH", "SMALL TREE"], 8, false, true]) apply { (getPos _x) vectorAdd [0, 0, 0.5 + random 3] });
_pos pushBack _target;

// sort cycles
private _cycle = selectRandom [3, 3, 4, 5];

// set tasks
_unit setVariable [QGVAR(currentTarget), _target, EGVAR(main,debug_functions)];
_unit setVariable [QGVAR(currentTask), "Leader Suppress", EGVAR(main,debug_functions)];

private _group = group _unit;
// set group task
_group setVariable [QGVAR(tacticsTask), "Suppressing", EGVAR(main,debug_functions)];

// gesture
[_unit, "gesturePoint"] call EFUNC(main,doGesture);

// leader callout
[_unit, "combat", "SuppressiveFire", 125] call EFUNC(main,doCallout);

// ready group
_group setFormDir (_unit getDir _target);

// execute recursive cycle
[_cycle, _units, _vehicles, _pos] call FUNC(doGroupSuppress);

// debug
if (EGVAR(main,debug_functions)) then {
    ["%1 TACTICS SUPPRESS (%2 with %3 units and %6 vehicles @ %4m with %5 positions for %7 cycles)", side _unit, name _unit, count _units, round (_unit distance2D _target), count _pos, count _vehicles, _cycle] call EFUNC(main,debugLog);
    private _m = [_unit, "", _unit call EFUNC(main,debugMarkerColor), "hd_arrow"] call EFUNC(main,dotMarker);
    private _mt = [_target, "", _unit call EFUNC(main,debugMarkerColor),"hd_destroy"] call EFUNC(main,dotMarker);
    {_x setMarkerSizeLocal [0.6, 0.6];} foreach [_m, _mt];
    _m setMarkerDirLocal (_unit getDir _target);
    [{{deleteMarker _x;true} count _this;}, [_m, _mt], _delay + 30] call CBA_fnc_waitAndExecute;
};

// end
true
