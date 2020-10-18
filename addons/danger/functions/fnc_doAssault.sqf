#include "script_component.hpp"
/*
 * Author: nkenny
 * Unit assaults building positions or open terrain according ot enemy position
 *
 * Arguments:
 * 0: Unit assaulting <OBJECT>
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
private _rangeBuilding = linearConversion [ 0, 150, _unit distance2D _target, 3.5, 22, true];

// Near buildings + sort near positions + add target actual location
private _buildings = [_target, _range, true, true] call EFUNC(main,findBuildings);
_buildings = _buildings select { _x distance _target < _rangeBuilding };

// set destination
private _pos = if (_buildings isEqualTo []) then {
    // unit is indoor and happy
    if (_unit call EFUNC(main,isIndoor) && {RND(GVAR(indoorMove))}) exitWith {
        _unit setVariable [QGVAR(currentTask), "Stay inside", EGVAR(main,debug_functions)];
        getPos _unit
    };

    // select
    _unit getHideFrom _target
} else {
    // add unit position to array
    _buildings pushBack getPosATL _target;

    // updates group memory variable
    private _group = group _unit;
    private _groupMemory = _group getVariable [QGVAR(groupMemory), []];
    _groupMemory pushBackUnique selectRandom _buildings;
    _group setVariable [QGVAR(groupMemory), _groupMemory];

    // select
    selectRandom _buildings
};

// stance and speed
_unit setUnitPosWeak selectRandom ["UP", "UP", "MIDDLE"];
_unit forceSpeed ([_unit, _pos] call FUNC(assaultSpeed));

// execute
_unit doMove _pos;
_unit setDestination [_pos, "FORMATION PLANNED", true];

// debug
if (EGVAR(main,debug_functions)) then {
    ["%1 assaulting %2(%3 @ %4m)", side _unit, ["Building ", ""] select (_buildings isEqualTo []), name _unit, round (_unit distance _pos)] call EFUNC(main,debugLog);
    private _sphere = createSimpleObject ["Sign_Sphere10cm_F", AGLtoASL _pos, true];
    _sphere setObjectTexture [0, [_unit] call EFUNC(main,debugObjectColor)];
    [{deleteVehicle _this}, _sphere, 12] call CBA_fnc_waitAndExecute;
};

// end
true
