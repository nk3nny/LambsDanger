#include "script_component.hpp"
/*
 * Author: nkenny
 * Actualises flanking cycle
 *
 * Arguments:
 * 0: Units list <ARRAY>
 * 1: List of building/enemy positions <ARRAY>
 * 2: Cycles <NUMBER>
 *
 * Return Value:
 * bool
 *
 * Example:
 * [units bob] call lambs_danger_fnc_doGroupFlank;
 *
 * Public: No
*/

params ["_cycle", "_units", "_vehicles", "_pos", "_overwatch"];

// update
_units = _units select { _x call EFUNC(main,isAlive) && { _x distance2D (_pos select 0) > 10 } && { !isPlayer _x } };
_vehicles = _vehicles select { canFire _x };
_cycle = _cycle - 1;

{
    private _posASL = AGLtoASL (selectRandom _pos);

    // suppress
    if (!(terrainIntersectASL [eyePos _x, _posASL]) && {RND(0.65)}) then {

        _x doWatch ASLtoAGL _posASL;
        [_x, _posASL, true] call FUNC(doSuppress);

    } else {

        // manoeuvre
        _x forceSpeed 4;
        _x setUnitPosWeak "MIDDLE";
        _x setVariable [QGVAR(currentTask), "Group Flank", EGVAR(main,debug_functions)];
        //_x setVariable [QGVAR(forceMove), getSuppression _x > 0.5];

        // force movement
        _x doMove _overwatch;

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
        FUNC(doGroupFlank),
        [_cycle, _units, _vehicles, _pos, _overwatch],
        12 + random 9
    ] call CBA_fnc_waitAndExecute;
};

// end
true