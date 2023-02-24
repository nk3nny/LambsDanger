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
_units = _units select { _x call FUNC(isAlive) && { !isPlayer _x } };
_vehicles = _vehicles select { canFire _x };

private _posASL = AGLtoASL (selectRandom _pos);

{
    private _suppressed = (getSuppression _x) > 0.5;
    _x setUnitPos (["MIDDLE", "DOWN"] select _suppressed);

    // move
    _x doMove (_overwatch vectorAdd [-2 + random 4, -2 + random 4, 0]);
    _x setDestination [_overwatch, "LEADER PLANNED", true];
    _x setVariable [QEGVAR(danger,forceMove), !_suppressed];

    // suppress
    if (
        RND(0.7)
        && {(leader _x) isNotEqualTo _x}
        && {!(terrainIntersectASL [eyePos _x, _posASL vectorAdd [0, 0, 3]])}
    ) then {
        [{_this call FUNC(doSuppress)}, [_x, _posASL vectorAdd [0, 0, random 1], true], random 3] call CBA_fnc_waitAndExecute;
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
        10 + random 8
    ] call CBA_fnc_waitAndExecute;
};

// end
true
