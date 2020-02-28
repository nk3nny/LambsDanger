#include "script_component.hpp"
/*
 * Author: nkenny
 * Unit in CQC mode moves to clear nearest free building location as declared by group leader
 *
 * Arguments:
 * 0: Unit assault cover <OBJECT>
 *
 * Return Value:
 * boolean
 *
 * Example:
 * [bob] call lambs_danger_fnc_assaultBuilding;
 *
 * Public: No
*/
params ["_unit"];

// check if stopped or busy
if (
    stopped _unit
    || {!(_unit checkAIFeature "PATH")}
    || {!(_unit checkAIFeature "MOVE")}
    || {currentCommand _unit in ["GET IN", "ACTION", "HEAL", "ATTACK"]}
) exitWith {false};

// settings
_unit setUnitPosWeak "UP";

// emergency break out of CQC loop
private _enemy = _unit findNearestEnemy _unit;
if ((_unit distance _enemy) < 7) exitWith {

    _unit setVariable [QGVAR(currentTarget), _enemy];
    _unit setVariable [QGVAR(currentTask), "Assault Building (Enemy)"];

    // movement
    _unit doWatch objNull;
    _unit lookAt _enemy;
    _unit doMove getposATL _enemy; // changed from getHideFrom as this tends to pick a spot outside building - nkenny
    _unit forceSpeed ([_unit, _enemy] call FUNC(assaultSpeed));

    // return
    true
};

// get buildings
private _buildings = (group _unit) getVariable [QGVAR(inCQC), []];
_buildings = _buildings select {count (_x getVariable [QGVAR(CQB_cleared_) + str (side _unit), [0, 0]]) > 0};

// exit on no buildings -- middle unit pos
if (_buildings isEqualTo []) exitWith {
    _unit setUnitPosWeak "MIDDLE";
    _unit doFollow leader _unit;
};

_unit setVariable [QGVAR(currentTarget), objNull];
_unit setVariable [QGVAR(currentTask), "Assault Building"];

// define building
private _building = (_buildings select 0);

// find spots
private _buildingPos = _building getVariable [QGVAR(CQB_cleared_) + str (side _unit), (_building buildingPos -1) select {lineIntersects [AGLToASL _x, (AGLToASL _x) vectorAdd [0, 0, 4]]}];

// remove current target and do move
_unit doWatch objNull;
_unit lookAt (_buildingPos select 0);
_unit doMove ((_buildingPos select 0) vectorAdd [0.5 - random 1, 0.5 - random 1, 0]);

// speed
_unit forceSpeed ([_unit, (_buildingPos select 0)] call FUNC(assaultSpeed));

// Close range cleanups
if (RND(0.95) || {_unit distance (_buildingPos select 0) < 1.6}) then {

    // remove buildingpos
    _buildingPos deleteAt 0;

    // update variable
    _building setVariable [QGVAR(CQB_cleared_) + str (side _unit), _buildingPos];

} else {
    // distant units crouch
    if (_unit distance _building > 30) then {
        _unit setUnitPosWeak "MIDDLE";
    };
    // possibly teleport fix here
    // possibly suppression fire here
};

// update group variable
if (_buildingPos isEqualTo []) then {
    (group _unit) setVariable [QGVAR(inCQC), _buildings - [_building]];
};

// debug
if (GVAR(debug_functions) && {leader _unit isEqualTo _unit}) then {
    format ["%1 CQC %2 buildings - near %3x spots @ %4m", side _unit, count _buildings, count _buildingPos, round (_unit distance _building)] call FUNC(debugLog);
};

// return
true
