#include "script_component.hpp"
/*
 * Author: nkenny
 * Unit performs suppressive fire on target location
 *
 * Arguments:
 * 0: unit suppressing <OBJECT>
 * 1: target position <OBJECT>, <ARRAY> (ASL position)
 * 2: do extended visibility checks <BOOLEAN>, default false
 * 3: do higher rate of fire <BOOLEAN>, default false
 *
 * Return Value:
 * success
 *
 * Example:
 * [bob, eyePos angryJoe] call lambs_main_fnc_doSuppress;
 *
 * Public: No
*/
params [["_unit", objNull], [ "_pos", [0, 0, 0], [[], objNull]], ["_checkLOS", false, [false]], ["_highROF", false, [false]]];

// object
if (_pos isEqualType objNull) then {_pos = getPosWorld _pos;};

// no primary weapons exit? Player led groups do not auto-suppress
private _eyePos = getPosWorld _unit;
if (
    (primaryWeapon _unit) isEqualTo ""
    || (currentCommand _unit) isEqualTo "Suppress"
    || terrainIntersectASL [_eyePos, _pos]
    || (isPlayer (leader _unit) && GVAR(disablePlayerGroupSuppression))
    || {_checkLOS && {!([_unit, _pos, false] call FUNC(shouldSuppressPosition))}}
) exitWith {false};

// get weapon max range and cache it ~ nkenny
private _baseWeapon = [primaryWeapon _unit] call BIS_fnc_baseWeapon;
private _maxRange = 50;

// check for the hashMap
if (isNil QGVAR(cachedWeaponsRangesHash)) then {
    GVAR(cachedWeaponsRangesHash) = createHashMap;
};

// get or make a new entry
if (_baseWeapon in GVAR(cachedWeaponsRangesHash)) then {
    _maxRange = GVAR(cachedWeaponsRangesHash) get _baseWeapon;
} else {
    private _modes = [_baseWeapon, true] call CBA_fnc_getWeaponModes;
    _modes = _modes select { (getNumber (configFile >> "CfgWeapons" >> _baseWeapon >> _x >> "requiredOpticType") ) < 1 };  // sort away optics
    {
        private _newRange = getNumber (configFile >> "CfgWeapons" >> _baseWeapon >> _x >> "maxRange");
        if (_newRange > _maxRange) then {_maxRange = _newRange};
    } forEach _modes;
    GVAR(cachedWeaponsRangesHash) set [_baseWeapon, _maxRange];
};

// override for maximum fire-rate
if (_highROF) then {_maxRange = 80;};

// max range pos
private _distance = _eyePos vectorDistance _pos;
if (_distance > _maxRange) then {

    // adjust target distance
    _pos = _eyePos vectorAdd (
        (_eyePos vectorFromTo _pos) vectorMultiply _maxRange
    );

    // approximate ballistic compensation (happy medium between all calibers)
    private _effectiveDistance = _distance - _maxRange;
    private _drop = 0.000042 * _effectiveDistance * _effectiveDistance;

    // raise artificial target
    private _height = _drop * (_maxRange / _distance);
    _pos set [2, (_pos select 2) + _height];

};

// adjust pos
private _vis = lineIntersectsSurfaces [_eyePos, _pos, _unit, objNull, true, 1, "VIEW", "NONE"];
if (_vis isNotEqualTo []) then {_pos = (_vis select 0) select 0;};

// final range check
if ((_eyePos vectorDistance _pos) < GVAR(minSuppressionRange)) exitWith {false};

// check for friendlies
private _friendlies = if (_distance > 200) then {[]} else {[_unit, ASLToAGL _pos, GVAR(minFriendlySuppressionDistance)] call FUNC(findNearbyFriendlies);};
if (_friendlies isNotEqualTo []) exitWith {false};

// Callout!
if (RND(0.6)) then {
    [_unit, "Combat", "suppress"] call FUNC(doCallout);
};

// reAdjust
_pos = _eyePos vectorAdd ((_pos vectorDiff _eyePos) vectorMultiply 0.9);

// do it!
_unit doWatch (ASLToAGL _pos);
[{params ["_unit", "_pos"]; _unit doSuppressiveFire _pos;}, [_unit, _pos], floor random 2] call CBA_fnc_waitAndExecute;

// Suppressive fire
_unit setVariable [QGVAR(currentTask), "Suppress!", GVAR(debug_functions)];
_unit setVariable [QGVAR(currentTarget), _pos, GVAR(debug_functions)];

// debug
if (GVAR(debug_functions)) then {
    ["%1 Suppression (%2 @ %3m)", side _unit, name _unit, round _distance] call FUNC(debugLog);

    private _sphere = createSimpleObject ["Sign_Sphere100cm_F", _pos, true];
    _sphere setObjectTexture [0, [_unit] call FUNC(debugObjectColor)];
    [{deleteVehicle _this}, _sphere, 20] call CBA_fnc_waitAndExecute;
};

// end
true
