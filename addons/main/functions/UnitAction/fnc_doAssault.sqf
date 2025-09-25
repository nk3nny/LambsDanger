#include "script_component.hpp"
/*
 * Author: nkenny
 * Unit assaults building positions or open terrain according ot enemy position
 *
 * Arguments:
 * 0: unit assaulting <OBJECT>
 * 1: enemy <OBJECT>
 * 2: range to find buildings, default 20 <NUMBER>
 *
 * Return Value:
 * boolean
 *
 * Example:
 * [bob, angryJoe, 20] call lambs_main_fnc_assault;
 *
 * Public: No
*/
params ["_unit", ["_target", objNull], ["_range", 12], ["_doMove", false]];

// check if stopped
if (!(_unit checkAIFeature "PATH")) exitWith {false};

_unit setVariable [QGVAR(currentTarget), _target, GVAR(debug_functions)];
_unit setVariable [QGVAR(currentTask), "Assault", GVAR(debug_functions)];

// get the hide
private _getHide = _unit getHideFrom _target;

// check visibility
private _vis = [objNull, "VIEW", objNull] checkVisibility [eyePos _unit, aimPos _target] isEqualTo 1;
private _buildings = [];
private _pos = call {

    // can see target!
    if (_vis) exitWith {
        _unit lookAt (ASLToAGL (aimPos _target));
        getPosATL _target
    };

    // near buildings
    _buildings = [_getHide, _range, true, false] call FUNC(findBuildings);
    private _distanceSqr = _unit distanceSqr _getHide;
    _buildings = _buildings select {_x distanceSqr _unit < _distanceSqr && {_x distanceSqr _unit > 2.25}};

    // target outdoors
    if (_buildings isEqualTo []) exitWith {

        if (_unit call FUNC(isIndoor) && {RND(GVAR(indoorMove))}) exitWith {
            _unit setVariable [QGVAR(currentTask), "Stay inside", GVAR(debug_functions)];
            _unit setUnitPosWeak "MIDDLE";
            _unit lookAt _getHide;
            getPosATL _unit
        };

        // forget targets when too close
        if (_unit distance2D _getHide < 1.7) then {
            _unit forgetTarget _target;
        };

        // select target location
        _doMove = true;
        _getHide
    };

    // updates group memory variable
    if (_unit distance2D _target < 40) then {
        private _group = group _unit;
        private _groupMemory = _group getVariable [QGVAR(groupMemory), []];
        if (_groupMemory isEqualTo []) then {
            _buildings pushBack _getHide;
            _group setVariable [QGVAR(groupMemory), _buildings];
        };
    };

    // look at target
    private _movePos = selectRandom _buildings;
    _unit lookAt _getHide;

    // adjust movePos
    private _nearMen = _movePos nearEntities ["CAManBase", 0.5];
    if (_nearMen isNotEqualTo []) then {
        private _nearMan = _nearMen select 0;
        private _movePosASL = getPosASL _nearMan;
        private _lineIntersect = lineIntersectsSurfaces [_movePosASL vectorAdd [0, 0, 2], _movePosASL vectorAdd [-5 + random 10, -5 + random 10, -4], _nearMan, objNull, true, 1, "GEOM", "VIEW"];
        if (_lineIntersect isNotEqualTo []) then {
            _movePos = ASLToAGL ( ( _lineIntersect select 0 ) select 0 );
        };
    };

    // exit
    _movePos
};

// stance and speed
[_unit, _pos] call FUNC(doAssaultSpeed);
_unit setUnitPosWeak (["UP", "MIDDLE"] select (getSuppression _unit > 0.3 || {_unit distance2D _pos < 2}));

// execute move
_unit setDestination [_pos, "LEADER PLANNED", false];
if (
    ((expectedDestination _unit) select 0) distanceSqr _pos > 1
) then {
    _unit moveTo _pos;
    if (_doMove) then {_unit doMove _pos;};
};

// debug
if (GVAR(debug_functions)) then {
    [
        "%1 %2 %3%4(%5 @ %6m)",
        side _unit,
        ["assaulting ", "staying inside "] select (_unit distance2D _pos < 1),
        ["(building) ", ""] select (_buildings isEqualTo []),
        ["", "(target visible) "] select _vis,
        name _unit,
        round (_unit distance _pos)
    ] call FUNC(debugLog);
    private _sphere = createSimpleObject ["Sign_Sphere10cm_F", AGLToASL _pos, true];
    _sphere setObjectTexture [0, [_unit] call FUNC(debugObjectColor)];
    [{deleteVehicle _this}, _sphere, 12] call CBA_fnc_waitAndExecute;
};

// end
true
