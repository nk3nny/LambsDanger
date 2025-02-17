#include "script_component.hpp"
/*
 * Author: nkenny
 * Leader calls for group to disperse into cover a special mode with optional anti-armour tactics
 *
 * Arguments:
 * 0: group executing tactics <GROUP> or group leader <UNIT>
 * 1: group threat unit <OBJECT> or position <ARRAY>
 * 2: ready anti-tank weapons <BOOL>
 * 3: delay until unit is ready again <NUMBER>
 *
 * Return Value:
 * success
 *
 * Example:
 * [bob, angryJoe] call lambs_danger_fnc_tacticsHide;
 *
 * Public: No
*/

params ["_group", "_target", ["_antiTank", false], ["_delay", 240]];

// group is missing
if (isNull _group) exitWith {false};

// get leader
if (_group isEqualType objNull) then {_group = group _group;};
if ((units _group) isEqualTo []) exitWith {false};
private _unit = leader _group;

// find target
_target = _target call CBA_fnc_getPos;

// reset tactics
[
    {
        params [["_group", grpNull], ["_combatMode", "YELLOW"], ["_enableAttack", false], ["_formation", "WEDGE"]];
        if (!isNull _group) then {
            _group setVariable [QGVAR(isExecutingTactic), nil];
            _group setVariable [QEGVAR(main,currentTactic), nil];
            _group setCombatMode _combatMode;
            _group enableAttack _enableAttack;
            _group setFormation _formation;
            (units _group) doFollow (leader _group)
        };
    },
    [_group, combatMode _group, attackEnabled _group, formation _group],
    _delay
] call CBA_fnc_waitAndExecute;

// hold-fire combat mode
_group setFormation "LINE";
_group setCombatMode "WHITE";
_group enableAttack false;

_unit setVariable [QEGVAR(main,currentTarget), _target, EGVAR(main,debug_functions)];
_unit setVariable [QEGVAR(main,currentTask), "Leader Hide", EGVAR(main,debug_functions)];

// set group task
_group setVariable [QEGVAR(main,currentTactic), "Hiding", EGVAR(main,debug_functions)];

// gesture
[_unit, "gestureCover"] call EFUNC(main,doGesture);

// callout
[_unit, behaviour _unit, "TakeCover", 125] call EFUNC(main,doCallout);

// sort units
private _units = units _unit;
_units = _units select {
    _x call EFUNC(main,isAlive)
    && {isNull objectParent _x}
    && {_x checkAIFeature "PATH"}
    && {_x checkAIFeature "MOVE"}
    && {!(_x call EFUNC(main,isIndoor))}
    && {!(_x getVariable [QGVAR(forceMove), false])}
};
if (_units isEqualTo []) exitWith {false};

// unit commands
_units doWatch objNull;

// find launcher units
private _launchersAA = [_units, AI_AMMO_USAGE_FLAG_AIR, true] call EFUNC(main,getLauncherUnits);
private _launchersAT = [_units, AI_AMMO_USAGE_FLAG_ARMOUR] call EFUNC(main,getLauncherUnits);

// find enemy vehicles
private _enemies = _unit targets [true, 600, [], 0, _target];
private _vehicleIndex = _enemies findIf {private _vehicle = vehicle _x; _vehicle isKindOf "Tank" || {_vehicle isKindOf "Air"}};

if (_antiTank && { _vehicleIndex != -1 } && { _launchersAT isNotEqualTo [] || (_launchersAA isNotEqualTo []) }) then {
    private _targetVehicle = vehicle (_enemies select _vehicleIndex);
    {
        // launcher units target air/tank
        _x setCombatMode "RED";
        _x doTarget _targetVehicle;

        // extra impetuous to select launcher
        [_x, secondaryWeapon _x] call CBA_fnc_selectWeapon;
        _x setUnitPos "MIDDLE";
        systemChat format ["%1 tacticsHide %2 changing weapons!", side _x, name _x];
        [
            {
                params ["_unit", "_target"];
                _unit doFire _target;
                _unit setUnitPos "AUTO";
                systemChat format ["%1 doFire! %2 @ %3m", side _unit, name _unit, round (_unit distance _target)];
            },
            [_x, _targetVehicle], 5 + random 3
        ] call CBA_fnc_waitAndExecute;
        _units = _units - [_x];
    } forEach ([_launchersAT, _launchersAA] select (_targetVehicle isKindOf "Air"));
};

// disperse and hide unit
[_units, _target] call EFUNC(main,doGroupHide);

// debug
if (EGVAR(main,debug_functions)) then {
    ["%1 TACTICS HIDE %2 %4", side _unit, groupId _group, ["", " (anti tank/air)"] select _antiTank] call EFUNC(main,debugLog);
    private _m = [_unit, "tactics hide", _unit call EFUNC(main,debugMarkerColor), "hd_ambush"] call EFUNC(main,dotMarker);
    _m setMarkerSizeLocal [0.6, 0.6];
    _m setMarkerDirLocal ((_unit getDir _target) - 90);
    [{{deleteMarker _x;true} count _this;}, [_m], _delay + 30] call CBA_fnc_waitAndExecute;
};

// end
true
