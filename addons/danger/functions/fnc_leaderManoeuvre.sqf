#include "script_component.hpp"
// Leader calls for aggresive manoeuvres
// version 1.41
//by nkenny

// init
params ["_unit", "_target", ["_units", []],["_cycle",4]];

// find units
if (_units isEqualTo []) then {
    _units = units _unit;
};

_unit setVariable [QGVAR(currentTarget), _target];
_unit setVariable [QGVAR(currentTask), "Leader Manoeuvre"];

// sort building locations
private _pos = ([_target, 12, true, false] call FUNC(findBuildings));
_pos pushBack (_target call cba_fnc_getPos);

// gesture
[_unit, ["gestureGo"]] call FUNC(gesture);
[selectRandom _units, ["gestureGoB"]] call FUNC(gesture);

// ready group
{_x doFollow leader _x} foreach _units;
group _unit setFormDir (_unit getDir (_pos select 0));

// manoeuvre function
private _fnc_manoeuvre = {
    params ["_cycle", "_units", "_pos", "_fnc_manoeuvre"];

    // select
    private _target = selectRandom _pos;

    // update
    _units = _units select {alive _x && {_x distance _target > GVAR(CQB_range)}};
    _cycle = _cycle - 1;

    {
        // pos
        _x doWatch _target;

        // Half suppress -- Half manoeuvre
        if (random 1 > 0.6) then {
            [_x, _target] call FUNC(Suppress);
            _x suppressFor 12;
        } else {
            // manoeuvre
            _x setUnitPosWeak selectRandom ["UP", "MIDDLE"];
            _x forceSpeed 25;
            _x doMove _target;
            _x setVariable [QGVAR(currentTask), "Manoeuvre"];
        };
    } foreach _units;

    // recursive cyclic
    if (_cycle > 0 && {count _units > 0}) then {
        [
            _fnc_manoeuvre,
            [_cycle, _units, _pos, _fnc_manoeuvre],
            12 + random 4
        ] call cba_fnc_waitAndExecute;
    };
};

// execute recursive cycle
[_cycle, _units, _pos, _fnc_manoeuvre] call _fnc_manoeuvre;

// end
true
