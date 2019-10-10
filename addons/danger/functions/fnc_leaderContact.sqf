#include "script_component.hpp"
// Leader Declares Contact!
// version 1.5
//by nkenny

// init
params ["_unit", "_target"];

// share information 
[_unit,_target] call lambs_danger_fnc_shareInformation;

// change formation 
(group _unit) setFormation (group _unit getVariable [QGVAR(dangerFormation),formation _unit]);

// call event system
["lambs_danger_onContact", [_unit, group _unit, units _unit]] call lambs_danger_fnc_eventCallback;

// end
true

