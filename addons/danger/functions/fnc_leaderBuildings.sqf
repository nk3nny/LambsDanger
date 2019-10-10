#include "script_component.hpp"
// Leader Declares CQC buildings
// version 1.41
//by nkenny

// init
params ["_unit", "_target", ["_buildings", []]];

if (_buildings isEqualTo []) then {
    _buildings = [_unit getPos [random 100, _unit getDir _target], 35, true, false] call FUNC(findBuildings);
};

_unit setVariable [QGVAR(currentTarget), _target];
_unit setVariable [QGVAR(currentTask), "Leader Buildings"];

// gesture
[_unit, ["gestureGo", "gestureGoB"]] call FUNC(gesture);

// units
private _units = units group _unit;
_units = _units select {isNull objectParent _x};

// no more spots than units
if (count _units > count _buildings) then {_units resize (count _buildings);};

// orders
{

    // stance
    _x setUnitPosWeak selectRandom ["UP", "UP", "MIDDLE"];

    // speed
    _x forceSpeed 2;

    // move
    _x doMove (_buildings select _forEachIndex);

} forEach _units;

// end
true
