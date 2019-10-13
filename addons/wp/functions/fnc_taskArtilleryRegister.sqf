#include "script_component.hpp"
// register units as ready artillery pieces
// version 1.0
// by nkenny

// init
params ["_group"];
private _artillery = [];

// sort grp
if (!local _group) exitWith {};
if (_group isEqualType objNull) then { _group = (group _group); };

// find all vehicles
{
    if !(isNull objectParent _x) then { _artillery pushBackUnique (vehicle _x); };
    true
} count (units _group);

// identify artillery
private _artillery = _artillery select { getNumber (configFile >> "CfgVehicles" >> (typeOf _x) >> "artilleryScanner") > 0 };
if (_artillery isEqualTo []) exitWith {false};

// add to faction global
private _global = missionNamespace getVariable ["lambs_artillery_" + str (side _group), []];
{ _global pushBackUnique _x; true } count _artillery;
missionNamespace setVariable ["lambs_artillery_" + str (side _group), _global, false];

// debug
if (EGVAR(danger,debug_functions)) then {
    systemchat format ["%1 Registered Artillery: %2 registered %3 guns", side _group, groupID _group, count _artillery];
};

// end
true
