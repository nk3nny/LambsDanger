#include "script_component.hpp"
/*
 * Author: nkenny
 * Vehicle suppresses building locations and shoots main weapon
 *
 * Arguments:
 * 0: vehicle suppressing <OBJECT>
 * 1: Target position <ARRAY>
 * 2: Target of suppressing <OBJECT>
 * 3: Predefined buildings, default none, <ARRAY>
 *
 * Return Value:
 * success
 *
 * Example:
 * [bob, getpos angryJoe, angryJoe] call lambs_danger_fnc_vehicleAssault;
 *
 * Public: Yes
*/
params ["_unit", "_pos", ["_target", objNull], ["_buildings", []]];

// settings + check
private _veh = vehicle _unit;
if (!canFire _veh) exitWith {false};

// tweaks target to remain usefully close
if ((_pos distance2d _unit) < 50) then {_pos = (_unit getHideFrom _target)};

//  target on foot
if ((_unit distance2d _pos) < GVAR(minSuppression_range)) exitWith {false};
if !(_target isKindOf "Man") exitWith {false};

// define buildings
if (_buildings isEqualTo []) then {
    _buildings = [_pos, 28, false, false] call FUNC(findBuildings);
};

// variables
_unit setVariable [QGVAR(currentTarget), _target];
_unit setVariable [QGVAR(currentTask), "Vehicle Assault"];

// find closest building
if !(_buildings isEqualTo []) then {
    _buildings = [_buildings, [], {_unit distance _x}, "ASCEND"] call BIS_fnc_sortBy;
    _buildings = if (random 1 > 0.4) then { _buildings select 0 } else { selectRandom _buildings };
    _buildings = _buildings buildingPos -1;
};

// add predicted location -- just to ensure shots fired!
_buildings pushBack _pos;

// pos
_pos = (AGLToASL (selectRandom _buildings)) vectorAdd [0.5 - random 1, 0.5 - random 1, 0.2 + random 1.2];

// minor manoeuvres -- moved to FSM
//[_veh, _unit getHideFrom _target] spawn FUNC(vehicleRotate);

// look at position
_veh doWatch _pos;

// suppression
_veh doSuppressiveFire _pos;

// cannon direction ~ threshold 30 degrees
private _fnc_turretDir = {
    params ["_veh", "_pos", ["_threshold", 30]];
    private _array = _veh weaponDirection (currentWeapon _veh);
    private _atan = ((_array select 0) atan2 (_array select 1));
    _atan = [ _atan, _atan + 360 ] select ( _atan < 0 );
    _atan = ( ( _veh getDir _pos ) -_atan );
    _atan = [ _atan, _atan * -1 ] select ( _atan < 0 );
    _atan < _threshold
};

// shoot cannon
private _cannon = (count _buildings > 2) && {random 1 > 0.2} && {(_veh distance _pos) > 80} && {[_veh, _pos] call _fnc_turretDir};
if (_cannon) then {
    _veh action ["useWeapon", _veh, gunner _veh, random 2];
};

// debug
if (GVAR(debug_functions)) then {systemchat format ["%1 Vehicle assault building (buildingPos: %2 cannon: %3)", side _unit, count _buildings, _cannon];};

// end
true
