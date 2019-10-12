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
params ["_group", "_pos"];
private _range = waypointCompletionRadius [_group, currentwaypoint _group];

// sort grp
if (!local _group) exitWith {};
if (_group isEqualType objNull) then { _group = (group _group); };

// wp fix
if (_range isEqualTo 0) then { _range = 25; };

// orders
_group setBehaviour "AWARE";
_group setSpeedMode "NORMAL";

// add WP
for "_i" from 0 to 2 do {
    private _wp = _group addWaypoint [_pos, _range * _i];
    _wp setWaypointType (["MOVE", "MOVE", "SAD"] select _i);
    _wp setWaypointStatements ["true", format ["
        if (local this) then {
            _buildings = [this, 28, true] call %1;
            _buildings pushBack getpos this;
            {_x doMove selectRandom _buildings;true} count thisList;
        };
    ", QEFUNC(danger,findBuildings)]];
};

// end
true
