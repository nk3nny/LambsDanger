#include "script_component.hpp"
/*
 * Author: joko // Jonas
 * Checks if a given ammo has a aiUsageFlagSet
 *
 * Arguments:
 * 0: Ammo  <String>
 * 1: Flags <Number>
 *
 * Return Value:
 * boolean
 *
 * Example:
 * "SmokeShell" call lambs_main_fnc_checkMagazineAiUsageFlags;
 *
 * Public: Yes
*/

if (isNil QGVAR(aiUsageFlagCache)) then {
    GVAR(aiUsageFlagCache) = createHashMap;
};

params [["_magazine", ""], ["_flags", 0]];

private _hasFlags = GVAR(aiUsageFlagCache) get _magazine;
if (!isNil "_hasFlags") exitWith {
    _hasFlags
};

// find smoke shell
private _ammo = getText (configfile >> "CfgMagazines" >> _magazine >> "Ammo");
private _aiAmmoUsage = getNumber (configfile >> "CfgAmmo" >> _ammo >> "aiAmmoUsageFlags");
_hasFlags = [_aiAmmoUsage, _type] call BIS_fnc_bitflagsCheck;

GVAR(aiUsageFlagCache) set [_magazine, _hasFlags];

_hasFlags;