#include "script_component.hpp"
/*
 * Author: nkenny
 * Tracker script
 *        Slower more deliberate tracking and attacking script
 *        Spawns flares to coordinate
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
 * [bob, 500] spawn lambs_wp_fnc_taskHunt;
 *
 * Public: No
*/
if !(canSuspend) exitWith {
    _this spawn FUNC(taskHunt);
};
// 1. FIND TRACKER
params ["_group", ["_radius", TASK_HUNT_SIZE], ["_cycle", TASK_HUNT_CYCLETIME], ["_area", [], [[]]], ["_pos", [], [[]]], ["_onlyPlayers", TASK_HUNT_PLAYERSONLY]];

// sort grp
if (!local _group) exitWith {false};
if (_group isEqualType objNull) then { _group = group _group; };

// 2. SET GROUP BEHAVIOR
_group setbehaviour "SAFE";
_group setSpeedMode "LIMITED";
_group enableAttack false;

// FUNCTIONS -------------------------------------------------------------

// FLARE SCRIPT
private _fnc_flare = {
    params ["_leader"];
    private _shootflare = "F_20mm_Red" createvehicle (_leader ModelToWorld [0, 0, 200]);
    _shootflare setVelocity [0, 0, -10];
};

// 3. DO THE HUNT SCRIPT! ---------------------------------------------------
waitUntil {

    // performance
    waitUntil { sleep 1; simulationEnabled (leader _group) };

    // find
    private _target = [_group, _radius, _area, _pos, _onlyPlayers] call FUNC(findClosestTarget);

    // settings
    private _combat = (behaviour (leader _group)) isEqualTo "COMBAT";
    private _onFoot = (isNull objectParent (leader _group));

    // give orders
    if (!isNull _target) then {
        _group move (_target getPos [random (linearConversion [50, 1000, (leader _group) distance _target, 25, 300, true]), random 360]);
        _group setFormDir ((leader _group) getDir _target);
        _group setSpeedMode "NORMAL";
        _group enableGunLights "forceOn";
        _group enableIRLasers true;

        // debug
        if (EGVAR(danger,debug_functions)) then {format ["%1 taskHunt: %2 targets %3 at %4M", side _group, groupID _group, name _target, floor (leader _group distance _target)] call EFUNC(danger,debugLog);};

        // flare
        if (!_combat && {_onFoot} && {RND(0.8)}) then { [leader _group] call _fnc_flare; };

        // suppress nearby buildings
        if (_combat && {(nearestBuilding _target distance2d _target < 25)}) then {
            {
                [_x, getPosASL _target] call EFUNC(danger,suppress);
                true
            } count units _group;
        };
    };

    // WAIT FOR IT! / end
    sleep _cycle;
    ((units _group) findIf {_x call EFUNC(danger,isAlive)} == -1)

};

// end
true
