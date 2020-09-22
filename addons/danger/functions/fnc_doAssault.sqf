#include "script_component.hpp"
/*
 * Author: nkenny
 * Unit assaults building positions or open terrain according ot enemy position
 *
 * Arguments:
 * 0: Unit assault cover <OBJECT>
 * 1: Enemy <OBJECT>
 * 2: Range to find buildings, default 30 <NUMBER>
 *
 * Return Value:
 * boolean
 *
 * Example:
 * [bob, angryJoe, 20] call lambs_danger_fnc_assault;
 *
 * Public: No
*/
params ["_unit", ["_target", objNull], ["_range", 20]];

_unit setVariable [QGVAR(currentTarget), _target, EGVAR(main,debug_functions)];
_unit setVariable [QGVAR(currentTask), "Assault", EGVAR(main,debug_functions)];

// settings
private _rangeBuilding = linearConversion [ 0, 200, _unit distance2D _target, 2.5, 22, true];

// Near buildings + sort near positions + add target actual location
private _buildings = [_target, _range, true, true] call EFUNC(main,findBuildings);
_buildings = _buildings select { _x distance _target < _rangeBuilding };

// set destination
private _pos = if (_buildings isEqualTo []) then {
    // unit is indoor and happy
    if (_unit call EFUNC(main,isIndoor) && {RND(GVAR(indoorMove))}) exitWith {
        _unit setVariable [QGVAR(currentTask), "Stay inside", EGVAR(main,debug_functions)];
        _unit getPos [random 1 + 0.2, _unit getDir _target];
    };

    // select
    _unit getHideFrom _target
} else {
    // add unit position to array
    _buildings pushBack getPosATL _target;

    // updates group memory variable
    private _group = group _unit;
    private _groupMemory = _group getVariable [QGVAR(CQB_pos), []];
    _groupMemory pushBackUnique selectRandom _buildings;
    _group setVariable [QGVAR(CQB_pos), _groupMemory];

    // select
    selectRandom _buildings
};

// stance and speed
_unit setUnitPosWeak selectRandom ["UP", "UP", "MIDDLE"];
_unit forceSpeed ([_unit, _pos] call FUNC(assaultSpeed));

// execute
_unit doMove _pos;
_unit setDestination [_pos, "FORMATION PLANNED", false];

// debug
if (EGVAR(main,debug_functions)) then {
    format ["%1 assaulting (%2 @ %3m)", side _unit, name _unit, round (_unit distance (_unit getHideFrom _target))] call EFUNC(main,debugLog);
    private _sphere = createSimpleObject ["Sign_Sphere10cm_F", ATLtoASL (_unit getHideFrom _target), true];
    _sphere setObjectTexture [0, [_unit] call EFUNC(main,debugObjectColor)];
    [{deleteVehicle _this}, _sphere, 10] call CBA_fnc_waitAndExecute;
};

// end
true
