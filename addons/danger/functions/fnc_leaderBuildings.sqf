#include "script_component.hpp"
// Leader Declares CQC buildings
// version 1.41
//by nkenny

// init
params ["_unit", "_target", ["_units", []],["_cycle",3]];

// find units
if (_units isEqualTo []) then {
    _units = units _unit;
};

_unit setVariable [QGVAR(currentTarget), _target];
_unit setVariable [QGVAR(currentTask), "Leader Buildings"];

// gesture
[_unit, ["gestureGo", "gestureGoB"]] call FUNC(gesture);

// sort building locations
private _pos = ([_target, 12, true, false] call FUNC(findBuildings)); 
_pos pushBack (_target call cba_fnc_getPos);

// gesture
[_unit, ["gestureAdvance"]] call lambs_danger_fnc_gesture;
[selectRandom _units, ["gestureGoB"]] call lambs_danger_fnc_gesture;

// ready units -- half suppress -- half cover
_fnc_manoeuvre = {
    params ["_cycle","_units","_pos","_fnc_manoeuvre","_target"];

    // select
    _target = selectRandom _pos;

    // update
    _units = _units select {alive _x && _x distance _target > 50};
    _cycle = _cycle - 1;

    {
        // pos
        _x doWatch _target;

        // Half suppress -- Half manoeuvre
        if (random 1 > 0.6) then {
            [_x, _target] call FUNC(Suppress);
            _x suppressFor 12; 

        // manoeuvre
        } else {
            _x setUnitPosWeak "MIDDLE";
            _x forceSpeed 25;
            _x doMove _target;
        };
    } foreach _units;

    // recursive cyclic
    if (_cycle > 0 && {count _units > 0}) then {
        [
            _fnc_manoeuvre,
            [_cycle,_units,_pos,_fnc_manoeuvre],
            12
        ] call cba_fnc_waitAndExecute;
    };
};

// execute recursive cycle
[_cycle,_units,_pos,_fnc_manoeuvre] call _fnc_manoeuvre;

// end
true
