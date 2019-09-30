#include "script_component.hpp"
// Attack into buildings
// version 1.0
// by nkenny

/*
  ** WAYPOINT EDITION **
  Design
    Creates 2-3 Search adnd Destroy waypoint
    Makes unit check buildings at site
*/

// init
private _grp = param [0];
private _pos = param [1];
private _range = waypointCompletionRadius [_grp,currentwaypoint _grp];

// sort grp
if (!local _grp) exitWith {};
_grp = [_grp] call {if (typeName _grp == "OBJECT") exitWith {group _grp};_grp};

// wp fix
if (_range isEqualTo 0) then {_range = 25;};

// orders
_grp setBehaviour "AWARE";
_grp setSpeedMode "NORMAL";

// add WP
for "_i" from 0 to 2 do {
    _wp = _grp addWaypoint [_pos,_range * _i];
    _wp setWaypointType (["MOVE","MOVE","SAD"] select _i);
    _wp setWaypointStatements ["true", format ["
        if (local this) then {
            _buildings = [this,28,true] call %1;
            _buildings pushBack getpos this;
            {_x doMove selectRandom _buildings;true} count thisList;
        };
    ", QEFUNC(danger,nearBuildings)]];
};

// end
true
