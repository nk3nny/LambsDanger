#include "script_component.hpp"
/*
 * Author: nkenny
 * Leader calls for extended aggressive assault towards buildings or location
 *
 * Arguments:
 * 0: group leader <OBJECT>
 * 1: group threat unit <OBJECT> or position <ARRAY>
 * 2: units in group, default all <ARRAY>
 * 3: how many assault cycles <NUMBER>
 * 4: delay until unit is ready again <NUMBER>
 *
 * Return Value:
 * success
 *
 * Example:
 * [bob, angryJoe] call lambs_danger_fnc_tacticsAssault;
 *
 * Public: No
*/
params ["_unit", "_target", ["_units", []], ["_cycle", 15], ["_delay", 80]];

// find target
_target = _target call CBA_fnc_getPos;
private _group = group _unit;

// reset tactics
[
    {
        params ["_group", "_enableAttack"];
        if (!isNull _group) then {
            _group setVariable [QGVAR(isExecutingTactic), nil];
            _group setVariable [QGVAR(tacticsTask), nil];
            _group enableAttack _enableAttack;
            {
                _x setVariable [QGVAR(forceMove), nil];
                _x doFollow leader _x;
                _x forceSpeed -1;
            } foreach (units _group);
        };
    },
    [_group, attackEnabled _group],
    _delay
] call CBA_fnc_waitAndExecute;

// alive unit
if !(_unit call EFUNC(main,isAlive)) exitWith {false};

// find units
if (_units isEqualTo []) then {
    _units = [_unit, 250] call EFUNC(main,findReadyUnits);
};
if (_units isEqualTo []) exitWith {false};

// sort potential targets
private _buildings = [_target, 8, true, false] call EFUNC(main,findBuildings);
_buildings append ((_unit targets [true, 10, [], 0, _target]) apply {_unit getHideFrom _x});
_buildings pushBack _target;

// set tasks
_unit setVariable [QGVAR(currentTarget), _target, EGVAR(main,debug_functions)];
_unit setVariable [QGVAR(currentTask), "Tactics Assault", EGVAR(main,debug_functions)];

// set group task
_group setVariable [QGVAR(tacticsTask), "Assaulting", EGVAR(main,debug_functions)];

// updates CQB group variable
_group setVariable [QGVAR(groupMemory), _buildings];
_group enableAttack false;

// gesture
[_unit, "gestureGo"] call EFUNC(main,doGesture);
[_units select (count _units - 1), "gestureGoB"] call EFUNC(main,doGesture);

// leader callout
[_unit, "combat", "Advance", 125] call EFUNC(main,doCallout);

// concealment
if (_unit distance2D _target > 15) then {

    // leader smoke
    [_unit, _target] call EFUNC(main,doSmoke);

    // grenadier smoke
    [{_this call EFUNC(main,doUGL)}, [_units, _target, "shotSmokeX"], 6] call CBA_fnc_waitAndExecute;
};

// ready group
_group setFormDir (_unit getDir _target);
_units doWatch _target;

// execute function
[_cycle, _units, _buildings] call FUNC(doGroupAssault);

// debug
if (EGVAR(main,debug_functions)) then {
    ["%1 TACTICS ASSAULT (%2 with %3 units @ %4m with %5 positions)", side _unit, name _unit, count _units, round (_unit distance2D _target), count _buildings] call EFUNC(main,debugLog);
    private _m = [_unit, "", _unit call EFUNC(main,debugMarkerColor), "hd_arrow"] call EFUNC(main,dotMarker);
    private _mt = [_target, "", _unit call EFUNC(main,debugMarkerColor), "hd_join"] call EFUNC(main,dotMarker);
    {_x setMarkerSizeLocal [0.6, 0.6];} foreach [_m, _mt];
    _m setMarkerDirLocal (_unit getDir _target);
    [{{deleteMarker _x;true} count _this;}, [_m, _mt], _delay + 30] call CBA_fnc_waitAndExecute;
};

// end
true
