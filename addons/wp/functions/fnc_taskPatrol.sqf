#include "script_component.hpp"
/*
 * Author: nkenny
 * Simple dynamic patrol script by nkenny
 *          Suitable for infantry units (not so much vehicles, boats or air-- that will have to wait!)
 *
 * Arguments:
 * 0: Group performing action, either unit <OBJECT> or group <GROUP>
 * 1: Position being searched, default group position <OBJECT or ARRAY>
 * 1: Range of tracking, default is 200 meters <NUMBER>
 *
 * Return Value:
 * none
 *
 * Example:
 * [bob, 500] call lambs_wp_fnc_taskRush;
 *
 * Public: No
*/

// Patrol script
// version 1.1
// by nkenny

/*



    Arguments:
        1. group or leader unit
        2. position
        3. Radius
*/

// init
params ["_group", ["_pos",[]], ["_radius", 200]];

// sort grp
if (!local _group) exitWith {};
if (_group isEqualType objNull) then { _group = group _group; };

// sort pos
if (_pos isEqualTo []) then {_pos = _group;};
_pos = _pos call cba_fnc_getPos;

// orders
_group setBehaviour "SAFE";
_group setSpeedMode "LIMITED";
_group setCombatMode "YELLOW";
_group setFormation selectRandom ["STAG COLUMN", "WEDGE", "ECH LEFT", "ECH RIGHT", "VEE", "DIAMOND"];
_group enableGunLights "forceOn";

// pos
if (isNil "_pos") then { _pos = getPos (leader _group); };

// Waypoints - Move
for "_i" from 1 to 4 do  {
    private _pos2 = _pos getPos [_radius * (1 - abs random [-1, 0, 1]), random 360];  // thnx Dedmen
    if (surfaceIsWater _pos2) then { _pos2 = _pos };
    private _wp = _group addWaypoint [_pos2, 10];
    _wp setWaypointType "MOVE";
    _wp setWaypointTimeout [8, 10, 15];
    _wp setWaypointCompletionRadius 10;
    _wp setWaypointStatements ["true", "(group this) enableGunLights 'forceOn';"];
};

// CYCLE
private _wpX = _group addWaypoint [_pos, 10];
_wpX setWaypointType "CYCLE";

// debug
if (EGVAR(danger,debug_functions)) then {
    systemchat format ["%1 taskPatrol: %2 Patrols", side _group, groupID _group];
};

// end
true
