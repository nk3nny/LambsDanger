#include "script_component.hpp"
/*
 * Author: nkenny
 * Group leadership initiates immediate reaction to contact
 *
 * Arguments:
 * 0: group leader <OBJECT>
 * 1: Time until tactics state ends <NUMBER>, 60 seconds default
 *
 * Return Value:
 * bool
 *
 * Example:
 * [bob] call lambs_danger_fnc_tacticsContact;
 *
 * Public: No
*/
params [["_unit", objNull, [objNull]], ["_Zzz", 60]];

// identify enemy
private _enemy = _unit findNearestEnemy _unit;
private _pos = getPos _enemy;

// get info
private _range = linearConversion [ 0, 150, (_unit distance2D _pos), 12, 35, true];
private _stealth = behaviour _unit isEqualTo "STEALTH";
private _full = speedMode _unit isEqualTo "FULL";

// update tactics and contact state
group _unit setVariable [QGVAR(tactics), true];
group _unit setVariable [QGVAR(contact), time + 300];

// reset tactics state
[
    {
        params [["_group", grpNull, [grpNull]]];
        if (!isNull _group) then {
            _group setVariable [QGVAR(tactics), nil];
        };
    },
    group _unit,
    _Zzz + random 15
] call CBA_fnc_waitAndExecute;

// change formation
(group _unit) setFormation (group _unit getVariable [QGVAR(dangerFormation), formation _unit]);

// call event system
[QGVAR(onContact), [_unit, group _unit, _enemy]] call EFUNC(main,eventCallback);

// Gesture
[_unit, "gestureFreeze"] call EFUNC(main,doGesture);
if (!isNull _enemy) then {[FUNC(shareInformation), [_unit, _enemy], 1 + random 3] call CBA_fnc_waitAndExecute;};

// Callout
_enemy = vehicle _enemy;
private _callout = if (isText (configFile >> "CfgVehicles" >> typeOf _enemy >> "nameSound")) then {
    getText (configFile >> "CfgVehicles" >> typeOf _enemy >> "nameSound")
} else {
    "contact"
};
[ _unit, ["Combat", "Stealth"] select _stealth, _callout, 100] call EFUNC(main,doCallout);

// rushing or ambushing units do not react
if (_stealth || {_full}) exitWith {true};

// initiate immediate action drills
private _units = [_unit] call EFUNC(main,findReadyUnits);
_units = _units select { currentCommand _x isEqualTo "" };

// leaders get their subordinates to hide!
private _buildings = [_unit, _range, true, true] call EFUNC(main,findBuildings);
{
    // hide
    [_x, getPosASL _enemy, _range * 0.7, _buildings] call FUNC(doHide);

    // dodge!
    if (getSuppression _x > 0) then {[_x, getPosASL _enemy] call FUNC(doDodge);};

    // force move
    _x forceSpeed 2;
    //_x setVariable [QGVAR(forceMove), true];
    //[{_this setVariable [QGVAR(forceMove), nil];}, _x, 2 + random 4] call CBA_fnc_waitAndExecute;

    // force stance
    if (stance _x isEqualTo "STAND") then {_x setUnitPosWeak "MIDDLE";[_x, ["DOWN"], true] call EFUNC(main,doGesture);};
    if (stance _x isEqualTo "CROUCH") then {_x setUnitPosWeak "DOWN";[_x, ["DOWN"], true] call EFUNC(main,doGesture);};

    // clear up existing building positions - nk
    _buildings deleteAt 0;

} foreach _units;

// gesture
if !(_units isEqualTo []) then {[_units select (count _units - 1), "gesturePoint"] call EFUNC(main,doGesture);};

// debug
if (EGVAR(main,debug_functions)) then {
    format ["%1 TACTICS CONTACT! %2", side _unit, groupId group _unit] call EFUNC(main,debugLog);
};

// set current task
_unit setVariable [QGVAR(currentTarget), _enemy, EGVAR(main,debug_functions)];
_unit setVariable [QGVAR(currentTask), "Tactics Contact", EGVAR(main,debug_functions)];

// end
true