#include "script_component.hpp"
/*
 * Author: nkenny
 * Aggressive Attacker script
 *
 * Arguments:
 * 0: Group performing action, either unit <OBJECT> or group <GROUP>
 * 1: Range of tracking, default is 500 meters <NUMBER>
 * 2: Delay of cycle, default 15 seconds <NUMBER>
 * 3: Area the AI Camps in, default [] <ARRAY>
 * 4: Center Position, if no position or Empty Array is given it uses the Group as Center and updates the position every Cycle, default [] <ARRAY>
 * 5: Only Players, default true <BOOL>
 *
 * Return Value:
 * none
 *
 * Example:
 * [bob, 500] spawn lambs_wp_fnc_taskRush;
 *
 * Public: Yes
*/
if !(canSuspend) exitWith {
    _this spawn FUNC(taskRush);
};

// init
params [
    ["_group", grpNull, [grpNull, objNull]],
    ["_radius", TASK_RUSH_SIZE, [0]],
    ["_cycle", TASK_RUSH_CYCLETIME, [0]],
    ["_area", [], [[]]],
    ["_pos", [], [[]]],
    ["_onlyPlayers", TASK_RUSH_PLAYERSONLY, [false]]
];

// functions ---

private _fnc_rushOrders = {
    params ["_group", "_target"];

    private _distance = (leader _group) distance2D _target;
    // Helicopters -- supress it!
    if ((_distance < 200) && {vehicle _target isKindOf "Air"}) exitWith {
        {
            _x commandSuppressiveFire _target;
            true
        } count (units _group);
    };

    // Tank -- hide or ready AT
    if ((_distance < 80) && {(vehicle _target) isKindOf "Tank"}) exitWith {
        {
            if ((secondaryWeapon _x) isNotEqualTo "") then {
                _x setUnitPos "MIDDLE";
                _x selectWeapon (secondaryWeapon _x);
            } else {
                _x setUnitPos "DOWN";
                _x commandSuppressiveFire _target;
            };
            true
        } count (units _group);
        _group enableGunLights "forceOff";
    };

    // Default -- run for it!
    {
        _x setUnitPos "UP";
        _x doMove (getPosATL _target);
        true
    } count (units _group);
    _group enableGunLights "forceOn";
};
// functions end ---

// sort grp
if (!local _group) exitWith {false};
if (_group isEqualType objNull) then { _group = group _group; };

// orders
_group setSpeedMode "FULL";
//_group setFormation "DIAMOND";
_group enableAttack false;
{
    _x disableAI "AUTOCOMBAT";
    doStop _x;
    true
} count (units _group);

// set group task
_group setVariable [QEGVAR(main,currentTactic), "taskRush", EGVAR(main,debug_functions)];

// Hunting loop
waitUntil {

    // performance
    waitUntil { sleep 1; simulationEnabled leader _group; };

    // find
    private _target = [_group, _radius, _area, _pos, _onlyPlayers] call FUNC(findClosestTarget);

    // act
    if (!isNull _target) then  {
        [_group, _target] call _fnc_rushOrders;
        if (EGVAR(main,debug_functions)) then { ["%1 taskRush: %2 targets %3 at %4M", side _group, groupID _group, name _target, floor (leader _group distance2D _target)] call EFUNC(main,debugLog); };
        sleep (linearConversion [1000, 2000, (leader _group distance2D _target), _cycle, _cycle * 4, true]);
    } else {
        sleep (_cycle * 4);
    };

    // end
    ((units _group) findIf {_x call EFUNC(main,isAlive)} == -1)

};

// end
true
