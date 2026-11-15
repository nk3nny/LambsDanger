#include "script_component.hpp"
/*
 * Author: nkenny
 * Leader calls for all group members to attack a single unit!
 *
 * Arguments:
 * 0: group executing tactics <GROUP> or group leader <UNIT>
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

// get a list of enemies within 34 meters of position
_target = _target call CBA_fnc_getPos;
private _enemies = _group targets [true, 34, [], 0, _target];

// get only one instance of each target
_enemies = _enemies apply {vehicle _x};
_enemies = _enemies arrayIntersect _enemies;

// exit
if (_enemies isEqualTo []) exitWith {false};

// update tactics and contact state
_group setVariable [QGVAR(isExecutingTactic), true];
_group setVariable [QEGVAR(main,currentTactic), "Attacking", EGVAR(main,debug_functions)];
_group enableAttack true;

// reset tactics
private _unit = leader _group;
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

// group settings - Diamond near buildings, line in open spaces
_group setCombatMode "RED";
_group setFormation (["LINE", "DIAMOND"] select (((getPos _unit) getEnvSoundController "houses") > 0.9));

// the attack
{
    private _enemy = selectRandom _enemies;
    _x doWatch (getPosATL _enemy);
    _x doTarget _enemy;
    _x doFire _enemy;
} forEach _units;

// debug
if (EGVAR(main,debug_functions)) then {
    ["%1 TACTICS ATTACK (%2 with %3 units @ %4m)", side _unit, name _unit, count _units, round (_unit distance2D _target)] call EFUNC(main,debugLog);
    private _m = [_unit, "tactics attack", _unit call EFUNC(main,debugMarkerColor), "hd_arrow"] call EFUNC(main,dotMarker);
    private _mt = [_target, "", _unit call EFUNC(main,debugMarkerColor), "hd_destroy"] call EFUNC(main,dotMarker);
    {_x setMarkerSizeLocal [0.6, 0.6];} forEach [_m, _mt];
    _m setMarkerDirLocal (_unit getDir _target);
    [{{deleteMarker _x;true} count _this;}, [_m, _mt], _delay + 30] call CBA_fnc_waitAndExecute;
};

// end
true
