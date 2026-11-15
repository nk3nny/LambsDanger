#include "script_component.hpp"
/*
 * Author: nkenny
 * Unit performs a mutual assault or suppressive fire on a location listed in the group "memory"
 *
 * Arguments:
 * 0: unit assaulting <OBJECT>
 * 1: group memory <ARRAY>
 * 2: current target <OBJECT>
 *
 * Return Value:
 * boolean
 *
 * Example:
 * [bob] call lambs_main_fnc_assaultMemory;
 *
 * Public: No
*/
params ["_unit", ["_groupMemory", []], ["_target", objNull]];

// check if stopped
if (!(_unit checkAIFeature "PATH")) exitWith {false};

// check it
private _group = group _unit;
if (_groupMemory isEqualTo []) then {
    _groupMemory = _group getVariable [QGVAR(groupMemory), []];
};

// positions too far away from group leader are ignored (142m normal, 44m when player is leader)
private _leader = leader _unit;
private _distanceSqr = [20164, 1936] select (isPlayer _leader);
_groupMemory = _groupMemory select {_leader distanceSqr _x < _distanceSqr && {_unit distanceSqr _x > 2.25}};
if (_groupMemory isEqualTo []) exitWith {

    // every unit within 12 meters returns to formation
    ((units _group) select {_unit distanceSqr _x < 144}) doFollow _leader;
    _group setVariable [QGVAR(groupMemory), [], false];
    false
};

// sort positions from nearest to furthest, putting priority on low floors for superior pathfinding
_groupMemory = _groupMemory apply {[floor (_x select 2), _leader distance2D _x, _x]};
_groupMemory sort true;
_groupMemory = _groupMemory apply {_x select 2};
private _pos = _groupMemory select 0;

// unit state exit - busy units keep following their path (4m)
private _expectedDestination = (expectedDestination _unit) select 0;
private _unitState = getUnitState _unit;
if (_unitState isEqualTo "BUSY" && (_expectedDestination distanceSqr _pos < 16 || _expectedDestination distanceSqr _target < 16)) exitWith {
    true
};

// unit seems to be stuck or unable to move. See if you have a moving ally. Use that as reference.
private _unitStuck = _unitState in ["PLANNING", "DELAY", "REPLAN", "WAIT"];
if (_unitStuck) then {
    private _buddy = (units _unit) select {speed _x > 0};
    if (_buddy isNotEqualTo []) then {_pos = getPosATL (_buddy select 0)};
};

// Check positions within 5 meters that the soldier can see is clear
private _distance2D = _unit distance2D _pos;
if (_distance2D < 5) then {

    private _unitASL = eyePos _unit;
    private _index = _groupMemory findIf {
        private _distanceSqr = _unit distanceSqr _x;
        _distanceSqr < 25
        && {
            !lineIntersects [_unitASL, ((AGLToASL _x) vectorAdd [0, 0, 0.4]), _unit, objNull]
            || _distanceSqr < 4
        }
    };
    if (_index isNotEqualTo -1) then {_groupMemory deleteAt _index;};

};

// update group variable
_group setVariable [QGVAR(groupMemory), _groupMemory, false];

// final position cleared - exit
if (_groupMemory isEqualTo []) exitWith {

    // every unit within 12 meters returns to formation
    [_unit, "danger", "Clear"] call FUNC(doCallout);
    ((units _group) select {_unit distanceSqr _x < 144}) doFollow _leader;
    false

};

// adjust movePos if destination is far away
if (_distance2D > 20 && (insideBuilding _unit) isEqualTo 0) then {
    _pos = _pos getPos [18, (_pos getDir _unit) - 10 + random 20];
};

// adjust movePos if close and/or man is present or unit stuck
if (_distance2D < 20) then {
    private _nearMen = _pos nearEntities ["CAManBase", 1];
    if (_nearMen isNotEqualTo [] || _unitStuck) then {
        _nearMen params [["_nearMan", objNull]];
        private _movePosASL = (AGLToASL _pos) vectorAdd [0, 0, 2];
        private _lineIntersect = lineIntersectsSurfaces [_movePosASL, _movePosASL vectorAdd [-5 + random 10, -5 + random 10, -4], _nearMan, objNull, true, 1, "GEOM", "NONE"];
        if (_lineIntersect isNotEqualTo []) then {
            _pos = ASLToAGL ( ( _lineIntersect select 0 ) select 0 );
        };
    };
};

// variables
_unit setVariable [QGVAR(currentTarget), _pos, GVAR(debug_functions)];
_unit setVariable [QGVAR(currentTask), "Assault (sympathetic)", GVAR(debug_functions)];

// execute move
if (
    _expectedDestination distanceSqr _pos > 16
) then {

    // set stance
    _unit setUnitPosWeak (["UP", "MIDDLE"] select (_distance2D > 8 || (getSuppression _unit) isNotEqualTo 0));

    // set speed
    [_unit, _pos] call FUNC(doAssaultSpeed);

    // set move
    _unit lookAt (_pos vectorAdd [0, 0, 1.2]);
    _unit doMove _pos;
};

// debug
if (GVAR(debug_functions)) then {
    ["%1 assaulting (sympathetic) (%2 @ %3m - %4 spots)", side _unit, name _unit, round (_unit distance _pos), count _groupMemory] call FUNC(debugLog);
    private _sphere = createSimpleObject ["Sign_Arrow_F", AGLToASL _pos, true];
    _sphere setObjectTexture [0, [_unit] call FUNC(debugObjectColor)];
    [{deleteVehicle _this}, _sphere, 12] call CBA_fnc_waitAndExecute;
};

// end
true
