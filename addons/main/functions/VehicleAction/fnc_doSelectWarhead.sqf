#include "script_component.hpp"
/*
 * Author: diwako
 * Makes main gun of vehicle switch to given warhead type ammo
 * warhead types: AP TandemHEAT HEAT HE
 *
 * Arguments:
 * 0: vehicle suppressing <OBJECT>
 * 1: warhead types <ARRAY of upper case strings>
 * 3: switch muzzle <BOOLEAN>
 *
 * Return Value:
 * success
 *
 * Example:
 * [vehicle bob, ["HE"]] call lambs_main_fnc_doSelectWarhead;
 *
 * Public: No
*/
params ["_vehicle", ["_warheadTypes", ["HE", "HEAT"]], ["_switchMuzzle", false]];

if !(GVAR(autonomousMunitionSwitching)) exitWith {false};
private _gunner = gunner _vehicle;
if (isNull _gunner) exitWith {false};

// figure out turret and ammo
private _turretPath = (assignedVehicleRole _gunner) select 1;
private _turretMagazines = _vehicle magazinesTurret _turretPath;
private _vehicleMagazines = magazines [_vehicle, false];
private _turrets = _vehicle weaponsTurret _turretPath;

// kick out magazines that do not belong to the gunner turrets
private _availableMags = _turretMagazines arrayIntersect _vehicleMagazines;

private _turret = "";
private _muzzle = "";
private _foundMag = "";

{
    _turret = _x;
    private _muzzles = getArray (configFile >> "CfgWeapons" >> _turret >> "muzzles");

    // first pass, try to find a muzzle that has the same name
    if (_switchMuzzle) then {
        private _index = _muzzles findIf {(toUpper _x) in _warheadTypes};
        if (_index > -1 && { // found muzzle with same name
            // one of the mags that can be loaded into that muzzle is in available mags
            ((getArray (configFile >> "CfgWeapons" >> _turret >> (_muzzles select _index) >> "magazines")) arrayIntersect _availableMags) isNotEqualTo []
        }) then {
            _muzzle = _muzzles select _index;
            break;
        };
    };

    // second pass no named muzzle found, see if any ammo loaded has its warheadName values set as a value in _warheadTypes
    private _index = _muzzles findIf {
        private _magazines = if (_x == "this") then {
            _availableMags arrayIntersect getArray ((configFile >> "CfgWeapons" >> _turret >> "magazines"))
        } else {
            _availableMags arrayIntersect getArray ((configFile >> "CfgWeapons" >> _turret >> _x >> "magazines"))
        };
        reverse _magazines; // reverse as vanilla arma sorts munition as such: ap, heat, he, other
                            // heat is also regarded as "HE", we want the actual HE munition first
        {
            private _ammo = getText (configFile >> "CfgMagazines" >> _x >> "ammo");
            if (_ammo isEqualTo "") then {continue};
            if ((toUpper (getText (configFile >> "CfgAmmo" >> _ammo >> "warheadName"))) in _warheadTypes) exitWith {
                _foundMag = _x;
            };
        } forEach _magazines;
        _foundMag isNotEqualTo ""
    };
    if (_index > -1) then {
        _muzzle = _muzzles select _index;
        break;
    };
} forEach _turrets;

if (_muzzle == "this") then {
    _muzzle = _turret;
};

if (_turret isEqualTo "" || {_muzzle isEqualTo ""}) exitWith {false};

// load mag type if exists and is not currently loaded
if (_foundMag isNotEqualTo "" && {_foundMag isNotEqualTo ((weaponState [_vehicle, _turretPath, _muzzle]) select 3)}) then {
    _vehicle loadMagazine [_turretPath, _turret, _foundMag];
};

// switch to muzzle if currently not active
if (_switchMuzzle && {(currentMuzzle _gunner) isNotEqualTo _muzzle}) then {
    _gunner selectWeapon _muzzle;
};

true
