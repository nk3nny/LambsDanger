#include "script_component.hpp"
// register units as ready artillery pieces
// version 1.0
// by nkenny

// init
params ["_grp"];

// sort grp
if (!local _grp) exitWith {};
_grp = [_grp] call {if (typeName _grp == "OBJECT") exitWith {group _grp};_grp};

// find all vehicles
{
    if !(isNull objectParent _x) then { _artillery pushBackUnique (vehicle _x)};
    true
} count units _grp;

// identify artillery
_artillery = _artillery select { getNumber (configFile >> "CfgVehicles" >> (typeOf _x) >> "artilleryScanner") > 0 };
if (count _artillery < 1) exitWith {false};

// add to faction global
private _global = missionNamespace getVariable ["lambs_artillery_" + str (side _grp), []];
{ _global pushBackUnique _x; true } count _artillery;
missionNamespace setVariable ["lambs_artillery_" + str (side _grp), _global, false];

// debug
if (EGVAR(danger,debug_functions)) then {
    systemchat format ["danger.wp Registered Artillery: %1 registered %2 guns for %3", groupID _grp, count _artillery, side _grp];
};

// end
true
