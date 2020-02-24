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
 *
 * Return Value:
 * none
 *
 * Example:
 * [bob, 500] spawn lambs_wp_fnc_taskHunt;
 *
 * Public: No
*/

// 1. FIND TRACKER
params ["_group", ["_radius", 500], ["_cycle", 60 + random 30]];

// sort grp
if (!local _group) exitWith {};
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
while {{alive _x} count units _group > 0} do {

    // performance
    waitUntil { sleep 1; simulationEnabled (leader _group) };

    // find
    private _target = [_group, _radius] call FUNC(findClosestTarget);

    // settings
    private _combat = (behaviour (leader _group)) isEqualTo "COMBAT";
    private _onFoot = (isNull objectParent (leader _group));

    // GIVE ORDERS  ~~ Or double wait
    if (!isNull _target) then {
        _group move (_target getPos [random (linearConversion [50, 1000, (leader _group) distance _target, 25, 300, true]), random 360]);
        _group setFormDir ((leader _group) getDir _target);
        _group setSpeedMode "NORMAL";
        _group enableGunLights "forceOn";
        _group enableIRLasers true;

        // DEBUG
        if (EGVAR(danger,debug_functions)) then {systemchat format ["%1 taskHunt: %2 targets %3 at %4 Meters", side _group, groupID _group, name _target, floor (leader _group distance _target)]};

        // FLARE HERE
        if (!_combat && {_onFoot} && {RND(0.8)}) then { [leader _group] call _fnc_flare; };

        // BUILDING SUPPRESSION! <-- BRING IT!
        if (_combat && {(nearestBuilding _target distance2d _target < 25)}) then { { _x doSuppressiveFire ((getposASL _target) vectorAdd [random 2, random 2, 0.5 + random 3]); true } count units _group;};
    };

    // WAIT FOR IT!
    sleep _cycle;
};
