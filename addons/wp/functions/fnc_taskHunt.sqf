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
 * 6: enable dynamic reinforcement <BOOL>
 * 7: Enable Flare <BOOL> or <NUMBER> where 0 disabled, 1 enabled (if Units cant fire it them self a flare is created via createVehicle), 2 Only if Units can Fire UGL them self
 *
 * Return Value:
 * none
 *
 * Example:
 * [bob, 500] spawn lambs_wp_fnc_taskHunt;
 *
 * Public: Yes
*/

if !(canSuspend) exitWith {
    _this spawn FUNC(taskHunt);
};

// init
params [
    ["_group", grpNull, [grpNull, objNull]],
    ["_radius", TASK_HUNT_SIZE, [0]],
    ["_cycle", TASK_HUNT_CYCLETIME, [0]],
    ["_area", [], [[]]],
    ["_pos", [], [[]]],
    ["_onlyPlayers", TASK_HUNT_PLAYERSONLY, [false]],
    ["_enableReinforcement", TASK_HUNT_ENABLEREINFORCEMENT, [false]],
    ["_doUGL", TASK_HUNT_TRYUGLFLARE, 1, [1, true]]
];

// functions ---

// shoot flare
private _fnc_flare = {
    params ["_leader"];
    switch (_doUGL) do {
        case true;
        case 1: {
            private _units = units _leader;
            private _unitsPostUGL = [_units] call EFUNC(main,doUGL);
            if (_units isEqualTo _unitsPostUGL) then {
                private _flare = "F_20mm_Red" createVehicle (_leader ModelToWorld [0, 0, 200]);
                _flare setVelocity [0, 0, -10];
            };
        };
        case 2: {
            [group _leader] call EFUNC(main,doUGL);
        };
    };
};

// functions end ---

// sort grp
if (!local _group) exitWith {false};
if (_group isEqualType objNull) then { _group = group _group; };

// orders
_group setbehaviour "SAFE";
_group setSpeedMode "LIMITED";
_group enableAttack false;

// set group task
_group setVariable [QEGVAR(main,currentTactic), "taskHunt", EGVAR(main,debug_functions)];

if (_enableReinforcement) then {
    // dynamic reinforcements
    _group setVariable [QEGVAR(danger,enableGroupReinforce), true, true];
};

// hunt loop
waitUntil {

    // performance
    waitUntil { sleep 1; simulationEnabled (leader _group) };

    // find
    private _target = [_group, _radius, _area, _pos, _onlyPlayers] call EFUNC(main,findClosestTarget);

    // settings
    private _combat = (behaviour (leader _group)) isEqualTo "COMBAT";
    private _onFoot = isNull (objectParent (leader _group));

    // give orders
    if (!isNull _target) then {
        _group move (_target getPos [random (linearConversion [50, 1000, (leader _group) distance2D _target, 25, 300, true]), random 360]);
        _group setFormDir ((leader _group) getDir _target);
        _group setSpeedMode "NORMAL";
        _group enableGunLights "forceOn";
        _group enableIRLasers true;

        // debug
        if (EGVAR(main,debug_functions)) then {["%1 taskHunt: %2 targets %3 at %4M", side _group, groupID _group, name _target, floor (leader _group distance2D _target)] call EFUNC(main,debugLog);};

        // flare
        if (!_combat && {_onFoot} && {RND(0.8)}) then { [leader _group] call _fnc_flare; };
    };

    // wait for it or end
    sleep _cycle;
    (units _group) findIf {_x call EFUNC(main,isAlive)} == -1
};

// end
true
