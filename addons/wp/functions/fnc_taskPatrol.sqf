#include "script_component.hpp"
// Patrol script
// version 1.1
// by nkenny

/*
  ** WAYPOINT EDITION **

  Simple dynamic patrol script by nkenny
  Suitable for infantry units (not so much vehicles, boats or air-- that will have to wait!)

  Arguments:
    1. group or leader unit
    2. position
    //2. Radius   <-- not for this verison
*/

// init
private _grp = param [0];
private _r = waypointCompletionRadius [_grp,currentwaypoint _grp];
private _n = 4;

// sort grp
if (!local _grp) exitWith {};
_grp = [_grp] call {if (typeName _grp == "OBJECT") exitWith {group _grp};_grp};

// wp fix
if (_r isEqualTo 0) then {_r = 200;};

// orders
_grp setBehaviour "SAFE";
_grp setSpeedMode "LIMITED";
_grp setCombatMode "YELLOW";
_grp setFormation selectRandom ["STAG COLUMN", "WEDGE", "ECH LEFT", "ECH RIGHT", "VEE", "DIAMOND"];
_grp enableGunLights "forceOn";

// pos
private _p = param [1,getpos leader _grp];
//private _p = getpos leader _grp;
//private _debug_color = selectRandom ["colorBlue","colorYellow","colorOrange","ColorBrown"];  <-- fn_dotMarkers not part of this release

// Waypoints - Move
for "_i" from 1 to _n do  {
    _p2 = _p getPos [_r,random 360];
    if (surfaceIsWater _p2) then {_p2 = _p} else {_r = _r * 0.8;};
    _wp = _grp addWaypoint [_p2,10];
    _wp setWaypointType "MOVE";
    _wp setWaypointTimeout [8,10,15];
    _wp setWaypointCompletionRadius 10;
    _wp setWaypointStatements ["true","(group this) enableGunLights 'forceOn';"];
    //if (var_debug) then {[getWPPos _wp,format ["wp%1",_i],_debug_color] call nk_fnc_dotMarker;};
};

// CYCLE
_wpX = _grp addWaypoint [_p,10];
_wpX setWaypointType "CYCLE";
//if (var_debug) then {[getWPPos _wpX,"cycle","colorBLUE"] call nk_fnc_dotMarker;};

// debug
if (EGVAR(danger,debug_functions)) then {
    systemchat format ["danger.wp taskPatrol: %1 Patrols",groupID _grp];
};

// end
true
