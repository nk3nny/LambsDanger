#include "script_component.hpp"
/*
 * Author: diwako
 * Makes main gun of vehicle switch to HE ammo,
 * then switches back to regular ammo after 15 seconds
 *
 * Arguments:
 * 0: vehicle suppressing <OBJECT>
 *
 * Return Value:
 * success
 *
 * Example:
 * [vehicle bob] call lambs_main_fnc_doSelectHEMunition;
 *
 * Public: No
*/
params ["_vehicle"];
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
private _heMag = "";

{
    _turret = _x;
    private _muzzles = getArray (configFile >> "CfgWeapons" >> _turret >> "muzzles");

    // first pass, try to find the "HE" muzzle
    private _index = _muzzles findIf {_x == "HE"};
    if (_index > -1 && { // found muzzle named HE
        // one of the mags that can be loaded into that muzzle is in available mags
        ((getArray (configFile >> "CfgWeapons" >> _turret >> "he" >> "magazines")) arrayIntersect _availableMags) isNotEqualTo []
    }) then {
        _muzzle = _muzzles select _index;
        break;
    };

    // second pass no "HE" muzzle not found, see if any ammo loaded has its warheadName values set as "HE"
    _index = _muzzles findIf {
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
            if ((toUpper (getText (configFile >> "CfgAmmo" >> _ammo >> "warheadName"))) in ["HE", "HEAT"]) exitWith {
                _heMag = _x;
            };
        } forEach _magazines;
        _heMag isNotEqualTo ""
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
if ((currentMuzzle _gunner) isNotEqualTo _muzzle) then {
    if ((_vehicle getVariable [QGVAR(defaultGunnerMuzzle), ""]) isEqualTo "") then {
        _vehicle setVariable [QGVAR(defaultGunnerMuzzle), currentMuzzle _gunner, true];
    };
    [{
        params ["_gunner", "_muzzle"];
        _gunner selectWeapon _muzzle;
        systemChat format ["%1 switching back to muzzle %2", _gunner, _muzzle];
    }, [_gunner, _vehicle getVariable [QGVAR(defaultGunnerMuzzle), ""]], 15] call CBA_fnc_waitAndExecute;
    systemChat format ["%1 switching to muzzle %2 from %3", _gunner, _muzzle, _vehicle getVariable [QGVAR(defaultGunnerMuzzle), ""]];
    [{
        params ["_gunner", "_muzzle"];
        _gunner selectWeapon _muzzle;
    }, [_gunner, _muzzle]] call CBA_fnc_execNextFrame;
};
if (_heMag isNotEqualTo "") then {
    if ((_vehicle getVariable [QGVAR(defaultGunnerMagazine), ""]) isEqualTo "") then {
        private _oldMagClass = (weaponState [_vehicle, _turretPath, _muzzle]) select 3;
        _vehicle setVariable [QGVAR(defaultGunnerMagazine), _oldMagClass, true];
    };
    [{
        params ["_vehicle", "_turretPath", "_turret", "_oldMagClass"];
        _vehicle loadMagazine [_turretPath, _turret, _oldMagClass];
        systemChat format ["%1 loading %2 back into %3 ", gunner _vehicle, _oldMagClass, _turret];
    }, [_vehicle, _turretPath, _turret, _vehicle getVariable [QGVAR(defaultGunnerMagazine), ""]], 15] call CBA_fnc_waitAndExecute;

    _vehicle loadMagazine [_turretPath, _turret, _heMag];
    systemChat format ["%1 loading %2 into %3 ", _gunner, _heMag, _turret];
};

true
