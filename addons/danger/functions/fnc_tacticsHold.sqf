#include "script_component.hpp"
/*
 * Author: nkenny
 * Leader has no orders and waits for the situation to develop. If under fire, the group will take cover.
 *
 * Arguments:
 * 0: group executing tactics <GROUP> or group leader <UNIT>
 * 1: delay until unit is ready again <NUMBER>
 *
 * Return Value:
 * success
 *
 * Example:
 * [bob] call lambs_danger_fnc_tacticsHold;
 *
 * Public: No
*/
params ["_group", ["_delay", 45]];

// group is missing
if (isNull _group) exitWith {false};

// get leader
if (_group isEqualType objNull) then {_group = group _group;};
if ((units _group) isEqualTo []) exitWith {false};
private _unit = leader _group;

// known enemy
private _enemy = _unit findNearestEnemy _unit;
private _pos = if (isNull _enemy) then {_unit getPos [300, getDir _unit]} else {_unit getHideFrom _enemy};

// reset tactics
[
    {
        params [["_group", grpNull, [grpNull]], ["_enableAttack", false]];
        if (!isNull _group) then {
            _group setVariable [QGVAR(isExecutingTactic), nil];
            _group setVariable [QEGVAR(main,currentTactic), nil];
            _group enableAttack _enableAttack;
        };
    },
    [_group, attackEnabled _group],
    _delay
] call CBA_fnc_waitAndExecute;

// unit alive and allowed to move
if !(_unit call EFUNC(main,isAlive) && {_unit checkAIFeature "PATH"} && {_unit checkAIFeature "MOVE"}) exitWith {false};

// evaluate tactical situation
private _units = units _unit;
if (count _units > 2) then {

    // callout
    [_unit, "combat", selectRandom ["KeepFocused", "StayAlert"], 100] call EFUNC(main,doCallout);

    // has taken casualties and no real orders: hide
    if (
        !(GVAR(disableAIAutonomousManoeuvres))
        && {((expectedDestination _unit) select 1) isEqualTo "DoNotPlan"}
        && {(speedMode _unit) isNotEqualTo "FULL"}
        && {_group getVariable [QEGVAR(main,groupMemory), []] isEqualTo []}
    ) then {
        private _deadOrSuppressed = _units findIf {
            getSuppression _x > 0.95
            || {damage _x > 0.6}
            || {!(_x call EFUNC(main,isAlive))}
            || {CBA_missionTime - (_x getVariable ["ace_medical_ai_lastHit", -999999]) < 10}
        };
        if (_deadOrSuppressed != -1) then {

            // set group task
            _group setVariable [QEGVAR(main,currentTactic), "Holding!", EGVAR(main,debug_functions)];

            // gesture wildly!
            [_unit, "gestureCeaseFire"] call EFUNC(main,doGesture);

            // execute hiding
            [_units, _pos, "holding"] call EFUNC(main,doGroupHide);

            // debug
            if (EGVAR(main,debug_functions)) then {
                ["%1 TACTICS HOLD %2%3", side _unit, groupId _group, ["", " (enemy known)"] select (isNull _enemy)] call EFUNC(main,debugLog);
            };
        };
    };
};

// check new random direction if no enemy found!
if (isNull _enemy) then {
    _group setFormDir (random 360);
};

// change attack state to prevent units from running like headless chickens!
_group enableAttack false;

// end
true
