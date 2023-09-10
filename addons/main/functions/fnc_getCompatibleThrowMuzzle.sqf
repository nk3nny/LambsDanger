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

private _muzzleList = GVAR(cachedThrowingWeapons);

private _muzzleIdx = _muzzleList findIf {
    private _compatible = GVAR(cachedThrowingWeaponsHash) get configName _x;
    if (isNil "_compatible") then {
        _compatible = getArray (_x >> "magazines");
        GVAR(cachedThrowingWeaponsHash) set [configName _x, _compatible];
    };
    _magazine in _compatible
};

if (_muzzleIdx == -1) exitWith {
    ""
};

_muzzleList select _muzzleIdx