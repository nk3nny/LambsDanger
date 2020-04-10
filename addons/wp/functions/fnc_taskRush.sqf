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
 * Public: No
*/
if !(canSuspend) exitWith {
    _this spawn FUNC(taskRush);
};
// functions ---

private _fnc_rushOrders = {
    params ["_group", "_target"];
    // Helicopters -- supress it!
    if (((leader _group) distance2d _target < 200) && {vehicle _target isKindOf "Air"}) exitWith {
        {
            _x commandSuppressiveFire (getPosASL _target);
            true
        } count (units _group);
    };

    // Tank -- hide or ready AT
    if (((leader _group) distance2d _target < 80) && {(vehicle _target) isKindOf "Tank"}) exitWith {
        {
            if !(secondaryWeapon _x isEqualTo "") then {
                _x setUnitPos "Middle";
                _x selectWeapon (secondaryWeapon _x);
            } else {
                _x setUnitPos "DOWN";
                _x commandSuppressiveFire (getPosASL _target);
            };
            true
        } count (units _group);
        _group enableGunLights "forceOff";
    };

    // Default -- run for it!
    {
        _x setUnitPos "UP";
        _x forceSpeed ([_x, _target] call EFUNC(danger,assaultSpeed));
        _x doMove (getPosATL _target);
        true
    } count (units _group);
    _group enableGunLights "forceOn";
};
// functions end ---

// init
params ["_group", ["_radius", 500], ["_cycle", 15], ["_area", [], [[]]], ["_pos", [], [[]]], ["_onlyPlayers", true]];

// sort grp
if (!local _group) exitWith {false};
if (_group isEqualType objNull) then { _group = group _group; };

// orders
//_group setSpeedMode "FULL";
//_group setFormation "DIAMOND";
_group enableAttack false;
{
    _x disableAI "AUTOCOMBAT";
    //doStop _x; true
} count (units _group);

// Hunting loop
waitUntil {

    // performance
    waitUntil { sleep 1; simulationEnabled leader _group; };

    // find
    private _target = [_group, _radius, _area, _pos, _onlyPlayers] call FUNC(findClosestTarget);

    // act
    if (!isNull _target) then  {
        [_group, _target] call _fnc_rushOrders;
        if (EGVAR(danger,debug_functions)) then { format ["%1 taskRush: %2 targets %3 at %4M", side _group, groupID _group, name _target, floor (leader _group distance2d _target)] call EFUNC(danger,debugLog); };
        sleep _cycle;
    } else {
        sleep (_cycle * 4);
    };

    // end
    ((units _group) findIf {_x call EFUNC(danger,isAlive)} == -1)

};

// end
true
