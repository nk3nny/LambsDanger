#include "script_component.hpp"
/*
 * Author: nkenny
 * Leader calls for extended aggressive assault towards buildings or location
 *
 * Arguments:
 * 0: Group leader <OBJECT>
 * 1: Group threat unit <OBJECT> or position <ARRAY>
 * 2: Units in group, default all <ARRAY>
 * 3: How many assault cycles, default four <NUMBER>
 *
 * Return Value:
 * success
 *
 * Example:
 * [bob, angryJoe] call lambs_danger_fnc_tacticsAssault;
 *
 * Public: No
*/
params ["_unit", "_target", ["_units", []], ["_cycle", 2], ["_delay", 22]];

// find target
_target = _target call CBA_fnc_getPos;
private _group = group _unit;

// reset tactics
[
    {
        params ["_group", "_speedMode"];
        if (!isNull _group) then {
            _group setVariable [QGVAR(isExecutingTactic), nil];
            _group setSpeedMode _speedMode;
            {_x setVariable [QGVAR(forceMove), nil];} foreach (units _group);
            _group setVariable [QGVAR(tacticsTask), nil];
        };
    },
    [_group, speedMode _unit],
    _delay
] call CBA_fnc_waitAndExecute;

// alive unit
if !(_unit call EFUNC(main,isAlive)) exitWith {false};

// find units
if (_units isEqualTo []) then {
    _units = [_unit, 250] call EFUNC(main,findReadyUnits);
};
if (_units isEqualTo []) exitWith {false};

// sort building locations
private _buildings = [_target, 9, true, false] call EFUNC(main,findBuildings);
_buildings pushBack _target;

// set tasks
_unit setVariable [QGVAR(currentTarget), _target, EGVAR(main,debug_functions)];
_unit setVariable [QGVAR(currentTask), "Tactics Assault", EGVAR(main,debug_functions)];

// set group task
_group setVariable [QGVAR(tacticsTask), "Assault", EGVAR(main,debug_functions)];

// updates CQB group variable
_group setVariable [QGVAR(CQB_pos), _buildings];

// gesture
[_unit, "gestureGo"] call EFUNC(main,doGesture);
[_units select (count _units - 1), "gestureGoB"] call EFUNC(main,doGesture);

// leader callout
[_unit, "combat", "Advance", 125] call EFUNC(main,doCallout);

// leader smoke
[_unit, _target] call EFUNC(main,doSmoke);

// grenadier smoke
[{_this call EFUNC(main,doUGL)}, [_units, _target, "shotSmokeX"], 6] call CBA_fnc_waitAndExecute;

// ready group
_group setFormDir (_unit getDir _target);

// execute function
[_cycle, _units, _buildings] call FUNC(doGroupAssault);

// set speedmode    // experiment with this! - nkenny
//_unit setSpeedMode "FULL";

// debug
if (EGVAR(main,debug_functions)) then {
    ["%1 TACTICS ASSAULT (%2 with %3 units @ %4m with %5 positions)", side _unit, name _unit, count _units, round (_unit distance2D _target), count _buildings] call EFUNC(main,debugLog);
};

// end
true
