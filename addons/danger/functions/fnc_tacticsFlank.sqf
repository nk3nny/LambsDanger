#include "script_component.hpp"
/*
 * Author: nkenny
 * Group conducts probing flanking manoeuvre
 *
 * Arguments:
 * 0: group leader <OBJECT>
 * 1: group target <OBJECT> or position <ARRAY>
 * 2: units in group, default all <ARRAY>
 * 3: how many assault cycles <NUMBER>
 * 4: default overwatch destination <ARRAY>
 * 4: delay until unit is ready again <NUMBER>
 *
 * Return Value:
 * Bool
 *
 * Example:
 * [bob, angryBob] call lambs_danger__fnc_tacticsFlank;
 *
 * Public: No
*/
params ["_unit", "_target", ["_units", []], ["_cycle", 4], ["_overwatch", []], ["_delay", 100]];

// find target
_target = _target call CBA_fnc_getPos;

// check CQB ~ exit if in close combat other functions will do the work - nkenny
if (_unit distance2D _target < GVAR(cqbRange)) exitWith {
    [_unit, _target] call FUNC(tacticsAssault);
    false
};

private _group = group _unit;
// reset tactics
[
    {
        params [["_group", grpNull], ["_speedMode", "NORMAL"], ["_formation", "WEDGE"]];
        if (!isNull _group) then {
            _group setVariable [QGVAR(isExecutingTactic), nil];
            _group setVariable [QEGVAR(main,currentTactic), nil];
            _group setSpeedMode _speedMode;
            _group setFormation _formation;
            {
                _x setVariable [QGVAR(forceMove), nil];
                _x setUnitPos "AUTO";
                [_x] allowGetIn true;
            } foreach (units _group);
        };
    },
    [_group, speedMode _unit, formation _unit],
    _delay
] call CBA_fnc_waitAndExecute;

// alive unit
if !(_unit call EFUNC(main,isAlive)) exitWith {false};

// find units
if (_units isEqualTo []) then {
    _units = _unit call EFUNC(main,findReadyUnits);
};
if (_units isEqualTo []) exitWith {false};

// find vehicles
private _vehicles = [_unit] call EFUNC(main,findReadyVehicles);

// sort building locations
private _pos = [_target, 12, true, false] call EFUNC(main,findBuildings);
_pos pushBack _target;

// find overwatch position
if (_overwatch isEqualTo []) then {
    private _distance2D = (_unit distance2D _target) min 250;
    _overwatch = selectBestPlaces [_target, _distance2D, "(2 * hills) + (2 * forest + trees + houses) - (2 * meadow) - (2 * windy) - (2 * sea) - (10 * deadBody)", 100 , 3] apply {[(_x select 0) distance2D _unit, _x select 0]};
    _overwatch = _overwatch select {!(surfaceIsWater (_x select 1))};
    _overwatch sort true;
    _overwatch = _overwatch apply {_x select 1};
    if (_overwatch isEqualTo []) then {_overwatch pushBack ([getPos _unit, _distance2D, 100, 8, _target] call EFUNC(main,findOverwatch));};
    _overwatch = _overwatch select 0;
};

// set tasks
_unit setVariable [QEGVAR(main,currentTarget), _target, EGVAR(main,debug_functions)];
_unit setVariable [QEGVAR(main,currentTask), "Tactics Flank", EGVAR(main,debug_functions)];

// set group task
_group setVariable [QEGVAR(main,currentTactic), "Flanking", EGVAR(main,debug_functions)];

// gesture
[_unit, ["gestureGo"]] call EFUNC(main,doGesture);
[_units select (count _units - 1), "gestureGoB"] call EFUNC(main,doGesture);

// leader callout
[_unit, "combat", "flank", 125] call EFUNC(main,doCallout);

// set speedmode
_unit setSpeedMode "FULL";

// prevent units from being mounted!
(units _unit) allowGetIn false;

// ready group
_group setFormDir (_unit getDir _target);
_group setFormation "FILE";
_units commandMove _overwatch;
{
    _x setUnitPos "MIDDLE";
    _x setVariable [QGVAR(forceMove), true];
} foreach _units;

// leader smoke ~ deploy concealment to enable movement
[_unit, _overwatch] call EFUNC(main,doSmoke);

// function
[{_this call EFUNC(main,doGroupFlank)}, [_cycle, _units, _vehicles, _pos, _overwatch], 2 + random 8] call CBA_fnc_waitAndExecute;

// debug
if (EGVAR(main,debug_functions)) then {
    ["%1 TACTICS FLANK (%2 with %3 units and %6 vehicles @ %4m with %5 positions)", side _unit, name _unit, count _units, round (_unit distance2D _overwatch), count _pos, count _vehicles] call EFUNC(main,debugLog);
    private _m = [_unit, "", _unit call EFUNC(main,debugMarkerColor), "hd_arrow"] call EFUNC(main,dotMarker);
    private _mt = [_overwatch, "", _unit call EFUNC(main,debugMarkerColor), "hd_objective"] call EFUNC(main,dotMarker);
    {_x setMarkerSizeLocal [0.6, 0.6];} foreach [_m, _mt];
    _m setMarkerDirLocal (_unit getDir _overwatch);
    [{{deleteMarker _x;true} count _this;}, [_m, _mt], _delay + 30] call CBA_fnc_waitAndExecute;
};

// end
true
