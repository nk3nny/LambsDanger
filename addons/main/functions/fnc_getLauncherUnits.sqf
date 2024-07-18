#include "script_component.hpp"
/*
 * Author: ThomasAngel
 * Gets all units from a group that have launchers.
 * Things like AP launchers, flares etc will not count, -
 * launcher must be capable of destroying at least some vehicle.
 *
 * Checking through the submunitions might improve mod compatibility,
 * but only if the AI actually accounts for submunitions when evaluating -
 * whether to engage or not. As of writing, this is unknown.
 *
 * Disposable launchers get mostly ignored, AI doesn't seem to even use them.
 *
 * Arguments:
 * 0: Group to search in <GROUP, ARRAY<OBJECT>>
 * 1: Flags to check Against <NUMBER>
 * 2: Check through submunitions <BOOLEAN>
 *
 * Return Value:
 * Array - units with launchers
 *
 * Example:
 * [group bob] call lambs_main_fnc_getLauncherUnits;
 *
 * Public: Yes
*/

params [
    ["_group", [], [grpNull, []]],
    ["_flags", AI_AMMO_USAGE_FLAG_VEHICLE + AI_AMMO_USAGE_FLAG_AIR + AI_AMMO_USAGE_FLAG_ARMOUR, [0]],
    ["_checkSubmunition", false, [false]]
];

if (_group isEqualType grpNull) then {
    _group = units _group;
};
private _suitableUnits = [];
{
    if ((secondaryWeapon _x) isEqualTo "") then {continue};
    private _currentUnit = _x;

    private _unitsMagazines = (magazines _currentUnit) + (secondaryWeaponMagazine _currentUnit);
    {
        if ([_x, _flags] call FUNC(checkMagazineAiUsageFlags)) exitWith {
            _suitableUnits pushBackUnique _currentUnit
        };

        // Optionally go through submunitions. More info in header.
        if !(_checkSubmunition) then {continue}; // Invert & continue to reduce indentation

        private _mainAmmo = getText (configFile >> "cfgMagazines" >> _x >> "ammo");
        private _submunition = getText (configFile >> "cfgAmmo" >> _mainAmmo >> "submunitionAmmo");
        if (_submunition isEqualTo "") then {continue};
        private _submunitionFlags = getNumber(configFile >> "cfgAmmo" >> _submunition >> "aiAmmoUsageFlags");

        if ([_submunitionFlags, _flags] call BIS_fnc_bitflagsCheck) exitWith {_suitableUnits pushBackUnique _currentUnit};
    } forEachReversed _unitsMagazines;
    // We iterate back to front for performance, because _unitsMagazines is structured -
    // as follows: uniform magazines -> vest magazines -> backpack magazines, and -
    // launcher ammo is usually in the backpack. This is a ~3-4x speedup.
} forEach _group;

_suitableUnits
