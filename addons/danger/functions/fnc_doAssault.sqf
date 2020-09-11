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
_unit setUnitPosWeak selectRandom ["UP", "UP", "MIDDLE"];
_unit forceSpeed ([_unit, _target] call FUNC(assaultSpeed));
private _rangeBuilding = linearConversion [ 0, 200, _unit distance2D _target, 2.5, 22, true];

// Near buildings + sort near positions + add target actual location
private _buildings = [_target, _range, true, true] call EFUNC(main,findBuildings);
_buildings = _buildings select { _x distance _target < _rangeBuilding };

// set destination
private _pos = if (_buildings isEqualTo []) then {

    // indoor
    if (_unit call EFUNC(main,isIndoor) && {random 100 > GVAR(indoorMove)}) exitWith {
        _unit setVariable [QGVAR(currentTask), "Stay inside", EGVAR(main,debug_functions)];
        _unit doWatch _target;
        _unit getPos [random 1 + 0.2, _unit getDir _target];
    };

    // select
    _unit getHideFrom _target

} else {

    // add position
    _buildings pushBack getPosATL _target;

    // updates group variable
    private _groupVariable = group _unit getVariable [QGVAR(CQB_pos), []];
    _groupVariable pushBackUnique selectRandom _buildings;
    group _unit setVariable [QGVAR(CQB_pos), _groupVariable];

    // debug
    hint format ["CQB - %1   \n%2\n\n%3", side _unit, count _groupVariable, (_groupVariable apply {round (_unit distance2D _x), _x}) joinString "\n  "];    // debug

    // select
    selectRandom _buildings

};

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
