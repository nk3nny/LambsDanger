#include "script_component.hpp"
/*
 * Author: nkenny
 * Actualisation of Suppression cycle
 *
 * Arguments:
 * 0: cycles <NUMBER>
 * 1: units list <ARRAY>
 * 2: list of group vehicles <ARRAY>
 * 3: list of building/enemy positions <ARRAY>
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

// infantry
{
    // ready
    private _posAGL = selectRandom _pos;
    _posAGL = _posAGL vectorAdd [0, 0, linearConversion [0, 600, _x distance2D _posAGL, 0.5, 2, true]];

    // suppressive fire
    _x forceSpeed 1;
    _x setUnitPosWeak "MIDDLE";
    _x doWatch _posAGL;
    private _suppress = [_x, AGLtoASL _posAGL] call FUNC(doSuppress);
    _x setVariable [QGVAR(currentTask), "Group Suppress", EGVAR(main,debug_functions)];

    // no LOS
    if !(_suppress || {(currentCommand _x isEqualTo "Suppress")}) then {
        // move forward
        _x forceSpeed 3;
        _x doMove (_x getPos [12 + random 6, _x getDir _posAGL]);
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
if !(_cycle <= 1 || {_units isEqualTo []}) then {
    [
        {_this call FUNC(doGroupSuppress)},
        [_cycle - 1, _units, _vehicles, _pos],
        16 + random 2
    ] call CBA_fnc_waitAndExecute;
};

// end
true
