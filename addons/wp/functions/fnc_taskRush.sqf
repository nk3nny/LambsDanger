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

    private _distance = (leader _group) distance _target;

    // Helicopters -- suppress it!
    if ((_distance < 200) && {(vehicle _target) isKindOf "Air"}) exitWith {
        (units _group) commandSuppressiveFire _target;
    };

    // Tank -- hide or ready AT
    private _launcherUnits = [_group] call EFUNC(main,getLauncherUnits);
    if ((_distance < 80) && {(vehicle _target) isKindOf "Tank"}) exitWith {
        {
            if (_x in _launcherUnits) then {
                _x setUnitPos "MIDDLE";
                _x selectWeapon (secondaryWeapon _x);
            } else {
                _x setUnitPos "DOWN";
                _x doSuppressiveFire _target;
            };
            true
        } count (units _group);
        _group enableGunLights "forceOff";
    };

    // adjust pos
    private _posMove = call {
        private _posATL = getPosATL _target;
        if ((insideBuilding _target) isEqualTo 1 || _distance < 20) exitWith {_posATL};
        private _posEmpty = _posATL findEmptyPosition [0, 20, "O_MRAP_02_F"];
        if (_posEmpty isEqualTo []) exitWith {_posATL};
        _posEmpty
    };

    // Default -- run for it!
    {
        _x forceSpeed -1;
        _x setUnitPos (["UP", "MIDDLE"] select ((unitPos _x) isEqualTo "Down"));
        _x doMove _posMove;
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
_group allowFleeing 0;
{
    _x disableAI "AUTOCOMBAT";
    _x disableAI "FSM";

    // fired EH
    private _firedEH = _x addEventHandler ["Fired", {
        params ["_unit"];
        _unit forceSpeed 3;
    }];

    // dodge
    private _suppressedEH = _x addEventHandler ["Suppressed", {
        params ["_unit", "", "_shooter"];
        private _unitPos = unitPos _unit;

        // tune stance
        if (_unitPos isEqualTo "Down") exitWith {};
        if (_unitPos isEqualTo "Middle" && {_unit distance2D _shooter > 30}) exitWith {_unit setUnitPos "DOWN";};
        _unit setUnitPos "MIDDLE";
    }];

    // variables
    _x setVariable [QGVAR(eventhandlers), [["Fired", _firedEH], ["Suppressed", _suppressedEH]]];

    doStop _x;
    true
} count (units _group);

// set group task
_group setVariable [QEGVAR(main,currentTactic), "taskRush", EGVAR(main,debug_functions)];

// Hunting loop
waitUntil {

    // performance
    waitUntil { sleep 1; simulationEnabled (leader _group); };

    // find
    private _target = [_group, _radius, _area, _pos, _onlyPlayers] call EFUNC(main,findClosestTarget);

    // act
    if (!isNull _target) then {
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
