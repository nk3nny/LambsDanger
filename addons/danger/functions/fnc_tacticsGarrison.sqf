#include "script_component.hpp"
/*
 * Author: nkenny
 * Group garrisons buildings near enemies!
 *
 * Arguments:
 * 0: group leader <OBJECT>
 * 1: group target <OBJECT> or position <ARRAY>
 * 2: units in group, default all <ARRAY>
 * 3: delay until unit is ready again <NUMBER>
 *
 * Return Value:
 * Bool
 *
 * Example:
 * [bob, angryBob] call lambs_danger_fnc_tacticsGarrison;
 *
 * Public: No
*/
#define COVER_DISTANCE 25
#define BUILDING_DISTANCE 42

params ["_unit", "_target", ["_units", []], ["_delay", 180]];

// sort target
_target = _target call CBA_fnc_getPos;

private _group = group _unit;
// reset tactics
[
    {
        params ["_group", "_enableAttack", "_formation"];
        if (!isNull _group) then {
            _group setVariable [QGVAR(isExecutingTactic), nil];
            _group setVariable [QEGVAR(main,currentTactic), nil];
            _group enableAttack _enableAttack;
            _group setFormation _formation;
        };
    },
    [_group, attackEnabled _group, formation _group],
    _delay
] call CBA_fnc_waitAndExecute;

// alive unit
if !(_unit call EFUNC(main,isAlive)) exitWith {false};

// set speed and enableAttack
_group setFormation "FILE";
_group enableAttack false;

// find units
if (_units isEqualTo []) then {
    _units = [_unit, 150] call EFUNC(main,findReadyUnits);
};
if (_units isEqualTo []) exitWith {false};

// buildings ~ sorted by distance
private _buildings = [_target, BUILDING_DISTANCE, true, false] call EFUNC(main,findBuildings);
_buildings = _buildings apply { [_unit distanceSqr _x, _x] };
_buildings sort true;
_buildings = _buildings apply { _x select 1 };

// failsafe
if (_buildings isEqualTo []) exitWith {
    {_x doFollow leader _x} foreach _units;
};

// update target ~ better both for debugging and stacking soldiers
_target = _buildings select 0;

// leader ~ rally animation here
[_unit, "gestureFollow"] call EFUNC(main,doGesture);

// leader callout
[_unit, "combat", "RallyUp", 125] call EFUNC(main,doCallout);

// set tasks
_unit setVariable [QEGVAR(main,currentTarget), _target, EGVAR(main,debug_functions)];
_unit setVariable [QEGVAR(main,currentTask), "Tactics Garrison", EGVAR(main,debug_functions)];

// set group task
_group setVariable [QEGVAR(main,currentTactic), "Garrison/Rally", EGVAR(main,debug_functions)];

// make group ready
doStop _units;
_units doWatch objNull;

// execute
{
    private _pos = if (_buildings isEqualTo []) then {_target} else {_buildings deleteAt 0};
    [
        {
            params ["_unit", "_pos"];
            _unit moveTo _pos;
            _unit setDestination [_pos, "LEADER PLANNED", true];
        }, [_x, _pos], 0.5 + random 2
    ] call CBA_fnc_waitAndExecute;
    _x setVariable [QEGVAR(main,currentTask), "Group Garrison", EGVAR(main,debug_functions)];
} forEach _units;

// declare leftover positions in memory!
_group setVariable [QEGVAR(main,groupMemory), _buildings];

// debug
if (EGVAR(main,debug_functions)) then {
    ["%1 TACTICS GARRISON %2 (%3m) (%4 units)", side _unit, groupId _group, round (_unit distance2D _target), count _units] call EFUNC(main,debugLog);
    private _m = [_target, "tactics garrison", _unit call EFUNC(main,debugMarkerColor), "hd_flag"] call EFUNC(main,dotMarker);
    _m setMarkerSizeLocal [0.6, 0.6];
    [{deleteMarker _this}, _m, _delay + 30] call CBA_fnc_waitAndExecute;
};

// end
true
