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

// settings
_unit setUnitPosWeak "UP";

// emergency break out of CQC loop
private _enemy = _unit findNearestEnemy _unit; 
if ((_unit distance _enemy) < 12) exitWith {

    _unit setVariable [QGVAR(currentTarget), _enemy];
    _unit setVariable [QGVAR(currentTask), "Assault Building (Enemy)"];

    // movement
    _unit doWatch objNull;
    _unit lookAt _enemy;
    _unit doMove (_unit getHideFrom _enemy);

    // return
    true
};

// get buildings
private _buildings = (group _unit) getVariable [QGVAR(inCQC), []];
_buildings = _buildings select {count (_x getVariable ["LAMBS_CQB_cleared_" + str (side _unit), [0, 0]]) > 0};

// exit on no buildings -- middle unit pos
if (count _buildings < 1) exitWith {
    _unit setUnitPosWeak "MIDDLE";
    _unit doFollow leader group _unit;
};

_unit setVariable [QGVAR(currentTarget), objNull];
_unit setVariable [QGVAR(currentTask), "Assault Building"];

// define building
private _building = (_buildings select 0);

// find spots
private _buildingPos = _building getVariable ["LAMBS_CQB_cleared_" + str (side _unit), (_building buildingPos -1) select {lineIntersects [AGLToASL _x, (AGLToASL _x) vectorAdd [0, 0, 4]]}];

// remove current target and do move
_unit doWatch objNull;
_unit lookAt (_buildingPos select 0);
_unit doMove ((_buildingPos select 0) vectorAdd [0.7 - random 1.4, 0.7 - random 1.4, 0]);

// Close range cleanups
if (_unit distance (_buildingPos select 0) < 3.2 || {random 1 > 0.95}) then {

    // remove buildingpos
    _buildingPos deleteAt 0;

    // update variable
    _building setVariable ["LAMBS_CQB_cleared_" + str (side _unit), _buildingPos];

} else {
    // distant units crouch
    if (_unit distance _building > 30) then {
        _unit setUnitPosWeak "MIDDLE";
    };
    // possibly teleport fix here
    // possibly suppression fire here
};

// update group variable
if (count _buildingPos < 1) then {
    (group _unit) setVariable [QGVAR(inCQC), _buildings - [_building]];
};

// debug
if (GVAR(debug_functions) && {leader _unit isEqualTo _unit}) then {systemchat format ["%1 CQC %2x spots @ %3m", side _unit, count (_building buildingPos -1), round (_unit distance _building)];};

// return
true
