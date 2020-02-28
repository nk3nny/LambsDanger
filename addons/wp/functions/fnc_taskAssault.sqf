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
 *
 * Return Value:
 * boolean
 *
 * Example:
 * [bob, getpos angryJoe] call lambs_wp_fnc_taskAssault;
 *
 * Public: Yes
*/

// functions ~ keep units moving!
private _fnc_unAssault = {
    params ["_unit"];
    if (currentCommand _unit isEqualTO "ATTACK") then {
        [_unit] joinSilent grpNull;
        [_unit] joinSilent _group;
    };
    if (_retreat) then {
        (group _unit) forgetTarget (_unit findNearestEnemy _unit);
        _unit doWatch ObjNull;
    };
    //_unit enableAI "COVER";
};

// functions ~ soft reset
private _fnc_softReset = {
    params ["_unit"];
    _unit forceSpeed -1;
    _unit setUnitPosWeak "AUTO";
    _unit enableAI "COVER";
    _unit enableAI "SUPPRESSION";
    //_unit enableAI "CHECKVISIBLE";
    if (_retreat) then {
        _unit switchMove (["AmovPercMsprSlowWrflDf_AmovPpneMstpSrasWrflDnon", "AmovPercMsprSnonWnonDf_AmovPpneMstpSnonWnonDnon"] select (primaryWeapon _unit isEqualTo ""));
    };
};

// init --
params ["_group", "_pos", ["_retreat", false ], ["_threshold", 10], [ "_cycle", 2] ];

// sort grp
if (!local _group) exitWith {false};
_group = _group call CBA_fnc_getGroup;
_group enableAttack false;
_group allowFleeing 0;

// sort pos
_pos = _pos call CBA_fnc_getPos;

// sort wp
private _wp_index = (currentWaypoint _group) min ((count waypoints _group) - 1);
//[_group, _wp_index] setWaypointPosition [AGLtoASL _pos, -1];  <-- Offending line  - nkenny

// debug
[waypointPosition [_group, _wp_index], "_wp origin", "colorBLUE"] call lambs_danger_fnc_dotMarker;
[_pos, "_pos", "colorRED"] call lambs_danger_fnc_dotMarker;
[player, str canSuspend, "colorYellow"] call lambs_danger_fnc_dotMarker;

// sort group
private _units = units _group select {!isPlayer _x && {_x call EFUNC(danger,isAlive)} && {isNull objectParent _x}};

// sort units
if (_retreat) then {
    {
        _x switchMove "ApanPercMrunSnonWnonDf";
        _x playMoveNow selectRandom [
            "ApanPknlMsprSnonWnonDf",
            "ApanPknlMsprSnonWnonDf",
            "ApanPercMsprSnonWnonDf"
        ];
    } foreach _units;
};

// execute move
waitUntil {

    // get waypoint position
    private _wp = waypointPosition [_group, _wp_index];

    [_wp, "_wp", "colorEAST"] call lambs_danger_fnc_dotMarker;

    // end if WP is odd
    if (_wp isEqualTo [0,0,0]) exitWith {true};

    // sort units
    {
        _x call _fnc_unAssault;
        _x setUnitPosWeak "UP";
        _x doMove _wp;
        _x setDestination [_wp, "DoNotPlanFormation", false];
        _x forceSpeed ([ [_x, _wp] call EFUNC(danger,assaultSpeed), 24] select _retreat);
        _x setVariable [QEGVAR(danger,forceMove), true];
    } foreach _units;

    // soft reset
    _units = _units select {_x call EFUNC(danger,isAlive)};
    {_x call _fnc_softReset;} foreach (_units select {_x distance2d _wp < _threshold});

    // get unit focus
    _units = _units select { _x distance2d _wp > _threshold };

    // debug
    if (EGVAR(danger,debug_functions)) then {
        systemchat format ["%1 %2: %3 units moving %4M",
            side _group,
            ["taskAssault", "taskRetreat"] select _retreat,
            count _units,
            round ( [ (_units select 0), leader _group] select ( _units isEqualTo [] ) distance2d _wp )
        ];
    };

    // delay and end
    sleep _cycle;
    _units isEqualTo []

};

// end
true