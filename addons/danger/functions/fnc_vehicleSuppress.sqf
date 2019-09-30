#include "script_component.hpp"
// Suppression Vehicle
// version 1.41
// by nkenny

/*
    Vehicle suppression
*/

// init
params ["_unit","_pos"];

// too close + high speed
if (_unit distance2d _pos < GVAR(minSuppression_range)) exitWith {false};
if (speed (vehicle _unit) > 12) exitWith {false};

// artillery (no tactical options)
if (vehicle _unit getVariable ["isArtillery",getNumber (configFile >> "CfgVehicles" >> (typeOf (vehicle _unit)) >> "artilleryScanner") > 0]) exitWith {
    vehicle _unit setVariable ["isArtillery",true];
    false
};

// do it
vehicle _unit doSuppressiveFire ((AGLtoASL _pos) vectorAdd [0.5 - random 1,0.5 - random 1,0.3 + random 1.3]);

// debug
if (GVAR(debug_functions)) then {systemchat format ["%1 suppression (%2 @ %3m)",side _unit,getText (configFile >> "CfgVehicles" >> (typeOf vehicle _unit) >> "displayName"),round (_unit distance _pos)];};

// end
true
