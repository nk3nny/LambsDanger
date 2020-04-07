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
 * 5: Use Waypoints default false <BOOL>
 *
 * Return Value:
 * boolean
 *
 * Example:
 * [bob, getPos angryJoe] call lambs_wp_fnc_taskAssault;
 *
 * Public: Yes
*/
if !(canSuspend) exitWith {
    _this spawn FUNC(taskAssault);
};
// functions ~ keep units moving!
private _fnc_unAssault = {
    params ["_unit", "_group", "_retreat"];
    if ((currentCommand _unit) isEqualTo "ATTACK") then {
        [_unit] joinSilent grpNull;
        [_unit] joinSilent _group;
    };
    if (_retreat) then {
        (group _unit) forgetTarget (_unit findNearestEnemy _unit);
        _unit doWatch ObjNull;
    };
};

// functions ~ soft reset
private _fnc_softReset = {
    params ["_unit", "_retreat"];
    _unit setVariable [QEGVAR(danger,disableAI), nil];
    _unit forceSpeed -1;
    _unit setUnitPosWeak "AUTO";
    _unit enableAI "FSM";
    _unit enableAI "COVER";
    _unit enableAI "SUPPRESSION";
    //_unit enableAI "CHECKVISIBLE";
    if (_retreat) then {
        _unit switchMove (["AmovPercMsprSlowWrflDf_AmovPpneMstpSrasWrflDnon", "AmovPercMsprSnonWnonDf_AmovPpneMstpSnonWnonDnon"] select (primaryWeapon _unit isEqualTo ""));
        _unit enableAI "TARGET";
        _unit enableAI "AUTOTARGET";
    };
};

// init --
params ["_group", "_pos", ["_retreat", false ], ["_threshold", 15], [ "_cycle", 3], ["_useWaypoint", false]];

// sort grp
if (!local _group) exitWith {false};
_group = _group call CBA_fnc_getGroup;
_group enableAttack (!_retreat);
_group allowFleeing 0;

// sort wp
if (_useWaypoint) then {
    _pos = [_group, (currentWaypoint _group) min ((count waypoints _group) - 1)];
};

//[_group, _wp_index] setWaypointPosition [AGLtoASL _pos, -1];  <-- Offending line  - nkenny

// sort group
private _units = units _group select {!isPlayer _x && {_x call EFUNC(danger,isAlive)} && {isNull objectParent _x}};

// sort units
{
    _x setVariable [QEGVAR(danger,disableAI), true];
    _x disableAI "FSM";
    _x disableAI "COVER";
    _x disableAI "SUPPRESSION";
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
} foreach _units;

// execute move
waitUntil {

    // reset option
    if ((units _group) isEqualTo []) exitWith {true};

    // get waypoint position
    private _wPos = _pos call EFUNC(main,getPos);

    // end if WP is odd
    if (_wPos isEqualTo [0,0,0]) exitWith {true};

    // sort units
    {
        [_x, _group, _retreat] call _fnc_unAssault;
        _x setUnitPosWeak "UP";
        _x doMove _wPos;
        _x setDestination [_wPos, "LEADER PLANNED", false];
        //_x forceSpeed ([ [_x, _wPos] call EFUNC(danger,assaultSpeed), 24] select _retreat);
        _x forceSpeed ([ [3, 4] select (_x distance _wPos > 100), 24] select (_retreat || {speedMode _x isEQUALto "FULL"}));
        _x setVariable [QEGVAR(danger,forceMove), true];
    } foreach _units;

    // soft reset
    _units = _units select {_x call EFUNC(danger,isAlive)};

    {[_x, _retreat] call _fnc_softReset;} foreach (_units select {_x distance2d _wPos < _threshold});

    // get unit focus
    _units = _units select { _x distance2d _wPos > _threshold };

    // debug
    if (EGVAR(danger,debug_functions)) then {
        format ["%1 %2: %3 units moving %4M",
            side _group,
            ["taskAssault", "taskRetreat"] select _retreat,
            count _units,
            round ( [ (_units select 0), leader _group] select ( _units isEqualTo [] ) distance2d _wPos )
        ] call EFUNC(danger,debugLog);
    };

    // delay and end
    sleep _cycle;
    _units isEqualTo []

};

// check reset
{
    _x doMove getPosASL _x;
    [_x, false] call _fnc_softReset;    // nb: retreat value set to false to prevent animation from replaying. -nkenny
    true
} count (units _group select {!isPlayer _x});

// end
true
