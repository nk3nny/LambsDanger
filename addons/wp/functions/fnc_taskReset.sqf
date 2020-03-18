#include "script_component.hpp"
/*
 * Author: nkenny
 * Zeus module which resets units, cancelling garrisons, waypoints an all animation phases
 *
 * Arguments:
 * 0: Group performing action, either unit <OBJECT> or group <GROUP>
 *
 * Return Value:
 * none
 *
 * Example:
 * [bob] call lambs_wp_fnc_taskReset;
 *
 * Public: No
*/


// init
params ["_group"];

// sort group
if (!local _group) exitWith {false};
if (_group isEqualType objNull) then { _group = group _group; };

// units
private _units = units _group select {!isplayer _x};

// remove all current waypoints
[_group] call CBA_fnc_clearWaypoints;
_group deleteGroupWhenEmpty true;

// make new group + adopt name
private _groupNew = createGroup (side _group);
_groupNew setGroupIdGlobal [groupId _group];

// reset
{
    // AI states
    _x enableAI "MOVE";
    _x enableAI "PATH";
    _x enableAI "COVER";
    _x enableAI "SUPPRESSION";
    _x enableAI "FSM";
    _x enableAI "TARGET";
    _x enableAI "AUTOTARGET";

    // speed and stance
    _x forceSpeed -1;
    _x setUnitPos "AUTO";
    _x setUnitPosWeak "AUTO";

    // reset animations if necessary
    if !(_unit checkAIFeature "ANIM") then {
        _x enableAI "ANIM";
        _x switchMove "ApanPercMrunSnonWnonDf";
        _x playMoveNow selectRandom [
            "ApanPknlMsprSnonWnonDf",
            "ApanPknlMsprSnonWnonDf",
            "ApanPercMsprSnonWnonDf"
        ];
    };

    // LAMBS variables
    _x setVariable [QEGVAR(danger,disableAI), nil];
    _x setVariable [QEGVAR(danger,forceMove), true];        // one FSM cycle of forced movement to get AI into action! -nkenny

    // rejoin group
    [_x] joinSilent _groupNew;
    _x doFollow leader _x;
} count _units;

// reset lambs variable
_groupNew setVariable [QEGVAR(danger,disableGroupAI), nil];

// end
true

// TODO @ joko
/*

    1. Module does not need a dialogue
    2. Unit should be called 'Unit taskReset'  <-- this puts it at the bottom of alphabetic list
    3. Unit returns 'Unit orders reset' as Zeus notification if successful
    4. done 

*/