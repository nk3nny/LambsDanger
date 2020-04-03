#include "script_component.hpp"
/*
 * Author: nkenny
 * Register units as ready artillery pieces
 *
 * Arguments:
 * 0: Group to check either unit <OBJECT> or group <GROUP>
 *
 * Return Value:
 * none
 *
 * Example:
 * [group bob] call lambs_wp_fnc_taskArtilleryRegister;
 *
 * Public: No
*/

// init
params ["_group"];
private _artillery = [];

if (canSuspend) exitWith { [FUNC(taskArtilleryRegister), _this] call CBA_fnc_directCall; };
// sort grp
if (!local _group) exitWith {false};
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
[QGVAR(RegisterArillery), _artillery] call CBA_fnc_serverEvent;

// debug
if (EGVAR(danger,debug_functions)) then {
    format ["%1 Registered Artillery: %2 registered %3 guns", side _group, groupID _group, count _artillery] call EFUNC(danger,debugLog);
};

// end
true
