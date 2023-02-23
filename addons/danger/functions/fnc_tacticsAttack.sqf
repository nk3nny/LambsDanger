#include "script_component.hpp"
/*
 * Author: nkenny
 * Leader calls for all group members to attack a single unit!
 *
 * Arguments:
 * 0: group <GROUP>
 * 1: group threat unit <OBJECT> or position <ARRAY>
 * 3: delay until unit is ready again <NUMBER>
 *
 * Return Value:
 * success
 *
 * Example:
 * [bob, angryJoe] call lambs_danger_fnc_tacticsAttack;
 *
 * Public: No
*/
params ["_group", ["_target", objNull], ["_units", []], ["_delay", 60]];

// group is missing
if (isNull _group) exitWith {false};

// get leader
if (_group isEqualType objNull) then {_group = group _group;};
if ((units _group) isEqualTo []) exitWith {false};
private _unit = leader _group;

// position
if (_target isEqualType []) then {
    _target = _unit findNearestEnemy _unit;
};

// exit
if (isNull _target) exitWith {false};

// update tactics and contact state
_group setVariable [QGVAR(isExecutingTactic), true];
_group setVariable [QEGVAR(main,currentTactic), "Attacking", EGVAR(main,debug_functions)];

// reset tactics
[
    {
        params [["_group", grpNull, [grpNull]], ["_combatMode", "YELLOW"], ["_formation", "WEDGE"]];
        if (!isNull _group) then {
            _group setVariable [QGVAR(isExecutingTactic), nil];
            _group setVariable [QEGVAR(main,currentTactic), nil];
            _group setCombatMode _combatMode;
            _group setFormation _formation;
        };
    },
    [_group, combatMode _unit, formation _unit],
    _delay
] call CBA_fnc_waitAndExecute;

// sort units
if (_units isEqualTo []) then {
    _units = [_unit] call EFUNC(main,findReadyUnits);
};

// set tasks
_unit setVariable [QEGVAR(main,currentTarget), _target, EGVAR(main,debug_functions)];
_unit setVariable [QEGVAR(main,currentTask), "Tactics Attack", EGVAR(main,debug_functions)];

// gesture
[_unit, ["gestureAttack"]] call EFUNC(main,doGesture);

// leader callout
[_unit, "combat", "Attack", 125] call EFUNC(main,doCallout);

// group settings
_unit setCombatMode "RED";
_unit setFormation "DIAMOND";

// the attack
private _targetVehicle = vehicle _target;
{
    _x setUnitPosWeak "MIDDLE";
    _x doWatch _targetVehicle;
    _x doTarget _targetVehicle;
    _x doFire _targetVehicle;
} foreach _units;

// debug
if (EGVAR(main,debug_functions)) then {
    ["%1 TACTICS ATTACK (%2 with %3 units @ %4m)", side _unit, name _unit, count _units, round (_unit distance2D _target)] call EFUNC(main,debugLog);
    private _m = [_unit, "tactics attack", _unit call EFUNC(main,debugMarkerColor), "hd_arrow"] call EFUNC(main,dotMarker);
    private _mt = [_target, "", _unit call EFUNC(main,debugMarkerColor), "hd_destroy"] call EFUNC(main,dotMarker);
    {_x setMarkerSizeLocal [0.6, 0.6];} foreach [_m, _mt];
    _m setMarkerDirLocal (_unit getDir _target);
    [{{deleteMarker _x;true} count _this;}, [_m, _mt], _delay + 30] call CBA_fnc_waitAndExecute;
};

// end
true
