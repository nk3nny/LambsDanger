#include "script_component.hpp"
/*
 * Author: nkenny
 * Unit rushes heedlessly to position with an option to be in forced retreat
 *
 * Arguments:
 * 0: Unit fleeing <OBJECT>
 * 1: Destination <ARRAY>
 * 2: Forced retreat, default false <BOOL>
 * 3: Distance threshold, default 10 <NUMBER>
 * 4: Update cycle, default 2 <NUMBER>
 * 5: Is Called for Waypoint, default false <BOOL>
 *
 * Return Value:
 * boolean
 *
 * Example:
 * [bob, getPos angryJoe] spawn lambs_wp_fnc_taskAssault;
 *
 * Public: Yes
*/
if !(canSuspend) exitWith {
    _this spawn FUNC(taskAssault);
};

// init
params [
    ["_group", grpNull, [grpNull, objNull]],
    ["_pos", [0, 0, 0]],
    ["_retreat", TASK_ASSAULT_ISRETREAT, [false]],
    ["_threshold", TASK_ASSAULT_DISTANCETHRESHOLD, [0]],
    [ "_cycle", TASK_ASSAULT_CYCLETIME, [0]],
    ["_useWaypoint", false, [false]]
];

// sort group
if (!local _group) exitWith {false};
_group = _group call CBA_fnc_getGroup;

// sort wp
if (_useWaypoint) then {
    _pos = [_group, (currentWaypoint _group) min ((count waypoints _group) - 1)];
};

// sort group + vehicles
private _units = units _group select {!isPlayer _x && {_x call EFUNC(main,isAlive)} && {isNull objectParent _x}};
private _vehicles = [leader _group] call EFUNC(main,findReadyVehicles);

// add group variables
_group setVariable [QGVAR(taskAssaultDestination), _pos];
_group setVariable [QGVAR(taskAssaultMembers), _units];

// set group task
_group setVariable [QEGVAR(main,currentTactic), ["taskAssault", "taskRetreat"] select _retreat, EGVAR(main,debug_functions)];

// set group orders
_group setBehaviourStrong (["AWARE", "CARELESS"] select _retreat);
_group setCombatMode (["RED", "BLUE"] select _retreat);
_group enableAttack false;
_group allowFleeing 0;
_group setSpeedMode "FULL";
_group setFormation "LINE";

// sort units
{
    _x setVariable [QEGVAR(danger,disableAI), true];
    _x setVariable [QEGVAR(danger,forceMove), true];
    _x disableAI "TARGET";
    _x disableAI "FSM";
    _x disableAI "COVER";
    _x disableAI "SUPPRESSION";
    _x setUnitPos "UP";

    // variable
    _x setVariable [QEGVAR(main,currentTask), ["Rushing Assault", "Rushing Retreat"] select _retreat, EGVAR(main,debug_functions)];

    // check retreat
    if (_retreat) then {
        _x disableAI "AUTOTARGET";
        [_x, "ApanPercMrunSnonWnonDf"] remoteExec ["switchMove", 0];
        [_x, selectRandom [
            "ApanPknlMsprSnonWnonDf",
            "ApanPknlMsprSnonWnonDf",
            "ApanPercMsprSnonWnonDf"
        ]] remoteExec["switchMove", 0];
    };

    // fired EH
    private _firedEH = _x addEventHandler ["Fired", {
        params ["_unit"];
        _unit forceSpeed 2;
    }];

    // dodge hits
    private _hitEH = _x addEventHandler ["Hit", {
        params ["_unit", "", "", "_shooter"];
        private _unitPos = unitPos _unit;

        // tune stance
        if (_unitPos isEqualTo "Down") exitWith {};
        if (_unitPos isEqualTo "Middle" && {_unit distance2D _shooter > 30}) exitWith {_unit setUnitPos "DOWN";};
        _unit setUnitPos "MIDDLE";
    }];

    // variables
    _x setVariable [QGVAR(eventhandlers), [["Fired", _firedEH], ["Hit", _hitEH]]];

    // adds frame handler
    if (!(_x getVariable [QGVAR(taskAssault), false])) then {
        [
            {
                params ["_args", "_handle"];
                _args params ["_unit", "_group", "_retreat", "_threshold"];
                private _destination = (_group getVariable [QGVAR(taskAssaultDestination), getPos _unit]) call CBA_fnc_getPos;

                // exit
                if (!(_unit call EFUNC(main,isAlive)) || {_unit distance2D _destination < _threshold} || {_destination isEqualTo [0,0,0]}) exitWith {

                    // group
                    private _groupMembers = _group getVariable [QGVAR(taskAssaultMembers), []];
                    _group setVariable [QGVAR(taskAssaultMembers), _groupMembers - [_unit]];

                    // handle
                    _handle call CBA_fnc_removePerFrameHandler;
                    _unit setVariable [QGVAR(taskAssault), nil];

                    // unit
                    [_unit, _retreat] call FUNC(doAssaultUnitReset);
                };

                // handle get In get out
                private _currentCommand = currentCommand _unit;
                if (_currentCommand in ["GET IN", "GET OUT"] || {!isNull objectParent _unit}) exitWith {};

                // unAttack
                if (_currentCommand isEqualTo "ATTACK") then {
                    [_unit] joinSilent (createGroup [(side (group _unit)), true]);
                    [_unit] joinSilent _group;
                };

                // move
                if ((expectedDestination _unit select 0) isNotEqualTo _destination) then {_unit doMove _destination};
                _unit forceSpeed 24;
                _unit setUnitPos (["UP", "MIDDLE"] select (RND(0.5) && (unitPos _unit) isEqualTo "Down"));

                // no animation on retreat
                if (_retreat) exitWith {};

                // force move
                private _dir = 360 - (_unit getRelDir _destination);
                private _anim = call {
                    // move right
                    if (_dir > 240 && {_dir < 320}) exitWith {
                        ["TactR", "TactRF"];
                    };

                    // move left
                    if (_dir < 120 && {_dir > 40}) exitWith {
                        ["TactL", "TactLF"];
                    };

                    // move back
                    if (_dir > 120 && {_dir < 240}) exitWith {
                        "TactB"
                    };

                    // forward
                    "TactF"
                };

                // execute
                [_unit, _anim, true] call EFUNC(main,doGesture);
            },
            _cycle - 0.5 + random 1.2,
            [_x, _group, _retreat, _threshold]
        ] call CBA_fnc_addPerFrameHandler;
        _x setVariable [QGVAR(taskAssault), true];
    };
} forEach _units;


// execute move
waitUntil {

    // reset option
    if ((units _group) isEqualTo []) exitWith {true};

    // adjust pos
    private _wPos = _pos call CBA_fnc_getPos;

    // end if WP is odd
    if (_wPos isEqualTo [0,0,0]) exitWith {true};

    // get vehicles moving
    {
        private _vehicle = _x;

        // execute movement
        _vehicle doWatch _wPos;
        _vehicle doMove _wPos;

        // unload vehicles
        if (_vehicle distance _wPos < (_threshold * 2)) then {
            private _cargo =  ((fullCrew [_vehicle, "cargo"]) apply {_x select 0});
            _cargo append ((fullCrew [_vehicle, "turret"] select {_x select 4}) apply {_x select 0});
            _cargo orderGetIn false;
            _cargo allowGetIn false;
        };

    } forEach _vehicles;

    // debug
    if (EGVAR(main,debug_functions)) then {
        ["%1 %2: %3 units moving %4M",
            side _group,
            ["taskAssault", "taskRetreat"] select _retreat,
            count (_group getVariable [QGVAR(taskAssaultMembers), []]),
            round ([ (_units select 0), leader _group] select ( _units isEqualTo [] ) distance2D _wPos)
        ] call EFUNC(main,debugLog);
    };

    // delay and end
    sleep _cycle;
    _group getVariable [QGVAR(taskAssaultMembers), []] isEqualTo []
};

// clean up
_group setVariable [QGVAR(taskAssaultDestination), nil];
_group setVariable [QGVAR(taskAssaultMembers), nil];
_group setFormation "WEDGE";
_group setBehaviour "AWARE";
_group setCombatMode "YELLOW";
_group enableAttack true;

// debug
if (EGVAR(main,debug_functions)) then {
    ["%1 %2 %3 Completed",
        side _group,
        ["taskAssault", "taskRetreat"] select _retreat,
        _group
    ] call EFUNC(main,debugLog);
};

// end
true
