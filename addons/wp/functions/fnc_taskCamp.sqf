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
 * 3: Area the AI Camps in, default [] <ARRAY>
 * 4: Teleport <BOOL>
 * 5: Patrol <BOOL>
 *
 * Return Value:
 * none
 *
 * Example:
 * [bob, getPos bob, 50] call lambs_wp_fnc_taskCamp;
 *
 * Public: Yes
*/
// init
params [
    ["_group", grpNull, [grpNull, objNull]],
    ["_pos", [0, 0, 0]],
    ["_range", TASK_CAMP_SIZE, [0]],
    ["_area", [], [[]], []],
    ["_teleport", TASK_CAMP_TELEPORT, [false]],
    ["_patrol", TASK_CAMP_PATROL, [false]]
];

if (canSuspend) exitWith { [FUNC(taskCamp), _this] call CBA_fnc_directCall; };

// sort grp
if (!local _group) exitWith {false};
if (_group isEqualType objNull) then {_group = group _group};
private _units = (units _group) select {!isPlayer _x && {isNull objectParent _x}};

// sort pos
if (_pos isEqualTo []) then { _pos = _group; };
_pos = _pos call CBA_fnc_getPos;

// remove all waypoints
//[_group] call CBA_fnc_clearWaypoints;

// orders
_group setBehaviour "SAFE";
_group setSpeedMode "LIMITED";
_group setCombatMode "YELLOW";


// find buildings
private _buildings = [_pos, _range, false, false] call EFUNC(main,findBuildings);
[_buildings, true] call CBA_fnc_shuffle;

// find guns
private _weapons = nearestObjects [_pos, ["Landvehicle"], _range, true];
_weapons = _weapons select {(_x emptyPositions "Gunner") > 0};
if !(_area isEqualTo []) then {
    _area params ["_a", "_b", "_angle", "_isRectangle"];
    _weapons = _weapons select {(getPos _x) inArea [_pos, _a, _b, _angle, _isRectangle]};
    _buildings = _buildings select {(getPos _x) inArea [_pos, _a, _b, _angle, _isRectangle]};
};

// STAGE 1 - PATROL --------------------------
if (_patrol) then {
    private _group2 = createGroup [(side _group), true];
    [selectRandom _units] join _group2;
    if (count _units > 4)  then { [selectRandom units _group] join _group2; };

    // performance
    if (dynamicSimulationEnabled _group) then {
        [_group2, true] remoteExecCall ["enableDynamicSimulation", 2];
    };

    // id
    _group2 setGroupIDGlobal [format ["Patrol (%1)", groupId _group2]];

    // orders
    if (_area isEqualTo []) then {
        [_group2, _group2, _range * 2, 4, nil, true] call FUNC(taskPatrol);
    } else {
        private _area2 = +_area;
        _area2 set [0, (_area2 select 0) * 2];
        _area2 set [0, (_area2 select 1) * 2];
        [_group2, _group2, _range * 2, 4, _area2, true] call FUNC(taskPatrol);
    };

    // update
    _units = units _group;
};

// STAGE 2 - GUNS & BUILDINGS ---------------
reverse _units;
{
    // gun
    if !(_weapons isEqualTo []) then {
        private _staticWeapon = (_weapons deleteAt 0);
        if (_teleport) then { _x moveInGunner _staticWeapon; };
        _x assignAsGunner _staticWeapon;
        [_x] orderGetIn true;
        _units set [_foreachIndex, objNull];
    };

    if (!(_buildings isEqualTo []) && { RND(0.6) }) then {
        _x setUnitPos "UP";
        private _buildingPos = selectRandom ((_buildings deleteAt 0) buildingPos -1);
        if (_teleport) then { _x setPos _buildingPos; };
        _x doMove _buildingPos;
        [
            {
                params ["_unit"];
                unitReady _unit
            },
            {
                params ["_unit", "_target"];
                if (surfaceIsWater (getPos _unit) || (_unit distance _target > 2)) exitWith { _unit doFollow (leader _unit); };
                doStop _unit;
                _unit setUnitPos selectRandom ["UP", "UP", "MIDDLE"];
            },
            [_x, _buildingPos]
        ] call CBA_fnc_waitUntilAndExecute;
        _units set [_foreachIndex, objNull];
    };
    if ((count _units) < (count (units _group))*0.5) exitWith {};

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
    "aidlpknlmstpslowwrfldnon_g03"
];

// direction
private _dir = random 360;
{
    _dir = _dir + (360 / count _units) - random (180 / count _units);
    private _range = 1.35 + random 3.3;
    private _pos2 = [(_pos select 0) + (sin _dir) * _range, (_pos select 1) + (cos _dir) * _range, 0];

    // teleport
    if (_teleport) then {
        _x setPos _pos2;
        _x setDir (_x getDir _pos);
    };

    // execute move
    doStop _x;
    _x doMove _pos2;
    _x setDestination [_pos2, "LEADER DIRECT", false];

    // sort anims
    private _anims = _unarmedAnims;
    if !(primaryWeapon _x isEqualTo "") then {_anims append _armedAnims};

    // wait for it
    [{
        params ["_unit"];
        unitReady _unit
    }, {
        params ["_unit", "_target", "_center", "_anim"];
        if (surfaceIsWater (getPos _unit) || (_unit distance2D _target > 1)) exitWith { _unit doFollow (leader _unit); };
        [_unit, _anim, 2] call EFUNC(main,doAnimation);

        _unit disableAI "ANIM";
        _unit disableAI "PATH";
        _unit setDir (_unit getDir _center);
        _unit addEventHandler ["Hit", {
            params ["_unit"];
            {
                [_x, "ANIM"] remoteExec ["enableAI", _x];
                [_x, "PATH"] remoteExec ["enableAI", _x];
            } foreach units _unit;
            [_unit, "", 2] call EFUNC(main,doAnimation);

            _unit removeEventHandler ["Hit", _thisEventHandler];
        }];
        _unit addEventHandler ["FiredNear", {
            params ["_unit"];
            {
                [_x, "ANIM"] remoteExec ["enableAI", _x];
                [_x, "PATH"] remoteExec ["enableAI", _x];
            } foreach units _unit;
            [_unit, "", 2] call EFUNC(main,doAnimation);

            _unit removeEventHandler ["FiredNear", _thisEventHandler];
        }];
    }, [_x, _pos2, _pos, selectRandom _anims]] call CBA_fnc_waitUntilAndExecute;

} forEach _units;

// waypoint and end state
private _wp = _group addWaypoint [_pos, 0];
_wp setWaypointType "SENTRY";
_wp setWaypointStatements ["true", "
    if (local this) then {
        {
            _x enableAI 'ANIM';
            _x enableAI 'PATH';
            [_x, '', 2] call lambs_main_fnc_doAnimation;
        } foreach thisList;
    };"
];

// followup orders - just stay put or move into buildings!
private _wp2 = _group addWaypoint [[_pos, getPos selectRandom _buildings] select (count _buildings > 4), _range / 4];
_wp2 setWaypointType selectRandom ["HOLD", "GUARD", "SAD"];

// debug
if (EGVAR(main,debug_functions)) then {
    format ["%1 taskCamp: %2 established camp", side _group, groupID _group] call EFUNC(main,debugLog);
};

// end
true
