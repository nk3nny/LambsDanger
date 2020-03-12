#include "script_component.hpp"
/*
 * Author: nkenny
 * Sets the team in camp like behaviour.
 *  Larger groups will set out patrols
 *  Turrets may be manned
 *  Some buildings may be garrisoned
 *
 * Arguments:
 * 0: Group performing action, either unit <OBJECT> or group <GROUP>
 * 1: Central position camp should be made, <ARRAY>
 * 2: Range of patrols and turrets found, default is 50 meters <NUMBER>
 *
 * Return Value:
 * none
 *
 * Example:
 * [bob, getpos bob, 50] call lambs_wp_fnc_taskCamp;
 *
 * Public: No
*/
// init
params ["_group", ["_pos",[]], ["_range", 50], ["_area", [], [[]]]];

if (canSuspend) exitWith { [FUNC(taskArtilleryRegister), _this] call CBA_fnc_directCall; };

// sort grp
if (!local _group) exitWith {false};
if (_group isEqualType objNull) then {_group = group _group};
private _units = units _group select {!isPlayer _x && {isNull objectParent _x}};

// sort pos
if (_pos isEqualTo []) then { _pos = _group; };
_pos = _pos call cba_fnc_getPos;

// remove all waypoints
//[_group] call CBA_fnc_clearWaypoints;

// orders
_group setBehaviour "SAFE";
_group setSpeedMode "LIMITED";
_group setCombatMode "YELLOW";


// find buildings
private _buildings = [_pos, _range, true, false] call EFUNC(danger,findBuildings);
[_buildings, true] call CBA_fnc_shuffle;

// find guns
private _gun = nearestObjects [_pos, ["Landvehicle"], _range, true];
_gun = _gun select {(_x emptyPositions "Gunner") > 0};
if !(_area isEqualTo []) then {
    _area params ["_a", "_b", "_angle", "_isRectangle"];
    _gun = _gun select {(getPos _x) inArea [_pos, _a, _b, _angle, _isRectangle]};
    _buildings = _buildings select {(getPos _x) inArea [_pos, _a, _b, _angle, _isRectangle]};
};

// STAGE 1 - PATROL --------------------------
if (count _units > 4) then {
    private _group2 = createGroup (side _group);
    [selectRandom _units] join _group2;
    if (count _units > 6)  then { [selectRandom units _group] join _group2; };

    // performance
    [_group2, dynamicSimulationEnabled _group] remoteExecCall ["enableDynamicSimulation", 2];
    _group2 deleteGroupWhenEmpty true;

    // id
    _group2 setGroupIDGlobal [format ["Patrol (%1)", groupId _group2]];

    // orders
    if (_area isEqualTo []) then {
        [_group2, _group2, _range * 2] call FUNC(taskPatrol);
    } else {
        private _area2 = +_area;
        _area2 set [0, (_area2 select 0) * 2];
        _area2 set [0, (_area2 select 1) * 2];
        [_group2, _group2, _range * 2, 4, _area2] call FUNC(taskPatrol);
    };

    // update
    _units = units _group;
};

// STAGE 2 - GUNS & BUILDINGS ---------------
reverse _units;
{
    // gun
    if (count _gun > 0) then {
        _x assignAsGunner (_gun deleteAt 0);
        [_x] orderGetIn true;
        _x moveInGunner (_gun deleteAt 0);
        _units set [_foreachIndex, objNull];
    };

    if (!(_buildings isEqualTo []) && { RND(0.3) }) then {
        doStop _x;
        _x setUnitPos "UP";
        [
            {
                params ["_unit", ""];
                unitReady _unit
            },
            {
                params ["_unit", "_target"];
                if (surfaceIsWater (getPos _unit) || (_unit distance _target > 2)) exitWith { _unit doFollow (leader _unit); };
                doStop _unit;
                _unit setUnitPos selectRandom ["UP", "UP", "MIDDLE"];
            },
            [_x, _buildings deleteAt 0]
        ] call CBA_fnc_waitUntilAndExecute;
        _units set [_foreachIndex, objNull];
    };
    if (count _units < count units _group/2) exitWith {};

} forEach _units;

_units = _units - [objNull];

// STAGE 3 - STAND ABOUT ----------------

// sort anims
private _unarmedAnims = [
    selectRandom ["HubStandingUA_idle1", "HubStandingUA_idle2", "HubStandingUA_idle3", "HubStandingUA_move1", "HubStandingUA_move2"],
    selectRandom ["HubStandingUB_idle1", "HubStandingUB_idle2", "HubStandingUB_idle3", "HubStandingUB_move1"],
    selectRandom ["HubStandingUC_idle1", "HubStandingUC_idle2", "HubStandingUC_idle3", "HubStandingUC_move1", "HubStandingUC_move2"],
    selectRandom ["inbasemoves_handsbehindback1","inbasemoves_handsbehindback2"],
    "aidlpsitmstpsnonwnondnon_ground00",
    "amovpsitmstpsnonwnondnon_ground",
    "aidlpsitmstpsnonwnondnon_ground00",
    "amovpsitmstpsnonwnondnon_ground",
    "aidlpsitmstpsnonwnondnon_ground00",
    "amovpsitmstpsnonwnondnon_ground",
    "aidlpsitmstpsnonwnondnon_ground00",
    "amovpsitmstpsnonwnondnon_ground"
];

private _armedAnims = [
    "inbasemoves_patrolling1",
    "inbasemoves_patrolling2",
    "inbasemoves_patrolling1",
    "inbasemoves_patrolling2",
    "amovpsitmstpslowwrfldnon",
    "amovpsitmstpslowwrfldnon_smoking",
    "amovpsitmstpslowwrfldnon_weaponcheck1",
    "amovpsitmstpslowwrfldnon_weaponcheck2",
    "amovpknlmstpslowwrfldnon",
    "aidlpknlmstpslowwrfldnon_g01",
    "aidlpknlmstpslowwrfldnon_g02",
    "aidlpknlmstpslowwrfldnon_g03",
    "Acts_InjuredLyingRifle01",
    "Acts_InjuredLyingRifle02",
    "Acts_InjuredLyingRifle02_180"
];

// direction
private _dir = random 360;
{
    _dir = _dir + random (360 / count _units);
    private _range = 1.3 + random 3.3;
    private _pos2 = [(_pos select 0) + (sin _dir) * _range, (_pos select 1) + (cos _dir) * _range, 0];

    // execute move
    _x doMove _pos2;
    _x setDestination [_pos2, "LEADER DIRECT", false];

    // sort anims
    private _anims = _unarmedAnims;
    if !(primaryWeapon _x isEqualTo "") then {_anims append _armedAnims};

    // wait for it
    [
        {
            params ["_unit", "", "", ""];
            unitReady _unit
        },
        {
            params ["_unit", "_target", "_center", "_anim"];
            if (surfaceIsWater (getPos _unit) || (_unit distance2d _target > 1)) exitWith { _unit doFollow (leader _unit); };
            doStop _unit;
            [_unit, _anim] remoteExec ["switchMove", 0];
            _unit disableAI "ANIM";
            _unit disableAI "PATH";
            _unit setDir (_unit getDir _center);
            _unit addEventHandler ["Hit", {
                params ["_unit"];
                {
                    _x enableAI "ANIM";
                    _x enableAI "PATH";
                } foreach units _unit;
                _unit playMoveNow (["AmovPercMsprSlowWrflDf_AmovPpneMstpSrasWrflDnon", "AmovPercMsprSnonWnonDf_AmovPpneMstpSnonWnonDnon"] select (primaryWeapon _unit isEqualTo ""));
                _unit removeEventHandler ["Hit", _thisEventHandler]
                }
            ];
        },
        [_x, _pos2, _pos, selectRandom _anims]
    ] call CBA_fnc_waitUntilAndExecute;

} forEach _units;

// waypoint and end state
private _wp = _group addWaypoint [_pos, 0];
_wp setWaypointType "SENTRY";
_wp setWaypointStatements ["(behaviour this) isEqualTo 'COMBAT'", "
        {
            _x enableAI 'ANIM';
            _x enableAI 'PATH';
            _x playMoveNow (['AmovPercMsprSlowWrflDf_AmovPpneMstpSrasWrflDnon', 'AmovPercMsprSnonWnonDf_AmovPpneMstpSnonWnonDnon'] select (primaryWeapon _x isEqualTo ''));
        } foreach thisList;
    "
];

// followup orders - just stay put or move into buildings!
private _wp2 = _group addWaypoint [[_pos, selectRandom _buildings] select (count _buildings > 4), _range / 4];
_wp2 setWaypointType selectRandom ["HOLD", "GUARD", "SAD"];

// debug
if (EGVAR(danger,debug_functions)) then {
    format ["%1 taskCamp: %2 established camp (buildings spots %3)", side _group, groupID _group, count _buildings] call EFUNC(danger,debugLog);
};

// end
true
