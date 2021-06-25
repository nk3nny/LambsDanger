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
_groupMemory = _groupMemory select {(leader _unit) distance _x < 200 && {_unit distance _x > 1.5}};
if (_groupMemory isEqualTo []) exitWith {
    _group setVariable [QGVAR(groupMemory), _groupMemory, false];
    _unit doFollow (leader _unit);
    false
};

// leader sorts positions from nearest to furthest
if ((leader _unit) isEqualTo _unit) then {
    _groupMemory = _groupMemory apply {[_x distance2D _unit, _x]};
    _groupMemory sort true;
    _groupMemory = _groupMemory apply {_x select 1};
};

// check
private _pos = _groupMemory select 0;
private _distance2D = _unit distance2D _pos;
if (_pos isEqualType objNull) then {_pos = getPosATL _pos;};

// look at
_unit lookAt _pos;

// ACE3 ~ allows unit to clear buildings with aggression - nkenny
if (_distance2D < 12) then {_unit setVariable ["ace_medical_ai_lastFired", CBA_missionTime];};

// CQB or suppress
if (RND(0.9) || {_distance2D < 66}) then {
    // movement
    _unit forceSpeed 4;

    // execute CQB move
    _unit doMove _pos;
    _unit setDestination [_pos, "LEADER PLANNED", _distance2D < 15];

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
    // execute suppression
    _unit setUnitPosWeak "MIDDLE";
    _unit forceSpeed ([2, -1] select (getSuppression _unit > 0.8));
    [_unit, (AGLToASL _pos) vectorAdd [0.5 - random 1, 0.5 - random 1, random 1.5], true] call FUNC(doSuppress);
    _unit setVariable [QGVAR(currentTarget), _pos, GVAR(debug_functions)];
    _unit setVariable [QGVAR(currentTask), "Suppress (sympathetic)", GVAR(debug_functions)];
};

// update variable
if (RND(0.95) || {_distance2D < 4}) then {_groupMemory deleteAt 0;};
_group setVariable [QGVAR(groupMemory), _groupMemory, false];

// end
true
