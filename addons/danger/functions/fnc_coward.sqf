#include "script_component.hpp"
// check to see if unit should be coward
// version 1.41
// by nkenny

// init
params ["_unit", "_target"];

// vehicles exit
if (!isNull objectParent _unit) exitWith {false};

// same side? stay
if (side _unit isEqualTo side _target) exitWith {false};

// no weapons? exit
if (count weapons _unit < 1) exitWith {true};

// Enemy vehicles?
private _enemyVehicle = _target isKindOf "Tank" || {_target isKindOf "Air"};
private _noLauncher = secondaryWeapon _unit isEqualTo "";

// tough vehicle and no launcher
if (_enemyVehicle && {_noLauncher}) exitWith {
    _unit setVariable [QGVAR(currentTarget), _target];
    _unit setVariable [QGVAR(currentTask), "Cowardice"];
    true
};

// else
false
