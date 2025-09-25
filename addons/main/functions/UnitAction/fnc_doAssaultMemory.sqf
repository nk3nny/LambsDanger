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
_groupMemory = _groupMemory select {_unit distanceSqr _x < 20164 && {_unit distanceSqr _x > 2.25}};
if (_groupMemory isEqualTo []) exitWith {
    _group setVariable [QGVAR(groupMemory), [], false];
    false
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
private _targets = _unit targets [true, 71];
_index = _targets findIf {
    private _getHideFrom = _unit getHideFrom _x;
    _unit distance2D _getHideFrom < _distance2D || {_unit distanceSqr _getHideFrom < 26};
};
if (_index isNotEqualTo -1) exitWith {
    [_unit, _targets select _index, 12, true] call FUNC(doAssault);
};

// adjust movePos if destination is far away
private _indoor = _unit call FUNC(isIndoor);
if (_distance2D > 20 && {!_indoor}) then {
    _pos = _unit getPos [20, _unit getDir _pos];
};
if (_pos isEqualType objNull) then {_pos = getPosATL _pos;};

// set stance
_unit setUnitPosWeak (["UP", "MIDDLE"] select (_indoor || {_distance2D > 8} || {(getSuppression _unit) isNotEqualTo 0}));

// set speed
[_unit, _pos] call FUNC(doAssaultSpeed);

// adjust movePos
private _nearMen = _pos nearEntities ["CAManBase", 0.5];
if (_nearMen isNotEqualTo []) then {
    private _nearMan = _nearMen select 0;
    private _movePosASL = AGLToASL _pos;
    private _lineIntersect = lineIntersectsSurfaces [_movePosASL vectorAdd [0, 0, 2], _movePosASL vectorAdd [-5 + random 10, -5 + random 10, -4], _nearMan, objNull, true, 1, "GEOM", "VIEW"];
    if (_lineIntersect isNotEqualTo [] && {_movePosASL vectorDistanceSqr ( ( _lineIntersect select 0 ) select 0 ) > 1}) then {
        _pos = ASLToAGL ( ( _lineIntersect select 0 ) select 0 );
    };
};

// variables
_unit setVariable [QGVAR(currentTarget), _pos, GVAR(debug_functions)];
_unit setVariable [QGVAR(currentTask), "Assault (sympathetic)", GVAR(debug_functions)];

// execute move
if (
    ((expectedDestination _unit) select 0) distanceSqr _pos > 1
) then {
    _unit lookAt (_pos vectorAdd [0, 0, 1.2]);
    _unit doMove _pos;
    _unit setDestination [_pos, "LEADER PLANNED", _indoor];
};

// update variable - remove positions within 5 meters that the soldier can see are clear.
private _unitASL = (getPosASLVisual _unit) vectorAdd [0, 0, 0.25];
_groupMemory = _groupMemory select {
    _unit distanceSqr _x > 25
    && {lineIntersects [_unitASL, AGLToASL (_x vectorAdd [0, 0, 0.25]), _unit, objNull]}
};

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
