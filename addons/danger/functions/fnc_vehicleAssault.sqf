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
 * [bob, getPos angryJoe, angryJoe] call lambs_danger_fnc_vehicleAssault;
 *
 * Public: No
*/
params ["_unit", "_pos", ["_target", objNull], ["_buildings", []]];

// settings + check
private _vehicle = vehicle _unit;
if (!canFire _vehicle) exitWith {false};

// tweaks target to remain usefully close
private _predictedPos = (_unit getHideFrom _target);
if ((_unit distance2D _pos) < 50) then {_pos = _predictedPos};

//  target not on foot or too close
if (
    isNull _target
    || {!(_target isKindOf "Man")}
    || {(_unit distance2D _predictedPos) < GVAR(minSuppression_range)}
    || {terrainIntersectASL [eyePos _vehicle, ATLtoASL _predictedPos]}
) exitWith {false};

// define buildings
if (_buildings isEqualTo []) then {
    _buildings = [_pos, 28, false, false] call EFUNC(main,findBuildings);
    //_buildings = _buildings select {!(terrainIntersect [getPos _unit, getPos _x])};
};

// set task
_unit setVariable [QGVAR(currentTarget), _target, EGVAR(main,debug_functions)];
_unit setVariable [QGVAR(currentTask), "Vehicle Assault", EGVAR(main,debug_functions)];

// find closest building
if !(_buildings isEqualTo []) then {
    _buildings = if (RND(0.4)) then { ([_buildings, [], {_unit distance _x}, "ASCEND"] call BIS_fnc_sortBy) select 0 } else { selectRandom _buildings };
    _buildings = _buildings buildingPos -1;
};

// add predicted location -- just to ensure shots fired!
_buildings pushBack _predictedPos;

// pos
_pos = AGLToASL (selectRandom _buildings);
private _vis = lineIntersectsSurfaces [eyePos _unit, _pos, _unit, vehicle _unit, true, 1];
if !(_vis isEqualTo []) then {_pos = (_vis select 0) select 0;};

// set max distance
private _distance = (_unit distance _pos) min 650;
_pos = (eyePos _unit) vectorAdd ((eyePos _unit vectorFromTo (AGLToASL (selectRandom _buildings))) vectorMultiply _distance);

// look at position
_vehicle doWatch ASLtoAGL _pos;

// recheck
if (_vehicle distance (ASLToAGL _pos) < GVAR(minSuppression_range)) exitWith {false};

// check for friendlies
private _friendlys = [_vehicle, (ASLToAGL _pos), GVAR(minFriendlySuppressionDistance) + 3] call EFUNC(main,findNearbyFriendly);
if !(_friendlys isEqualTo []) exitWith {false};

// suppression
_vehicle doSuppressiveFire _pos;

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

// shoot cannon ~ random chance, enough positions, 80m+ and turret pointed right way
private _cannon = RND(0.2) && {count _buildings > 2} && {(_vehicle distance _pos) > 80} && {[_vehicle, _pos] call _fnc_turretDir};
if (_cannon) then {
    _vehicle action ["useWeapon", _vehicle, gunner _vehicle, random 2];
};

// debug
if (EGVAR(main,debug_functions)) then {
    format ["%1 Vehicle assault building (%2 @ %3 buildingPos %4)", side _unit, getText (configFile >> "CfgVehicles" >> (typeOf _vehicle) >> "displayName"), count _buildings, [""," with cannon"] select _cannon] call EFUNC(main,debugLog);

    private _sphere = createSimpleObject ["Sign_Sphere100cm_F", _pos, true];
    _sphere setObjectTexture [0, [_unit] call EFUNC(main,debugObjectColor)];
    [{deleteVehicle _this}, _sphere, 20] call CBA_fnc_waitAndExecute;

};

// end
true
