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
 * Public: Yes
*/

// init
params [["_group", grpNull, [grpNull, objNull]]];

if (canSuspend) exitWith { [FUNC(taskArtilleryRegister), _this] call CBA_fnc_directCall; };
// sort grp
if (_group isEqualType objNull) then { _group = (group _group); };

private _artillery = [];

// find all vehicles
{
    if !(isNull objectParent _x) then { _artillery pushBackUnique (vehicle _x); };
    true
} count (units _group);

// identify artillery
private _artillery = _artillery select { getNumber (configOf _x >> "artilleryScanner") > 0 };
if (_artillery isEqualTo []) exitWith {false};

// check for MLRS
{
    private _assignedRoles = assignedVehicleRole (gunner _x);

    // gunner doesn't have a proper turret!
    if ((count _assignedRoles) < 2) then {
        _x setVariable [QEGVAR(main,isArtilleryMRLS), false];
    } else {
        // get the callout for what this vehicle shoots!
        private _turretPath = _assignedRoles select 1;
        private _turret = (_x weaponsTurret _turretPath) select 0;
        private _nameSound = getText (configFile >> "CfgWeapons" >> _turret >> "nameSound");
        if (_nameSound isEqualTo "rockets") then {
            _x setVariable [QEGVAR(main,isArtilleryMRLS), true];
        } else {
            _x setVariable [QEGVAR(main,isArtilleryMRLS), false];
        };
    };
} forEach _artillery;

// add to faction global
[QGVAR(RegisterArtillery), _artillery] call CBA_fnc_serverEvent;

// debug
if (EGVAR(main,debug_functions)) then {
    ["%1 Registered Artillery: %2 registered %3 guns", side _group, groupID _group, count _artillery] call EFUNC(main,debugLog);
};

// end
true
