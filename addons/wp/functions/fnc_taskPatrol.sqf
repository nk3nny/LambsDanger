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
 * [bob, 500] call lambs_wp_fnc_taskPatrol;
 *
 * Public: No
*/

if (canSuspend) exitWith { [FUNC(taskPatrol), _this] call CBA_fnc_directCall; };

// init
params ["_group", ["_pos",[]], ["_radius", 200], ["_waypointCount", 4], ["_area", [], [[]]], ["_moveWaypoints", false]];

// sort grp
if (!local _group) exitWith {false};
if (_group isEqualType objNull) then { _group = group _group; };

// sort pos
if (_pos isEqualTo []) then { _pos = _group; };
_pos = _pos call cba_fnc_getPos;

// remove all waypoints
[_group] call CBA_fnc_clearWaypoints;

// orders
_group setBehaviour "SAFE";
_group setSpeedMode "LIMITED";
_group setCombatMode "YELLOW";
_group setFormation selectRandom ["STAG COLUMN", "WEDGE", "ECH LEFT", "ECH RIGHT", "VEE", "DIAMOND"];
_group enableGunLights "forceOn";

private _fistWPId = 0;
private _fnc_waypointStatement = "
    private _radius = %1;
    private _pos = %2;
    private _area = %3;
    private _group = group this;
    {
        if ((currentWaypoint _group) != (_x select 1)) then {
            private _pos2 = _pos getPos [_radius * (1 - abs random [-1, 0, 1]), random 360];
            if !(_area isEqualTo []) then {
                _pos2 = _pos getPos [(_radius *  1.2) * (1 - abs random [-1, 0, 1]), random 360];
                _area params ['_a', '_b', '_angle', '_isRectangle'];
                while {!(_pos2 inArea [_pos, _a, _b, _angle, _isRectangle])} do {
                    _pos2 = _pos getPos [(_radius * 1.2) * (1 - abs random [-1, 0, 1]), random 360];
                };
            };
            if (surfaceIsWater _pos2) then { _pos2 = _pos };
            _x setWPPos _pos2;
        };
    } forEach waypoints (group this);
";
private _wp = nil;
// Waypoints - Move
for "_i" from 1 to _waypointCount do {
    private _pos2 = _pos getPos [_radius * (1 - abs random [-1, 0, 1]), random 360];  // thnx Dedmen
    if !(_area isEqualTo []) then {
        _pos2 = _pos getPos [(_radius *  1.2) * (1 - abs random [-1, 0, 1]), random 360];
        _area params ["_a", "_b", "_angle", "_isRectangle"];
        while {!(_pos2 inArea [_pos, _a, _b, _angle, _isRectangle])} do {
            _pos2 = _pos getPos [(_radius * 1.2) * (1 - abs random [-1, 0, 1]), random 360];
        };
    };
    if (surfaceIsWater _pos2) then { _pos2 = _pos };
    _wp = _group addWaypoint [_pos2, 10];
    _wp setWaypointType "MOVE";
    _wp setWaypointTimeout [8, 10, 15];
    _wp setWaypointCompletionRadius 10;
    _wp setWaypointStatements ["true", "(group this) enableGunLights 'forceOn';"];
    if (_i == 1) then {
        _fistWPId = _wp select 1;
    };
};
if (_moveWaypoints) then {
    _wp setWaypointStatements ["true", format ["(group this) enableGunLights 'forceOn'; (group this) setCurrentWaypoint [(group this), %1];", _fistWPId] + format [_fnc_waypointStatement, _radius, _pos, _area]];
} else {
    _wp setWaypointStatements ["true", format ["(group this) enableGunLights 'forceOn'; (group this) setCurrentWaypoint [(group this), %1];", _fistWPId]];
};

// debug
if (EGVAR(danger,debug_functions)) then {
    format ["%1 taskPatrol: %2 Patrols", side _group, groupID _group] call EFUNC(danger,debugLog);
};

// end
true
