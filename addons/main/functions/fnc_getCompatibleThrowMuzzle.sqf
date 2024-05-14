#include "script_component.hpp"
/*
 * Author: joko // Jonas
 * Finds a Compatible Throwing Muzzle for a given Throwing Weapon
 *
 * Arguments:
 * 0: Magazine <String>
 *
 * Return Value:
 * String: Muzzle Classname
 *
 * Example:
 * "SmokeShell" call lambs_main_fnc_getCompatibleThrowMuzzle;
 *
 * Public: Yes
*/
params [["_magazine", "", [""]]];

if (isNil QGVAR(cachedThrowingWeapons)) then {
    GVAR(cachedThrowingWeapons) = "true" configClasses (configFile >> "cfgWeapons" >> "throw");
    GVAR(cachedThrowingWeaponsHash) = createHashMap;
};

private _muzzle = GVAR(cachedThrowingWeaponsHash) get _magazine;
if (!isNil "_muzzle") exitWith {
    _muzzle;
};

private _muzzleIdx = GVAR(cachedThrowingWeapons) findIf {
    private _compatible = getArray (_x >> "magazines");
    _magazine in _compatible
};

if (_muzzleIdx == -1) then {
    _muzzle = "";
} else {
    _muzzle = configName (GVAR(cachedThrowingWeapons) select _muzzleIdx);
};

GVAR(cachedThrowingWeaponsHash) set [_magazine, _muzzle];

_muzzle
