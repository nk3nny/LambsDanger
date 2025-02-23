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
 * [bob, getPos angryJoe, angryJoe] call lambs_main_fnc_doVehicleAssault;
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

// get target position ~ exit if target is unknown  -nkenny
private _predictedPos = _unit getHideFrom _target;
if (_predictedPos isEqualTo [0, 0, 0]) exitWith {false};

// define buildings
private _visibility = [objNull, "VIEW", _vehicle] checkVisibility [eyePos _vehicle, ATLToASL (_predictedPos vectorAdd [0, 0, 1.5])];
if (_buildings isEqualTo [] && {_visibility < 0.5}) then {
    _buildings = [_target, 12, false, false] call FUNC(findBuildings);
};

// get building positions
if (_buildings isNotEqualTo []) then {
    _buildings = (selectRandom _buildings) buildingPos -1;
};

// add predicted location -- just to ensure shots fired!
if (_buildings isEqualTo []) then {
    _predictedPos = ASLToAGL (ATLToASL _predictedPos);
    if ((nearestObjects [_predictedPos, ["house", "man"], 6]) isEqualTo []) then {_predictedPos set [2, 0.5]};
    _buildings pushBack _predictedPos;
};

// pos
_pos = selectRandom _buildings;

// look at position
_vehicle doWatch (AGLToASL _pos);

// suppression
private _suppression = [_unit, _pos] call FUNC(doVehicleSuppress);

// set task
_unit setVariable [QGVAR(currentTarget), _target, GVAR(debug_functions)];
_unit setVariable [QGVAR(currentTask), "Vehicle Assault", GVAR(debug_functions)];

// minor jink if no suppression possible
if (!_suppression) exitWith {[_unit, 35] call FUNC(doVehicleJink)};

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
if (GVAR(debug_functions)) then {
    [
        "%1 Vehicle assault building (%2 @ %3 positions%4%5)",
        side _unit,
        getText (configOf _vehicle >> "displayName"),
        count _buildings,
        [""," suppressing targets"] select _suppression,
        [""," with cannon"] select _cannon
    ] call FUNC(debugLog);

    private _m = [_unit, "", _unit call FUNC(debugMarkerColor), "mil_arrow2"] call FUNC(dotMarker);
    private _mt = [_pos, "", _unit call FUNC(debugMarkerColor),"mil_destroy"] call FUNC(dotMarker);
    {_x setMarkerSizeLocal [0.6, 0.6];} forEach [_m, _mt];
    _m setMarkerDirLocal (_unit getDir _target);
    [{{deleteMarker _x;true} count _this;}, [_m, _mt], 15] call CBA_fnc_waitAndExecute;
};

// end
true
