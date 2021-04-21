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
params [["_unit", objNull, [objNull]], ["_enemy", objNull, [objNull]], ["_delay", 18]];

// only leader
if !((leader _unit) isEqualTo _unit || {_unit call EFUNC(main,isAlive)}) exitWith {false};

// identify enemy
if (isNull _enemy) then {
    _enemy = _unit findNearestEnemy _unit;
};

// update contact state
private _group = group _unit;
_group setVariable [QGVAR(contact), time + 600];

// set group task
_group setVariable [QGVAR(isExecutingTactic), true];
_group setVariable [QEGVAR(main,currentTactic), "Contact!", EGVAR(main,debug_functions)];

// reset tactics state
[
    {
        params [["_group", grpNull, [grpNull]], ["_enableAttack", false]];
        if (!isNull _group) then {
            _group setVariable [QGVAR(isExecutingTactic), nil];
            _group setVariable [QEGVAR(main,currentTactic), nil];
            _group enableAttack _enableAttack;
            private _leader = leader _group;
            if (_leader call FUNC(isLeader)) then {
                [_leader, _leader findNearestEnemy _leader] call FUNC(tactics);
            };
        };
    },
    [_group, attackEnabled _group],
    _delay + random 12
] call CBA_fnc_waitAndExecute;

// change formation and attack state
_group enableAttack false;
_group setFormation (_group getVariable [QGVAR(dangerFormation), formation _unit]);
_group setFormDir (_unit getDir _enemy);

// call event system
[QGVAR(onContact), [_unit, _group, _enemy]] call EFUNC(main,eventCallback);

// gesture + callouts for larger units
private _stealth = (behaviour _unit) isEqualTo "STEALTH";
private _units = (units _unit) select {currentCommand _x isEqualTo ""};
private _count = count _units;
if (_count > 2) then {
    // gesture
    [{_this call EFUNC(main,doGesture)}, [_unit, "gestureFreeze", true], 0.3] call CBA_fnc_waitAndExecute;

    // supporting unit
    private _unitCaller = _units select (_count - 1);

    // point
    [{_this call EFUNC(main,doGesture)}, [_unitCaller, "gesturePoint"], 0.3 + random 4] call CBA_fnc_waitAndExecute;

    // contact!
    [{_this call EFUNC(main,doCallout)}, [_unitCaller, ["Combat", "Stealth"] select _stealth, "contact"], 0.3 + random 4] call CBA_fnc_waitAndExecute;
};

// callout and share information
[
    {
        params ["_unit", "_enemy", "_stealth"];
        [_unit, _enemy, EGVAR(main,radioShout), true] call EFUNC(main,doShareInformation);
        [_unit, ["Combat", "Stealth"] select _stealth, "contact"] call EFUNC(main,doCallout);
    }, [_unit, _enemy, _stealth], 1 + random 4
] call CBA_fnc_waitAndExecute;

// disable Reaction phase for rushing or ambushing groups or player groups
if (
    _stealth
    || {(speedMode _unit) isEqualTo "FULL"}
    || {isPlayer (leader _unit) && {GVAR(disableAIPlayerGroupReaction)}}
) exitWith {true};

// set current task
//_unit setVariable [QEGVAR(main,currentTarget), _enemy, EGVAR(main,debug_functions)];
_unit setVariable [QEGVAR(main,currentTask), "Tactics Contact", EGVAR(main,debug_functions)];

// set combat behaviour and focus team
if ((behaviour _unit) isEqualTo "AWARE" && {!isPlayer (leader _group)}) then {_unit setBehaviour "COMBAT";};
if (!isNull _enemy && {_unit knowsAbout _enemy > 1}) then {_units doWatch _enemy;};

// immediate action -- leaders near to enemy go aggressive!
private _deadOrSuppressed = (units _unit) findIf {getSuppression _x > 0.95 || {!(_x call EFUNC(main,isAlive))}};
if (
    _count > random 3
    && {_unit knowsAbout _enemy > 0.1}
    && {_deadOrSuppressed isEqualTo -1}
    && {_unit distance2D _enemy < (GVAR(cqbRange) * 1.8)}
) exitWith {
    // execute assault
    {
        [_x, _enemy] call EFUNC(main,doAssault);
        _x setVariable [QEGVAR(main,currentTask), "Assault (contact)", EGVAR(main,debug_functions)];
    } foreach _units;

    // group variable
    _group setVariable [QEGVAR(main,currentTactic), "Contact! (aggressive)", EGVAR(main,debug_functions)];

    // debug
    if (EGVAR(main,debug_functions)) then {
        ["%1 TACTICS AGGRESSIVE CONTACT! %2", side _unit, groupId _group] call EFUNC(main,debugLog);
    };
};

// immediate action -- leaders further away get their subordinates to hide!
private _buildings = [leader _unit, 30, true, true] call EFUNC(main,findBuildings);
{
    // force movement!
    _x setVariable [QGVAR(forceMove), true];
    [{_this setVariable [QGVAR(forceMove), nil]}, _x, 2 + random 3] call CBA_fnc_waitAndExecute;

    // hide units
    [_x, _enemy, 18, _buildings] call EFUNC(main,doHide);
    _x setVariable [QEGVAR(main,currentTask), "Hide (contact)", EGVAR(main,debug_functions)];
} foreach _units;

// debug
if (EGVAR(main,debug_functions)) then {
    ["%1 TACTICS CONTACT! %2", side _unit, groupId _group] call EFUNC(main,debugLog);
};

// end
true
