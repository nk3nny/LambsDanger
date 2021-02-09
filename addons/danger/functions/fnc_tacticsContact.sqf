#include "script_component.hpp"
/*
 * Author: nkenny
 * Group leadership initiates immediate reaction to contact
 *
 * Arguments:
 * 0: group leader <OBJECT>
 * 1: enemy <OBJECT>
 * 2: Time until tactics state ends <NUMBER>
 *
 * Return Value:
 * bool
 *
 * Example:
 * [bob, angryJoe] call lambs_danger_fnc_tacticsContact;
 *
 * Public: No
*/
params [["_unit", objNull, [objNull]], ["_enemy", objNull, [objNull]], ["_delay", 22]];

// only leader
if !((leader _unit) isEqualTo _unit || {_unit call EFUNC(main,isAlive)}) exitWith {false};

// identify enemy
if (isNull _enemy) then {
    _enemy = _unit findNearestEnemy _unit;
};

// get info
private _range = linearConversion [0, 150, _unit distance2D _enemy, 8, 30, true];
private _stealth = (behaviour _unit) isEqualTo "STEALTH";

// update tactics and contact state
private _group = group _unit;
_group setVariable [QGVAR(isExecutingTactic), true];
_group setVariable [QGVAR(contact), time + 600];

// set group task
_group setVariable [QEGVAR(main,currentTactic), "Contact!", EGVAR(main,debug_functions)];

// reset tactics state
[
    {
        params [["_group", grpNull, [grpNull]], ["_enableAttack", false]];
        if (!isNull _group) then {
            _group setVariable [QGVAR(isExecutingTactic), nil];
            _group setVariable [QEGVAR(main,currentTactic), nil];
            _group enableAttack _enableAttack;
            {_x setUnitPosWeak "AUTO"} foreach units _group;
            private _leader = leader _group;
            if (_leader call FUNC(isLeader)) then {
                [_leader, _leader findNearestEnemy _leader] call FUNC(tactics);
            };
        };
    },
    [_group, attackEnabled _group],
    _delay + random 8
] call CBA_fnc_waitAndExecute;

// change formation and attack state
_group enableAttack false;
_group setFormation (_group getVariable [QGVAR(dangerFormation), formation _unit]);
_group setFormDir (_unit getDir _enemy);

// call event system
[QGVAR(onContact), [_unit, _group, _enemy]] call EFUNC(main,eventCallback);

// Gesture
[_unit, "gestureFreeze", true] call EFUNC(main,doGesture);

// Callout
private _typeOf = typeOf vehicle _enemy;
private _callout = if (isText (configFile >> "CfgVehicles" >> _typeOf >> "nameSound")) then {
    getText (configFile >> "CfgVehicles" >> _typeOf >> "nameSound")
} else {
    "contact"
};
[_unit, ["Combat", "Stealth"] select _stealth, _callout, 100] call EFUNC(main,doCallout);

// gesture + call!
private _units = [_unit] call EFUNC(main,findReadyUnits);
if !(_units isEqualTo []) then {
    // unit
    private _unitCaller = _units select (count _units - 1);

    // point
    [{_this call EFUNC(main,doGesture)}, [_unitCaller, "gesturePoint"], random 4] call CBA_fnc_waitAndExecute;

    // contact!
    [{_this call EFUNC(main,doCallout)}, [_unitCaller, ["Combat", "Stealth"] select _stealth, "contact", 100], random 4] call CBA_fnc_waitAndExecute;
};

// share information
[{_this call FUNC(shareInformation)}, [_unit, _enemy, GVAR(radioShout), true], 1 + random 5] call CBA_fnc_waitAndExecute;

// disable Reaction phase for rushing or ambushing groups
if (_stealth || {(speedMode _unit) isEqualTo "FULL"}) exitWith {true};

// disable Reaction phase for player group
if (isPlayer (leader _unit) && {GVAR(disableAIPlayerGroupReaction)}) exitWith {false};

// set current task
//_unit setVariable [QEGVAR(main,currentTarget), _enemy, EGVAR(main,debug_functions)];
_unit setVariable [QEGVAR(main,currentTask), "Tactics Contact", EGVAR(main,debug_functions)];

// set combat behaviour and focus team
if ((behaviour _unit) isEqualTo "AWARE") then {_unit setBehaviour "COMBAT";};
if (!isNull _enemy && {_unit knowsAbout _enemy > 1}) then {_units doWatch _enemy;};

// immediate action -- leaders near to enemy go aggressive!
private _deadOrSuppressed = (units _unit) findIf {getSuppression _x > 0.95 || {!(_x call EFUNC(main,isAlive))}};
if (_deadOrSuppressed isEqualTo -1 && {_unit distance2D _enemy < (GVAR(cqbRange) * 1.8)} && {count _units > random 3}) exitWith {
    {
        private _distanceAssault = RND(0.2) && {_x distance2D _enemy < GVAR(cqbRange)};
        if (_distanceAssault) then {
            [_x, _enemy] call EFUNC(main,doAssault);
        } else {
            [_x, ATLtoASL ((_unit getHideFrom _enemy) vectorAdd [0.5 - random 1, 0.5 - random 1, 0.3 + random 1])] call EFUNC(main,doSuppress);
        };
    } foreach _units;

    // group variable
    _group setVariable [QEGVAR(main,currentTactic), "Contact! (aggressive)", EGVAR(main,debug_functions)];

    // debug
    if (EGVAR(main,debug_functions)) then {
        ["%1 TACTICS AGGRESSIVE CONTACT! %2", side _unit, groupId _group] call EFUNC(main,debugLog);
    };
};

// immediate action -- leaders further away get their subordinates to hide!
private _buildings = [leader _unit, _range, true, true] call EFUNC(main,findBuildings);
{
    [_x, _enemy, _range * 0.7, _buildings] call EFUNC(main,doHide);
    _x setVariable [QEGVAR(main,currentTask), "Hide (contact)", EGVAR(main,debug_functions)];
} foreach _units;

// debug
if (EGVAR(main,debug_functions)) then {
    ["%1 TACTICS CONTACT! %2", side _unit, groupId _group] call EFUNC(main,debugLog);
};

// end
true
