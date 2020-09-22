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
params [["_unit", objNull, [objNull]], ["_delay", 30]];

// only leader
if !(leader _unit isEqualTo _unit || {isPlayer leader _unit}) exitWith {false};

// identify enemy
private _enemy = _unit findNearestEnemy _unit;
private _pos = getPosASL _enemy;

// get info
private _range = linearConversion [ 0, 150, (_unit distance2D _pos), 12, 35, true];
private _stealth = behaviour _unit isEqualTo "STEALTH";
private _full = speedMode _unit isEqualTo "FULL";

// update tactics and contact state
private _group = group _unit;
_group setVariable [QGVAR(tactics), true];
_group setVariable [QGVAR(contact), time + 300];

// set group task
_group setVariable [QGVAR(tacticsTask), "In contact!", EGVAR(main,debug_functions)];

// reset tactics state
[
    {
        params [["_group", grpNull, [grpNull]], ["_enableAttack", false]];
        if (!isNull _group) then {
            _group setVariable [QGVAR(tactics), nil];
            _group setVariable [QGVAR(tacticsTask), nil];
            _group enableAttack _enableAttack;
        };
    },
    [_group, attackEnabled _group],
    _delay + random 20
] call CBA_fnc_waitAndExecute;

// change formation and attack state
_group enableAttack false;
_group setFormation (_group getVariable [QGVAR(dangerFormation), formation _unit]);

// call event system
[QGVAR(onContact), [_unit, _group, _enemy]] call EFUNC(main,eventCallback);

// Gesture
[_unit, "gestureFreeze", true] call EFUNC(main,doGesture);

if (!isNull _enemy) then {
    [{_this call FUNC(shareInformation)}, [_unit, _enemy], 1 + random 3] call CBA_fnc_waitAndExecute;
};

// Callout
private _typeOf = typeOf vehicle _enemy;
private _callout = if (isText (configFile >> "CfgVehicles" >> _typeOf >> "nameSound")) then {
    getText (configFile >> "CfgVehicles" >> _typeOf >> "nameSound")
} else {
    "contact"
};
[ _unit, ["Combat", "Stealth"] select _stealth, _callout, 100] call EFUNC(main,doCallout);

// check speed
//(leader _unit) forceSpeed 1;

// rushing or ambushing units do not react
if (_stealth || {_full}) exitWith {true};

// disable Reaction phase for player group
if (isPlayer (leader _unit) && {GVAR(disableAIPlayerGroupReaction)}) exitWith {false};

// behaviour
if (behaviour _unit isEqualTo "AWARE") then {_unit setBehaviour "COMBAT";};

// initiate immediate action drills
private _units = [_unit] call EFUNC(main,findReadyUnits);

// leaders get their subordinates to hide!
private _buildings = [_unit, _range, true, true] call EFUNC(main,findBuildings);
{
    // hide
    [_x, getPosASL _enemy, _range * 0.7, _buildings] call FUNC(doHide);

    // dodge!
    if (getSuppression _x > 0) then {[_x, getPosASL _enemy] call FUNC(doDodge);};

    // force stance
    //[{_this call EFUNC(main,doGesture)}, [_x, "DOWN", true], random 3] call CBA_fnc_waitAndExecute;
    _x setUnitPosWeak "DOWN";

    // clear up existing building positions - nk
    _buildings deleteAt 0;

} foreach _units;

// gesture + call!
if !(_units isEqualTo []) then {

    // unit
    private _unit2 = _units select (count _units - 1);
    
    // point
    [{_this call EFUNC(main,doGesture)}, [_unit2, "gesturePoint"], random 4] call CBA_fnc_waitAndExecute;

    // contact!
    [{_this call EFUNC(main,doCallout)}, [_unit2, ["Combat", "Stealth"] select _stealth, "contact", 100], random 4] call CBA_fnc_waitAndExecute;
};

// debug
if (EGVAR(main,debug_functions)) then {
    format ["%1 TACTICS CONTACT! %2", side _unit, groupId _group] call EFUNC(main,debugLog);
};

// set current task
_unit setVariable [QGVAR(currentTarget), _enemy, EGVAR(main,debug_functions)];
_unit setVariable [QGVAR(currentTask), "Tactics Contact", EGVAR(main,debug_functions)];

// end
true