#include "script_component.hpp"
/*
 * Author: nkenny
 * Group garrisons buildings near enemies!
 *
 * Arguments:
 * 0: Unit checked <OBJECT>
 * 1: Unit being attacked <OBJECT>
 * 2: Units list <ARRAY>, default is blank
 * 2: Time until tactics is reset, default 30s <NUMBERS>
 *
 * Return Value:
 * Bool
 *
 * Example:
 * [bob, angryBob] call liteDanger_fnc_tacticsGarrison;
 *
 * Public: No
*/
params ["_unit", "_target", ["_units", []], ["_delay", 90]];

private _group = group _unit;
// reset tactics
[
    {
        params ["_group", "_speedMode", "_enableAttack", "_formation"];
        if (!isNull _group) then {
            _group setVariable [QGVAR(isExecutingTactic), nil];
            _group enableAttack _enableAttack;
            _group setSpeedMode _speedMode;
            _group setFormation _formation;
            _group setVariable [QGVAR(tacticsTask), nil];
            {_x doFollow leader _x} foreach units _group;
        };
    },
    [_group, speedMode _unit, attackEnabled _unit, formation _unit],
    _delay
] call CBA_fnc_waitAndExecute;

// alive unit
if !(_unit call EFUNC(main,isAlive)) exitWith {false};

// find units
if (_units isEqualTo []) then {
    _units = [_unit, 150] call EFUNC(main,findReadyUnits);
};
if (_units isEqualTo []) exitWith {false};

// sort target
_target = _target call CBA_fnc_getPos;

// clear attacks! ( https://community.bistudio.com/wiki/getAttackTarget )
{
    if ((currentCommand _x) isEqualTo "ATTACK") then {
        _x forgetTarget (assignedTarget _x);
    };
} foreach _units;

// buildings
private _buildings = [_target, 9, true, false] call EFUNC(main,findBuildings);
_buildings = [_buildings, [], { _x select 2 }, "DESCEND"] call BIS_fnc_sortBy;    // ~ top to bottom
if (_buildings isEqualTo []) exitWith {false};
[_buildings, true] call CBA_fnc_shuffle;

// set speed and enableAttack
_unit setFormation "FILE";
_unit setSpeedMode "LIMITED";
_unit enableAttack false;

// leader ~ rally animation here
[_unit, "gestureFollow"] call EFUNC(main,doGesture);

// leader callout
[_unit, "combat", "RallyUp", 125] call EFUNC(main,doCallout);

// set tasks
_unit setVariable [QGVAR(currentTarget), _target, EGVAR(main,debug_functions)];
_unit setVariable [QGVAR(currentTask), "Tactics Garrison", EGVAR(main,debug_functions)];

// set group task
_group setVariable [QGVAR(tacticsTask), "Garrison/Rally", EGVAR(main,debug_functions)];

// updates CQB group variable
_group setVariable [QGVAR(CQB_pos), _buildings select {_unit distance2D _x < 25}];

// execute
{
    private _pos = if (_buildings isEqualTo []) then {_target} else {_buildings deleteAt 0};
    doStop _x;
    _x doMove _pos;
    _unit setDestination [_pos, "FORMATION PLANNED", true];
    _x setVariable [QGVAR(currentTask), "Group Garrison", EGVAR(main,debug_functions)];
} forEach _units;

// debug
if (EGVAR(main,debug_functions)) then {
    ["%1 TACTICS GARRISON %2 (%3m)", side _unit, groupId _group, round (_unit distance2D _target)] call EFUNC(main,debugLog);
    private _m = [_target, "", _unit call EFUNC(main,debugMarkerColor), "hd_flag"] call EFUNC(main,dotMarker);
    _m setMarkerSizeLocal [0.6, 0.6];
    [{{deleteMarker _x;true} count _this;}, [_m], _delay + 30] call CBA_fnc_waitAndExecute;
};

// end
true
