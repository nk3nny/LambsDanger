#include "script_component.hpp"
/*
 * Author: nkenny
 * Actualisation of Suppression cycle
 *
 * Arguments:
 * 0: Group leader <OBJECT>
 * 1: Group threat unit <OBJECT> or position <ARRAY>
 * 2: Units in group, default all <ARRAY>
 *
 * Return Value:
 * success
 *
 * Example:
 * [bob, angryJoe] call lambs_danger_fnc_doGroupSuppress;
 *
 * Public: No
*/
params ["_cycle", "_units", "_vehicles", "_pos"];

// update
_units = _units select {_x call EFUNC(main,isAlive) && { !isPlayer _x }};
_vehicles = _vehicles select { canFire _x };
_cycle = _cycle - 1;

// infantry
{
    // ready
    private _posAGL = selectRandom _pos;

    // suppressive fire
    _x forceSpeed 1;
    _x setUnitPosWeak "MIDDLE";
    _x doWatch _posAGL;
    private _suppress = [_x, AGLtoASL _posAGL, true] call FUNC(doSuppress);
    _x setVariable [QGVAR(currentTask), "Group Suppress", EGVAR(main,debug_functions)];

    // no LOS
    if !(_suppress) then {
        // move forward
        _x forceSpeed 3;
        _x doMove (_x getPos [8 + random 6, _x getdir _posAGL]);
        _x setVariable [QGVAR(currentTask), "Group Suppress (Move)", EGVAR(main,debug_functions)];
    };
} foreach _units;

// vehicles
{
    private _posAGL = selectRandom _pos;
    _x doWatch _posAGL;
    [_x, _posAGL] call FUNC(vehicleSuppress);
} foreach _vehicles;

// recursive cyclic
if (_cycle > 0 && {!(_units isEqualTo [])}) then {
    [
        FUNC(doGroupSuppress,)
        [_cycle, _units, _vehicles, _pos],
        2 + random 2
    ] call CBA_fnc_waitAndExecute;
};

// end
true
