#include "script_component.hpp"
/*
 * Author: nkenny
 * Unit assaults building positions or open terrain according ot enemy position
 *
 * Arguments:
 * 0: unit assaulting <OBJECT>
 * 1: enemy <OBJECT>
 * 2: range to find buildings, default 12 <NUMBER>
 *
 * Return Value:
 * boolean
 *
 * Example:
 * [bob, angryJoe] call lambs_main_fnc_doAssault;
 *
 * Public: No
*/
params ["_unit", ["_target", objNull], ["_range", 12], ["_doMove", false]];

// check if stopped
if (!(_unit checkAIFeature "PATH")) exitWith {false};

_unit setVariable [QGVAR(currentTarget), _target, GVAR(debug_functions)];
_unit setVariable [QGVAR(currentTask), "Assault", GVAR(debug_functions)];

// check visibility and target within 20 meters
private _vis = _unit distanceSqr _target < 400 && {[_unit, "FIRE", _target] checkVisibility [getPosWorld _unit, aimPos _target] isEqualTo 1};
private _buildings = [];
private _expectedDestination = (expectedDestination _unit) select 0;
private _pos = call {

    // can see target!
    if (_vis) exitWith {
        _unit doWatch _target;
        _doMove = true;
        getPosATL _unit
    };

    // get the hide
    private _getHide = _unit getHideFrom _target;
    private _distanceSqr = _unit distanceSqr _getHide;

    // busy units keep tracking their targets(!)
    private _unitState = getUnitState _unit;
    if (_unitState isEqualTo "BUSY" && (_expectedDestination distanceSqr _getHide < 6.25)) exitWith {
        _expectedDestination
    };

    // get buildings near target
    _buildings = [_getHide, _range, false, false] call FUNC(findBuildings);

    // no valid buildings
    if (_buildings isEqualTo []) exitWith {

        if (_unit call FUNC(isIndoor) && RND(GVAR(indoorMove))) exitWith {
            _unit setVariable [QGVAR(currentTask), "Stay inside", GVAR(debug_functions)];
            _unit doWatch _getHide;
            getPosATL _unit
        };

        // forget targets when too close
        if (_unit distance2D _getHide < 1.7) then {
            _unit forgetTarget _target;
        };

        // select target location
        _getHide
    };

    // pick the closest building and find all positions
    _buildings = (_buildings select 0) buildingPos -1;
    if (_unitState in ["DELAY", "PLANNING"]) then {reverse _buildings};

    // updates group memory variable (assumed position within 40m)
    if (_distanceSqr < 1600) then {
        private _group = group _unit;
        private _groupMemory = _group getVariable [QGVAR(groupMemory), []];
        if (_groupMemory isEqualTo []) then {
            _group setVariable [QGVAR(groupMemory), _buildings];
        };
    };

    // find position on the same floor as target and look towards enemy
    private _posASL2 = round ((getPosASL _target) select 2);
    private _index = _buildings findIf {RND(0.15) && (_unit distanceSqr _x > 2.25) && (_posASL2 isEqualTo (round ((AGLToASL _x) select 2))) && (_getHide distanceSqr _x < _distanceSqr)};
    private _movePos = [_buildings select _index, _getHide] select (_index isEqualTo -1);
    _unit lookAt _movePos;

    // adjust movePos
    if ((speed _unit) isEqualTo 0) then {
        private _nearMen = _movePos nearEntities ["CAManBase", 1];
        if (_nearMen isNotEqualTo []) then {
            private _nearMan = _nearMen select 0;
            private _movePosASL = getPosASL _nearMan;
            private _lineIntersect = lineIntersectsSurfaces [_movePosASL vectorAdd [0, 0, 2], _movePosASL vectorAdd [-8 + random 16, -8 + random 16, -4], _nearMan, objNull, true, 1, "GEOM", "NONE"];
            if (_lineIntersect isNotEqualTo []) then {
                _movePos = ASLToAGL ( ( _lineIntersect select 0 ) select 0 );
            };
        };
    };

    // exit
    _doMove = true;
    _movePos
};

// execute move
if (
    _expectedDestination distanceSqr _pos > 1
) then {

    // set stance and speed
    [_unit, _pos] call FUNC(doAssaultSpeed);
    _unit setUnitPosWeak (["UP", "MIDDLE"] select ( (stance _unit) isEqualTo "PRONE" || (getSuppression _unit) isNotEqualTo 0 ) );

    // set move
    if (_doMove) then {
        _unit doMove _pos;
    } else {
        _unit setDestination [_pos, "LEADER PLANNED", false];
    };
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
