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
if (!(_unit checkAIFeature "PATH")) exitWith {false};

// check it
private _group = group _unit;
if (_groupMemory isEqualTo []) then {
    _groupMemory = _group getVariable [QGVAR(groupMemory), []];
};

// exit or sort it!
_groupMemory = _groupMemory select {(leader _unit) distance2D _x < 150 && {_unit distance _x > 1.5}};
if (_groupMemory isEqualTo []) exitWith {
    _group setVariable [QGVAR(groupMemory), [], false];
    false
};

// sort positions from nearest to furthest
_groupMemory = _groupMemory apply {[_x distanceSqr _unit, _x]};
_groupMemory sort true;
_groupMemory = _groupMemory apply {_x select 1};

// check for enemy get position
private _nearestEnemy = _unit findNearestEnemy _unit;
if (
    _unit distance2D _nearestEnemy < 18
    && {(vehicle _nearestEnemy) isKindOf "CAManBase"}
) exitWith {
    [_unit, _nearestEnemy, 18, true] call FUNC(doAssault);
};

// get distance
private _pos = _groupMemory select 0;
private _distance2D = _unit distance2D _pos;
if (_pos isEqualType objNull) then {_pos = getPosATL _pos;};

// look at
_unit doWatch _pos;

// variables
_unit setVariable [QGVAR(currentTarget), _pos, GVAR(debug_functions)];
_unit setVariable [QGVAR(currentTask), "Assault (sympathetic)", GVAR(debug_functions)];

// CQB move
if (_distance2D < 55) then {

    // ACE3 ~ allows unit to clear buildings with aggression - nkenny
    if (_distance2D < 7) then {_unit setVariable ["ace_medical_ai_lastFired", CBA_missionTime];};

    // execute move
    _unit setUnitPosWeak (["UP", "MIDDLE"] select (getSuppression _unit > 0.7));
    _unit doMove _pos;
    _unit setDestination [_pos, "LEADER PLANNED", true];

    // update variable
    if (
        RND(0.97)
        || {_distance2D < 4 && {[objNull, "VIEW", objNull] checkVisibility [eyePos _unit, (AGLToASL _pos) vectorAdd [0, 0, 1]] isEqualTo 1}}
    ) then {
        _groupMemory deleteAt 0;
    };
};

// set speed
[_unit, _pos] call FUNC(doAssaultSpeed);

// variables
_group setVariable [QGVAR(groupMemory), _groupMemory, false];

// debug
if (GVAR(debug_functions)) then {
    ["%1 assaulting (sympathetic) (%2 @ %3m - %4 spots)", side _unit, name _unit, round (_unit distance _pos), count _groupMemory] call FUNC(debugLog);
    private _sphere = createSimpleObject ["Sign_Arrow_F", AGLtoASL _pos, true];
    _sphere setObjectTexture [0, [_unit] call FUNC(debugObjectColor)];
    [{deleteVehicle _this}, _sphere, 12] call CBA_fnc_waitAndExecute;
};

// end
true
