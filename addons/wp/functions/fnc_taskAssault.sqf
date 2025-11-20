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
_group setVariable [QEGVAR(danger,isExecutingTactic), false, true];
_group setVariable [QEGVAR(main,groupMemory), [], true];

// forget all targets!
private _targets = _group targets [true];
{_group forgetTarget _x} forEach _targets;

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
    _x disableAI "WEAPONAIM";
    _x disableAI "FSM";
    _x disableAI "COVER";
    _x disableAI "SUPPRESSION";

    // variable
    _x setVariable [QEGVAR(main,currentTask), ["Rushing Assault", "Rushing Retreat"] select _retreat, EGVAR(main,debug_functions)];

    // check retreat
    if (_retreat) then {
        _x disableAI "AUTOTARGET";
        _x disableAI "FIREWEAPON";
        [QEGVAR(main,doSwitchMove), [_x, "ApanPercMrunSnonWnonDf"]] call CBA_fnc_globalEvent;
        private _animation = selectRandom [
            "ApanPknlMsprSnonWnonDf",
            "ApanPknlMsprSnonWnonDf",
            "ApanPercMsprSnonWnonDf"
        ];
        [{[QEGVAR(main,doSwitchMove), [_this select 0, _this select 1]] call CBA_fnc_globalEvent;}, [_x, _animation], 1 + random 1] call CBA_fnc_waitAndExecute;
    };

    // fired EH
    private _firedEH = _x addEventHandler ["Fired", {
        params ["_unit"];
        _unit forceSpeed 2;
    }];

    // dodge hits
    private _hitEH = _x addEventHandler ["Hit", {
        params ["_unit", "", "", "_shooter"];
        private _stance = stance _unit;

        // tune stance
        if (_stance isEqualTo "PRONE") exitWith {};
        if (_stance isEqualTo "CROUCH" && {_unit distanceSqr _shooter > 900}) exitWith {_unit setUnitPos "DOWN";};
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
                if (!alive _unit || {_unit distance2D _destination < _threshold} || {_destination isEqualTo [0,0,0]}) exitWith {

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
                _unit doMove (_unit getPos [(_unit distance2D _destination) * 0.5, _unit getDir _destination]);
                _unit forceSpeed 24;
                _unit setUnitPos (["UP", "MIDDLE"] select (RND(0.85) || (stance _unit) isEqualTo "PRONE"));
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

    // adjust for vehicles
    if (_vehicles isNotEqualTo []) then {
        private _adjustPos = _wPos findEmptyPosition [0, 10];
        if (_adjustPos isNotEqualTo []) then {_wPos = _adjustPos;};

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
        } forEach (_vehicles select {unitReady _x});
    };

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
