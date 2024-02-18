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
 * [bob, angryJoe] call lambs_main_fnc_doGroupSuppress;
 *
 * Public: No
*/
params ["_cycle", "_units", "_vehicles", "_pos"];

// update
_units = _units select {_x call FUNC(isAlive) && { !isPlayer _x }};
_vehicles = _vehicles select { canFire _x };

// infantry
{
    // ready
    private _posAGL = selectRandom _pos;
    _posAGL = _posAGL vectorAdd [0, 0, random 1];

    // suppressive fire
    _x forceSpeed 1;
    _x setUnitPosWeak "MIDDLE";
    private _suppress = [_x, AGLtoASL _posAGL] call FUNC(doSuppress);
    _x setVariable [QGVAR(currentTask), "Group Suppress", GVAR(debug_functions)];

    // no LOS
    if !(_suppress || {(currentCommand _x isEqualTo "Suppress")}) then {
        // move forward
        _x forceSpeed 3;
        _x doMove (_x getPos [20, _x getDir _posAGL]);
        _x setVariable [QGVAR(currentTask), "Group Suppress (Move)", GVAR(debug_functions)];
    };

    // follow-up fire
    [
        {
            params ["_unit", "_posASL"];
            if (_unit call FUNC(isAlive) && {!(currentCommand _unit isEqualTo "Suppress")}) then {
                [_unit, _posASL vectorAdd [2 - random 4, 2 - random 4, 0.8], true] call EFUNC(main,doSuppress);
            };
        },
        [_x, AGLtoASL _posAGL],
        5
    ] call CBA_fnc_waitAndExecute;
} foreach _units;

// vehicles
{
    private _posAGL = selectRandom _pos;
    _x doWatch _posAGL;
    [_x, _posAGL] call FUNC(doVehicleSuppress);
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
