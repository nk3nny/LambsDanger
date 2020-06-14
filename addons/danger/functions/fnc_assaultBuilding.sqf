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

    _unit setVariable [QGVAR(currentTarget), _enemy, EGVAR(main,debug_functions)];
    _unit setVariable [QGVAR(currentTask), "Assault Building (Enemy)", EGVAR(main,debug_functions)];

    // movement
    //_unit doWatch objNull;
    _unit doTarget _enemy;
    _unit doFire _enemy;
    _unit doMove getPosATL _enemy;
    _unit forceSpeed ([_unit, _enemy] call FUNC(assaultSpeed));

    // debug
    if (EGVAR(main,debug_functions)) then {
        format ["%1 assault enemy (%2 @ %3m)", side _unit, name _unit, round (_unit distance _enemy)] call EFUNC(main,debugLog);
        private _arrow = createSimpleObject ["Sign_Arrow_Large_F", getPosASL _enemy, true];
        [{deleteVehicle _this}, _arrow, 20] call CBA_fnc_waitAndExecute;
    };

    // return
    true
};

// get buildings
private _buildings = (group _unit) getVariable [QGVAR(inCQC), []];
_buildings = _buildings select {count (_x getVariable [QGVAR(CQB_cleared_) + str (side _unit), [0, 0]]) > 0};

// exit on no buildings -- middle unit pos
if (_buildings isEqualTo []) exitWith {

    _unit doFollow leader _unit;

};

_unit setVariable [QGVAR(currentTarget), objNull, EGVAR(main,debug_functions)];
_unit setVariable [QGVAR(currentTask), "Assault Building", EGVAR(main,debug_functions)];

// define building
private _building = (_buildings select 0);

// find spots
private _buildingPos = _building getVariable [QGVAR(CQB_cleared_) + str (side _unit), (_building buildingPos -1) select {lineIntersects [AGLToASL _x, (AGLToASL _x) vectorAdd [0, 0, 4]]}];

private _buildingPosSelected = _buildingPos select 0;

if (isNil "_buildingPosSelected") then {
    _buildingPosSelected = _building modelToWorld [0,0,0];
};
// remove current target and do move
//_unit lookAt AGLtoASL _buildingPosSelected;
_unit doMove (_buildingPosSelected vectorAdd [0.5 - random 1, 0.5 - random 1, 0]);

// debug
if (EGVAR(main,debug_functions)) then {
    private _arrow = createSimpleObject ["Sign_Arrow_Large_F", AGLtoASL _buildingPosSelected, true];
    _arrow setObjectTexture [0, [_unit] call EFUNC(main,debugObjectColor)];
    [{deleteVehicle _this}, _arrow, 20] call CBA_fnc_waitAndExecute;
};

// speed
_unit forceSpeed ([_unit, _buildingPosSelected] call FUNC(assaultSpeed));

// Close range cleanups
if (RND(0.95) || {_unit distance _buildingPosSelected < 1.6}) then {

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
if (EGVAR(main,debug_functions) && {leader _unit isEqualTo _unit}) then {
    format ["%1 assaulting building (%2 @ %3m - %4x spots left)",
        side _unit,
        name _unit,
        round (_unit distance _buildingPosSelected),
        count _buildingPos
    ] call EFUNC(main,debugLog);
};

// return
true
