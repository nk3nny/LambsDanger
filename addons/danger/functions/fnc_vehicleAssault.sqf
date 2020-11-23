#include "script_component.hpp"
/*
 * Author: nkenny
 * Vehicle suppresses building locations and shoots main weapon
 *
 * Arguments:
 * 0: vehicle suppressing <OBJECT>
 * 1: target position <ARRAY>
 * 2: target of suppressing <OBJECT>
 * 3: predefined buildings, default none, <ARRAY>
 *
 * Return Value:
 * success
 *
 * Example:
 * [bob, getPos angryJoe, angryJoe] call lambs_danger_fnc_vehicleAssault;
 *
 * Public: No
*/
params ["_unit", "_pos", ["_target", objNull], ["_buildings", []]];

// settings + check
private _vehicle = vehicle _unit;

//  sort targets
if (
    isNull _target
    || {!canFire _vehicle}
    || {(_unit distance2D _target) < GVAR(minSuppressionRange)}
    || {terrainIntersectASL [eyePos _vehicle, eyePos _target]}
) exitWith {false};

// get target position
private _predictedPos = _unit getHideFrom _target;

// define buildings
private _visibility = [objNull, "VIEW", objNull] checkVisibility [eyePos _vehicle, ATLtoASL (_predictedPos vectorAdd [0, 0, 1 + random 1])];
if (_buildings isEqualTo [] && {_visibility < 0.5}) then {
    _buildings = [_target, 12, false, false] call EFUNC(main,findBuildings);
};

// find closest building
if !(_buildings isEqualTo []) then {
    _buildings = (selectRandom _buildings) buildingPos -1;
};

// add predicted location -- just to ensure shots fired!
_buildings pushBack _predictedPos;

// pos
_pos = selectRandom _buildings;

// look at position
_vehicle doWatch _pos;

// suppression
private _suppression = [_unit, _pos] call FUNC(vehicleSuppress);

// set task
_unit setVariable [QGVAR(currentTarget), _target, EGVAR(main,debug_functions)];
_unit setVariable [QGVAR(currentTask), "Vehicle Assault", EGVAR(main,debug_functions)];

// minor jink if no suppression possible
if (!_suppression) then {[_unit, 22] call FUNC(vehicleJink)};

// cannon direction ~ threshold 30 degrees
private _fnc_turretDir = {
    params ["_vehicle", "_pos", ["_threshold", 30]];
    private _array = _vehicle weaponDirection (currentWeapon _vehicle);
    private _atan = ((_array select 0) atan2 (_array select 1));
    _atan = [ _atan, _atan + 360 ] select ( _atan < 0 );
    _atan = ( ( _vehicle getDir _pos ) -_atan );
    _atan = [ _atan, _atan * -1 ] select ( _atan < 0 );
    _atan < _threshold
};

// shoot cannon ~ random chance and turret pointed right way
private _cannon = RND(0.2) && {_suppression} && {[_vehicle, _pos] call _fnc_turretDir};
if (_cannon) then {
    _vehicle action ["useWeapon", _vehicle, gunner _vehicle, random 2];
};

// debug
if (EGVAR(main,debug_functions)) then {
    [
        "%1 Vehicle assault building (%2 @ %3 buildingPos %4 %5)",
        side _unit,
        getText (configFile >> "CfgVehicles" >> (typeOf _vehicle) >> "displayName"),
        count _buildings,
        [""," suppressing targets"] select _suppression,
        [""," with cannon"] select _cannon
    ] call EFUNC(main,debugLog);

    private _m = [_unit, "", _unit call EFUNC(main,debugMarkerColor), "mil_arrow2"] call EFUNC(main,dotMarker);
    private _mt = [_pos, "", _unit call EFUNC(main,debugMarkerColor),"mil_destroy"] call EFUNC(main,dotMarker);
    {_x setMarkerSizeLocal [0.6, 0.6];} foreach [_m, _mt];
    _m setMarkerDirLocal (_unit getDir _target);
    [{{deleteMarker _x;true} count _this;}, [_m, _mt], 15] call CBA_fnc_waitAndExecute;
};

// end
true
