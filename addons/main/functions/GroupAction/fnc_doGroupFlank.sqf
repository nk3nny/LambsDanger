#include "script_component.hpp"
/*
 * Author: nkenny
 * Actualises flanking cycle
 *
 * Arguments:
 * 0: cycles <NUMBER>
 * 1: units list <ARRAY>
 * 2: list of group vehicles <ARRAY>
 * 3: list of building/enemy positions <ARRAY>
 * 4: destination <ARRAY>
 *
 * Return Value:
 * bool
 *
 * Example:
 * [units bob] call lambs_main_fnc_doGroupFlank;
 *
 * Public: No
*/
params ["_cycle", "_units", "_vehicles", "_pos", "_overwatch"];

// update
_units = _units select { _x call FUNC(isAlive) && { _x distance2D _overwatch > 12 } && { !isPlayer _x } };
_vehicles = _vehicles select { canFire _x };

{
    private _posASL = AGLtoASL (selectRandom _pos);

    // stance
    private _suppression = (getSuppression _x) > 0.5;
    _x setUnitPos (["MIDDLE", "DOWN"] select _suppression);

    // suppress
    if (RND(0.65) && {!(terrainIntersectASL [eyePos _x, _posASL vectorAdd [0, 0, 3]])}) then {
        [{_this call FUNC(doSuppress)}, [_x, _posASL vectorAdd [0, 0, random 1]], random 3] call CBA_fnc_waitAndExecute;
    } else {
        // manoeuvre
        _x forceSpeed 24;
        _x setVariable [QGVAR(currentTask), "Group Flank", GVAR(debug_functions)];
        _x setVariable [QEGVAR(danger,forceMove), !_suppression];
        //_x doWatch ASLtoAGL _posASL;
        _x doMove _overwatch;
        _x setDestination [_overwatch, "FORMATION PLANNED", false];
    };
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
        {_this call FUNC(doGroupFlank)},
        [_cycle - 1, _units, _vehicles, _pos, _overwatch],
        15 + random 5
    ] call CBA_fnc_waitAndExecute;
};

// end
true
