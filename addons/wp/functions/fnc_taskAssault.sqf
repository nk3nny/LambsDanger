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
if (!local _group) exitWith {};
_group = _group call CBA_fnc_getGroup;
_group enableAttack false;
_group allowFleeing 0;

// sort pos
_pos = _pos call CBA_fnc_getPos;

// sort wp
[_group, 0] setWaypointPosition [AGLtoASL _pos, -1];

// sort group
private _units = units _group select {!isPlayer _x && {isNull objectParent _x}};

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
    private _wp = waypointPosition [_group, 0];
    {
        _x call _fnc_unAssault;
        _x setUnitPosWeak "UP";
        _x doMove _wp;
        _x setDestination [_wp, "DoNotPlanFormation", false];
        _x forceSpeed ([ [_x, _wp] call EFUNC(danger,assaultSpeed), 24] select _retreat);
        _x setVariable [QEVAR(danger,forceMove), true];
    } foreach _units;

    // soft reset
    {_x call _fnc_softReset;} foreach (_units select {_x distance _wp < _threshold && {_x call EFUNC(danger,isAlive)}});

    // get unit focus
    _units = _units select {_x distance _wp > _threshold && {_x call EFUNC(danger,isAlive)}};

    // debug
        if (EGVAR(danger,debug_functions)) then {
            systemchat format ["%1 %2: %3 units moving %4m",
                side _group, 
                ["taskAssault", "taskRetreat"] select _retreat,
                count _units,
                round ( [ (_units select 0), leader _group] select ( _units isEqualTo [] ) distance _pos )
            ];
        };

    // delay and end
    sleep _cycle;
    _units isEqualTo []

};

// end
true
