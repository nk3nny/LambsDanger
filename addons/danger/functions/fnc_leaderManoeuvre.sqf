#include "script_component.hpp"
// Leader calls for aggresive manoeuvres
// version 1.41
//by nkenny

// init
params ["_unit", "_target", ["_units", []]];

// find units
if (_units isEqualTo []) then {
    _units = units group _unit;
};

_unit setVariable [QGVAR(currentTarget), _target];
_unit setVariable [QGVAR(currentTask), "Leader Manoeuvre"];

// find overwatch positions
private _pos = [_target, _unit distance _target, 100 min (_unit distance _target), 25, getPosATL _unit] call FUNC(findOverwatch);

// gesture
[_unit, ["gestureAdvance"]] call FUNC(gesture);
[selectRandom _units, ["gestureGoB"]] call FUNC(gesture);

// ready units -- half suppress -- half cover
{
    // Half suppress -- Half manoeuvre
    if (random 1 > 0.6) then {

        [_x, _target] call FUNC(suppress);

    // manoeuvre
    } else {

        doStop _x;
        _x forceSpeed 25;
        _x doMove (_pos getPos [10 + random 20, random 360]);
        if !(stance _x isEqualTo "PRONE") then {
            private _anim = selectRandom [
                "AmovPercMrunSrasWrflDfl_AmovPercMrunSrasWrflDf",
                "AmovPercMrunSrasWrflDfl_AmovPercMrunSrasWrflDfr",
                "AmovPercMrunSrasWrflDfr_AmovPercMrunSrasWrflDf",
                "AmovPercMrunSrasWrflDfr_AmovPercMrunSrasWrflDfl"
            ];
            _x switchMove _anim;
        };
    };

    // end
    true

} count (_units select {_x distance2d _unit < 300});

// end
true
