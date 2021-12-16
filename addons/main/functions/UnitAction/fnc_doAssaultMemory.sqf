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
_groupMemory = _groupMemory select {(leader _unit) distance _x < 150 && {_unit distance _x > 2}};
if (_groupMemory isEqualTo []) exitWith {
    _group setVariable [QGVAR(groupMemory), [], false];
    _unit doFollow (leader _unit);
    false
};

// sort positions from nearest to furthest
_groupMemory = _groupMemory apply {[_x distance _unit, _x]};
_groupMemory sort true;
_groupMemory = _groupMemory apply {_x select 1};

// check for enemy get position
private _pos = [_groupMemory select 0, _unit findNearestEnemy _unit] select (_unit distance2D (_unit findNearestEnemy _unit) < 12);
private _distance2D = _unit distance2D _pos;
if (_pos isEqualType objNull) then {_pos = getPosATL _pos;};

// look at
_unit doWatch _pos;

// ACE3 ~ allows unit to clear buildings with aggression - nkenny
if (_distance2D < 7) then {_unit setVariable ["ace_medical_ai_lastFired", CBA_missionTime];};

// CQB
if (RND(0.9) || {_distance2D < 66}) then {
    // movement
    _unit setUnitPosWeak "UP";

    // execute CQB move
    _unit doMove _pos;
    _unit setDestination [_pos, "LEADER PLANNED", false];

    // variables
    _unit setVariable [QGVAR(currentTarget), _pos, GVAR(debug_functions)];
    _unit setVariable [QGVAR(currentTask), "Assault (sympathetic)", GVAR(debug_functions)];

    // debug
    if (GVAR(debug_functions)) then {
        ["%1 assaulting (sympathetic) (%2 @ %3m - %4 spots)", side _unit, name _unit, round (_unit distance _pos), count _groupMemory] call FUNC(debugLog);
        private _sphere = createSimpleObject ["Sign_Sphere10cm_F", AGLtoASL _pos, true];
        _sphere setObjectTexture [0, [_unit] call FUNC(debugObjectColor)];
        [{deleteVehicle _this}, _sphere, 12] call CBA_fnc_waitAndExecute;
    };
} else {
    // reset
    _unit setUnitPosWeak "MIDDLE";
};

// update variable
if (RND(0.9) || {_distance2D < 4}) then {_groupMemory deleteAt 0;};
_group setVariable [QGVAR(groupMemory), _groupMemory, false];

// end
true
