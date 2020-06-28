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
 * Public: Yes
*/


// init
params [["_group", grpNull, [grpNull, objNull]]];

// sort group
if (!local _group) exitWith {false};
if (_group isEqualType objNull) then { _group = group _group; };

// units
private _units = units _group select {!isPlayer _x};

// make new group + adopt name
private _groupNew = createGroup [(side _group), true];
_groupNew setGroupIdGlobal [groupId _group];
_groupNew setFormation (formation _group);

// remove all current waypoints
[_group] call CBA_fnc_clearWaypoints;
_group deleteGroupWhenEmpty true;

// remove LAMBS group variables
_group setVariable [QGVAR(taskAssaultDestination), nil];
_group setVariable [QGVAR(taskAssaultMembers), nil];

// reset
{
    // check move
    _x doMove (getPosASL _x);

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

    // reset animations
    _x enableAI "ANIM";
    [_x, "" , 2] call EFUNC(main,doAnimation);
    _x playMove (["AmovPercMstpSlowWrflDnon","AmovPercMstpSnonWnonDnon"] select ((primaryWeapon _x) isEqualTo ""));

    // LAMBS variables
    _x setVariable [QEGVAR(danger,currentTask), nil, EGVAR(main,debug_functions)];
    _x setVariable [QEGVAR(danger,currentTarget), nil, EGVAR(main,debug_functions)];
    _x setVariable [QEGVAR(danger,disableAI), nil];
    _x setVariable [QEGVAR(danger,forceMove), true];        // one FSM cycle of forced movement to get AI into action! -nkenny

    // rejoin group
    [_x] joinSilent _groupNew;
    _x doFollow (leader _x);
} count _units;

// reset lambs variable
_groupNew setVariable [QEGVAR(danger,disableGroupAI), nil];

if (dynamicSimulationEnabled _group) then {
    [_groupNew, true] remoteExecCall ["enableDynamicSimulation", 2];
};
// reset move and behaviour
_groupNew move (getPosASL (leader _groupNew));
_groupNew setBehaviour "AWARE";

// end
true
