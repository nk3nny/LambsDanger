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
#define BUILDING_DISTANCE 25

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
            _group setVariable [QGVAR(tacticsTask), nil];
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
_group setBehaviour "COMBAT";
_group setFormation "FILE";
_group enableAttack false;

// find units
if (_units isEqualTo []) then {
    _units = [_unit, 150] call EFUNC(main,findReadyUnits);
};
if (_units isEqualTo []) exitWith {false};

// clear attacks!
{
    if ((currentCommand _x) isEqualTo "ATTACK") then {
        _x forgetTarget (getAttackTarget _x);
    };
} foreach _units;

// buildings ~ sorted by height ~ add other cover
private _buildings = [_target, BUILDING_DISTANCE, true, false] call EFUNC(main,findBuildings);
private _cover = ((nearestTerrainObjects [_target, ["BUSH", "TREE", "HIDE", "WALL", "FENCE"], COVER_DISTANCE, false, true]) apply {_x getPos [1.5, random 360]});
_buildings = _buildings apply { [_x select 2, _x] };
_buildings sort false;
_buildings = _buildings apply { _x select 1 };
_buildings append _cover;

// leader ~ rally animation here
[_unit, "gestureFollow"] call EFUNC(main,doGesture);

// leader callout
[_unit, "combat", "RallyUp", 125] call EFUNC(main,doCallout);

// set tasks
_unit setVariable [QGVAR(currentTarget), _target, EGVAR(main,debug_functions)];
_unit setVariable [QGVAR(currentTask), "Tactics Garrison", EGVAR(main,debug_functions)];

// set group task
_group setVariable [QGVAR(tacticsTask), "Garrison/Rally", EGVAR(main,debug_functions)];

// clear CQB group variable
_group setVariable [QGVAR(groupMemory), []];

// failsafe
if (_buildings isEqualTo []) exitWith {
    {_x doFollow leader _x} foreach _units;
};

// update target ~ better both for debugging and stacking soldiers
_target = _buildings select 0;

// make group ready
doStop _units;
_units doWatch _target;

// execute
{
    private _pos = if (_buildings isEqualTo []) then {_target} else {_buildings deleteAt 0};
    [
        {
            params ["_unit", "_pos"];
            _unit moveTo _pos;
            _unit setDestination [_pos, "FORMATION PLANNED", true];
        }, [_x, _pos], random 2
    ] call CBA_fnc_waitAndExecute;
    _x setVariable [QGVAR(currentTask), "Group Garrison", EGVAR(main,debug_functions)];
} forEach _units;

// debug
if (EGVAR(main,debug_functions)) then {
    ["%1 TACTICS GARRISON %2 (%3m) (%4 units)", side _unit, groupId _group, round (_unit distance2D _target), count _units] call EFUNC(main,debugLog);
    private _m = [_target, "", _unit call EFUNC(main,debugMarkerColor), "hd_flag"] call EFUNC(main,dotMarker);
    _m setMarkerSizeLocal [0.6, 0.6];
    [{deleteMarker _this}, _m, _delay + 30] call CBA_fnc_waitAndExecute;
};

// end
true
