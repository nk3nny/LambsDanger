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

// init --
params ["_group", "_pos", ["_retreat", TASK_ASSAULT_ISRETREAT ], ["_threshold", TASK_ASSAULT_DISTANCETHRESHOLD], [ "_cycle", TASK_ASSAULT_CYCLETIME], ["_useWaypoint", false]];

// sort grp
if (!local _group) exitWith {false};
_group = _group call CBA_fnc_getGroup;
_group enableAttack false;
_group allowFleeing 0;

// sort wp
if (_useWaypoint) then {
    _pos = [_group, (currentWaypoint _group) min ((count waypoints _group) - 1)];
};

// sort group
private _units = units _group select {!isPlayer _x && {_x call EFUNC(main,isAlive)} && {isNull objectParent _x}};

// add group variables
_group setVariable [QGVAR(taskAssaultDestination), _pos];
_group setVariable [QGVAR(taskAssaultMembers), _units];
_group setBehaviourStrong (["AWARE", "CARELESS"] select _retreat);
_group setSpeedMode "FULL";

// sort units
{
    _x setVariable [QEGVAR(danger,disableAI), true];
    _x disableAI "FSM";
    _x disableAI "COVER";
    _x disableAI "SUPPRESSION";
    _x setUnitPos "UP";

    // check retreat
    if (_retreat) then {
        _x disableAI "TARGET";
        _x disableAI "AUTOTARGET";
        _x switchMove "ApanPercMrunSnonWnonDf";
        _x playMoveNow selectRandom [
            "ApanPknlMsprSnonWnonDf",
            "ApanPknlMsprSnonWnonDf",
            "ApanPercMsprSnonWnonDf"
        ];
    };

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
                    _groupMembers = _groupMembers - [_unit];
                    _group setVariable [QGVAR(taskAssaultMembers), _groupMembers];

                    // handle
                    _handle call CBA_fnc_removePerFrameHandler;
                    _unit setVariable [QGVAR(taskAssault), nil];

                    // unit
                    [_unit, _retreat] call FUNC(doAssaultUnitReset);
                };

                // unAttack
                if ((currentCommand _unit) isEqualTo "ATTACK") then {
                    [_unit] joinSilent (createGroup [(side (group _unit)), true]);
                    [_unit] joinSilent _group;
                };

                // move
                if !((expectedDestination _unit select 0) isEqualTo _destination) then {_unit doMove _destination};
                _unit forceSpeed ([ [_unit, _destination] call EFUNC(danger,assaultSpeed), 24] select _retreat);
                _unit doWatch _destination;
                _unit setVariable [QEGVAR(danger,forceMove), true];

                // force move
                private _dir = 360 - (_unit getRelDir _destination);
                private _anim = [];

                // move right
                if (_dir > 250 && {_dir < 320}) then {
                    _anim append ["FastR", "FastRF"];
                };

                // move left
                if (_dir < 110 && {_dir > 40}) then {
                    _anim append ["FastL", "FastLF"];
                };

                // move back
                if (_dir > 150 && {_dir < 210}) then {
                    _anim pushBack "TactB";
                };

                // forward
                if (_anim isEqualTo []) then {_anim = ["FastF"];};

                // execute
                _unit playActionNow selectRandom _anim;
            },
            _cycle,
            [_x, _group, _retreat, _threshold]
        ] call CBA_fnc_addPerFrameHandler;
        _x setVariable [QGVAR(taskAssault), true];
    };

} foreach _units;

// execute move
waitUntil {

    // reset option
    if ((units _group) isEqualTo []) exitWith {true};

    // adjust pos
    private _wPos = _pos call CBA_fnc_getPos;

    // end if WP is odd
    if (_wPos isEqualTo [0,0,0]) exitWith {true};

    // debug
    if (EGVAR(main,debug_functions)) then {
        format ["%1 %2: %3 units moving %4M",
            side _group,
            ["taskAssault", "taskRetreat"] select _retreat,
            count (_group getVariable [QGVAR(taskAssaultMembers), []]),
            round ( [ (_units select 0), leader _group] select ( _units isEqualTo [] ) distance2D _wPos )
        ] call EFUNC(main,debugLog);
    };

    // delay and end
    sleep _cycle;
    _group getVariable [QGVAR(taskAssaultMembers), []] isEqualTo []

};

// clean up
_group setVariable [QGVAR(taskAssaultDestination), nil];
_group setVariable [QGVAR(taskAssaultMembers), nil];
_group setBehaviour "AWARE";

// debug
if (EGVAR(main,debug_functions)) then {
    format ["%1 %2 %3 Completed",
        side _group,
        ["taskAssault", "taskRetreat"] select _retreat,
        _group
    ] call EFUNC(main,debugLog);
};

// end
true
