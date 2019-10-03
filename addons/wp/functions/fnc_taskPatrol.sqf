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
params ["_grp", "_pos"];
private _radius = waypointCompletionRadius [_grp, currentWaypoint _grp];

// sort grp
if (!local _grp) exitWith {};
if (_grp isEqualType objNull) then { _grp = group _grp; };

// wp fix
if (_radius isEqualTo 0) then { _radius = 200; };

// orders
_grp setBehaviour "SAFE";
_grp setSpeedMode "LIMITED";
_grp setCombatMode "YELLOW";
_grp setFormation selectRandom ["STAG COLUMN", "WEDGE", "ECH LEFT", "ECH RIGHT", "VEE", "DIAMOND"];
_grp enableGunLights "forceOn";

// pos
if (isNil "_pos") then { _pos = getPos (leader _grp); };
//private _p = getpos leader _grp;
//private _debug_color = selectRandom ["colorBlue", "colorYellow", "colorOrange", "ColorBrown"];  <-- fn_dotMarkers not part of this release

// Waypoints - Move
for "_i" from 1 to 4 do  {
    private _pos2 = _pos getPos [_radius, random 360];
    if (surfaceIsWater _pos2) then { _pos2 = _pos } else { _radius = _radius * 0.8; };
    private _wp = _grp addWaypoint [_pos2, 10];
    _wp setWaypointType "MOVE";
    _wp setWaypointTimeout [8, 10, 15];
    _wp setWaypointCompletionRadius 10;
    _wp setWaypointStatements ["true", "(group this) enableGunLights 'forceOn';"];
    //if (var_debug) then {[getWPPos _wp, format ["wp%1", _i], _debug_color] call nk_fnc_dotMarker;};
};

// CYCLE
private _wpX = _grp addWaypoint [_pos, 10];
_wpX setWaypointType "CYCLE";
//if (var_debug) then {[getWPPos _wpX, "cycle", "colorBLUE"] call nk_fnc_dotMarker;};

// debug
if (EGVAR(danger,debug_functions)) then {
    systemchat format ["danger.wp taskPatrol: %1 Patrols", groupID _grp];
};

// end
true
