#include "script_component.hpp"
/*
 * Author: nkenny
 * Unit performs a mutual assault or suppressive fire on a location listed in the group "memory"
 *
 * Arguments:
 * 0: unit assaulting <OBJECT>
 * 1: group memory <ARRAY>
 *
 * Return Value:
 * boolean
 *
 * Example:
 * [bob] call lambs_main_fnc_assaultMemory;
 *
 * Public: No
*/
params ["_unit", ["_groupMemory", []]];

// check if stopped
if (!(_unit checkAIFeature "PATH") || {(getUnitState _unit) isEqualTo "PLANNING"}) exitWith {false};

// check it
private _group = group _unit;
if (_groupMemory isEqualTo []) then {
    _groupMemory = _group getVariable [QGVAR(groupMemory), []];
};

// exit or sort it!
_groupMemory = _groupMemory select {_unit distanceSqr _x < 20164 && {_unit distanceSqr _x > 2.25}};
if (_groupMemory isEqualTo []) exitWith {
    _group setVariable [QGVAR(groupMemory), [], false];
    false
};

// check for enemy get position
private _nearestEnemy = _unit findNearestEnemy _unit;
if (
    (_unit distanceSqr _nearestEnemy < 5041)
    && {(vehicle _nearestEnemy) isKindOf "CAManBase"}
    && {[objNull, "VIEW", objNull] checkVisibility [eyePos _unit, aimPos _nearestEnemy] isEqualTo 1 || {_unit distanceSqr _nearestEnemy < 64 && {(round (getPosATL _unit select 2)) isEqualTo (round ((getPosATL _nearestEnemy) select 2))}}}
) exitWith {
    [_unit, _nearestEnemy, 12, true] call FUNC(doAssault);
};

// sort positions from nearest to furthest prioritising positions on the same floor
private _unitASL2 = round ( ( getPosASL _unit ) select 2 );
_groupMemory = _groupMemory apply {[_unitASL2 + (round ((AGLToASL _x) select 2)), _x distanceSqr _unit, _x]};
_groupMemory sort true;
_groupMemory = _groupMemory apply {_x select 2};

// get distance
private _pos = _groupMemory select 0;
private _distance2D = _unit distance2D _pos;

// check for nearby enemy
if (_unit distance2D (_unit getHideFrom _nearestEnemy) < _distance2D) exitWith {
    [_unit, _nearestEnemy, 12, true] call FUNC(doAssault);
};

private _indoor = _unit call FUNC(isIndoor);
if (_distance2D > 20 && {!_indoor}) then {
    _pos = _unit getPos [20, _unit getDir _pos];
};
if (_pos isEqualType objNull) then {_pos = getPosATL _pos;};

// variables
_unit setVariable [QGVAR(currentTarget), _pos, GVAR(debug_functions)];
_unit setVariable [QGVAR(currentTask), "Assault (sympathetic)", GVAR(debug_functions)];

// set stance
_unit setUnitPosWeak (["UP", "MIDDLE"] select (_indoor || {_distance2D > 8} || {(getSuppression _unit) isNotEqualTo 0}));

// set speed
[_unit, _pos] call FUNC(doAssaultSpeed);

// ACE3 ~ allows unit to clear buildings with aggression - nkenny
if (_distance2D < 7) then {_unit setVariable ["ace_medical_ai_lastFired", CBA_missionTime];};

// execute move
_unit lookAt (_pos vectorAdd [0, 0, 1]);
_unit doMove _pos;
_unit setDestination [_pos, "LEADER PLANNED", _indoor];

// update variable
if (RND(0.95)) then {_groupMemory deleteAt 0;};
_groupMemory = _groupMemory select {_unit distanceSqr _x > 25 && {[objNull, "VIEW", objNull] checkVisibility [eyePos _unit, (AGLToASL _x) vectorAdd [0, 0, 0.5]] isEqualTo 0}};

// variables
_group setVariable [QGVAR(groupMemory), _groupMemory, false];

// debug
if (GVAR(debug_functions)) then {
    ["%1 assaulting (sympathetic) (%2 @ %3m - %4 spots)", side _unit, name _unit, round (_unit distance _pos), count _groupMemory] call FUNC(debugLog);
    private _sphere = createSimpleObject ["Sign_Arrow_F", AGLToASL _pos, true];
    _sphere setObjectTexture [0, [_unit] call FUNC(debugObjectColor)];
    [{deleteVehicle _this}, _sphere, 12] call CBA_fnc_waitAndExecute;
};

// end
true
