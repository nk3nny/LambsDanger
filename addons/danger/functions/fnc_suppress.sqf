#include "script_component.hpp"
// Suppression
// version 1.4
// by nkenny

// init
params ["_unit","_pos"];

// no primary weapons exit?
if (primaryWeapon _unit isEqualTo "") exitWith {false};

_unit setVariable [QGVAR(currentTarget), _pos];
_unit setVariable [QGVAR(currentTask), "Suppress"];

// do it!
_unit doSuppressiveFire ((AGLToASL _pos) vectorAdd [0,0,0.2 + random 1.2]);

// extend suppressive fire for machineguns
if (_unit ammo (currentWeapon _unit) > 32) then {
    _unit suppressFor (2 + random 7);
};

// debug
if (GVAR(debug_functions)) then {systemchat format ["%1 Suppression (%2 @ %3m)",side _unit,name _unit,round (_unit distance _pos)];};

// end
true
