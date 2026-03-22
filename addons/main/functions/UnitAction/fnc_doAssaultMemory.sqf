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

// positions too far away from group leader are ignored
private _leader = leader _unit;
_groupMemory = _groupMemory select {_leader distanceSqr _x < 20164 && {_unit distanceSqr _x > 2.25}};
if (_groupMemory isEqualTo []) exitWith {
    (units _unit) doFollow _leader;
    _group setVariable [QGVAR(groupMemory), [], false];
    false
};

// sort positions from nearest to furthest, putting priority on low floors for superior pathfinding
_groupMemory = _groupMemory apply {[floor (_x select 2), _x distance2D _leader, _x]};
_groupMemory sort true;
_groupMemory = _groupMemory apply {_x select 2};

// get distance
private _unitState = getUnitState _unit;
private _pos = [_groupMemory select 0, selectRandom _groupMemory] select (_unitState in ["PLANNING", "DELAY", "REPLAN", "WAIT"]);
private _distance2D = _unit distance2D _pos;
private _expectedDestination = (expectedDestination _unit) select 0;

// unit state exit - busy units keep folowing their targets(!)
if (_unitState isEqualTo "BUSY" && (_expectedDestination distanceSqr _pos < 16)) exitWith {
    true
};

// update variable - remove position within 5 meters that the soldier can see is clear.
if (_distance2D < 5) then {

    private _unitASL = eyePos _unit;
    private _index = _groupMemory findIf {_unit distanceSqr _x < 25 && {!lineIntersects [_unitASL, ((AGLToASL _x) vectorAdd [0, 0, 0.4]), _unit, objNull] || _unit distanceSqr _x < 4}};
    if (_index isNotEqualTo -1) then {_groupMemory deleteAt _index;};

};

// update group variable
_group setVariable [QGVAR(groupMemory), _groupMemory, false];

// adjust movePos if destination is far away
if (_distance2D > 20 && (insideBuilding _unit) isEqualTo 0) then {
    _pos = _pos getPos [20, _pos getDir _unit];
};

// adjust movePos
if (_distance2D < 20) then {
    private _nearMen = _pos nearEntities ["CAManBase", 0.5];
    if (_nearMen isNotEqualTo []) then {
        private _nearMan = _nearMen select 0;
        private _movePosASL = getPosASL _nearMan;
        private _lineIntersect = lineIntersectsSurfaces [_movePosASL vectorAdd [0, 0, 2], _movePosASL vectorAdd [-5 + random 10, -5 + random 10, -4], _nearMan, objNull, true, 1, "GEOM", "NONE"];
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
    _expectedDestination distanceSqr _pos > 4
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
