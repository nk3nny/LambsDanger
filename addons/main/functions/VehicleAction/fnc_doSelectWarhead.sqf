#include "script_component.hpp"
/*
 * Author: diwako
 * Makes main gun of vehicle switch to given warhead type ammo
 * warhead types: AP TandemHEAT HEAT HE
 *
 * Arguments:
 * 0: vehicle suppressing <OBJECT>
 * 1: warhead types <ARRAY of upper case strings>
 * 2: switch muzzle <BOOLEAN>
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

private _gunner = gunner _vehicle;
if (isNull _gunner) exitWith {false};

private _assignedRoles = assignedVehicleRole _gunner;
// is either assigned nothing, driving or a cargo role without turret path
if ((count _assignedRoles) < 2) exitWith {false};

// figure out turret and ammo
private _turretPath = _assignedRoles select 1;
private _turretMagazines = _vehicle magazinesTurret _turretPath;
private _vehicleMagazines = magazines [_vehicle, false];
private _turrets = _vehicle weaponsTurret _turretPath;

if (isNil "_turrets") exitWith {false};

// kick out magazines that do not belong to the gunner turrets
private _availableMags = _turretMagazines arrayIntersect _vehicleMagazines;

private _turret = "";
private _muzzle = "";
private _foundMag = "";

if (_switchMuzzle) then {
    {
        _turret = _x;
        private _muzzles = getArray (configFile >> "CfgWeapons" >> _turret >> "muzzles");

        // first pass, try to find a muzzle that has the same name
        private _index = _muzzles findIf {(toUpperANSI _x) in _warheadTypes};
        if (_index > -1 && { // found muzzle with same name
            // one of the mags that can be loaded into that muzzle is in available mags
            ((getArray (configFile >> "CfgWeapons" >> _turret >> (_muzzles select _index) >> "magazines")) arrayIntersect _availableMags) isNotEqualTo []
        }) then {
            _muzzle = _muzzles select _index;
            break;
        };
    } forEach _turrets;
};

if (_muzzle isEqualTo "") then {
    {
        _turret = _x;
        private _muzzles = getArray (configFile >> "CfgWeapons" >> _turret >> "muzzles");
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
                if ((toUpperANSI (getText (configFile >> "CfgAmmo" >> _ammo >> "warheadName"))) in _warheadTypes && {
                    // do skip munition that needs a manual lase
                    !isClass (configFile >> "CfgAmmo" >> _ammo >> "Components" >> "SensorsManagerComponent" >> "Components" >> "LaserSensorComponent")
                }) then {
                    _foundMag = _x;
                    break;
                };
            } forEach _magazines;
            _foundMag isNotEqualTo ""
        };
        if (_index > -1) then {
            _muzzle = _muzzles select _index;
            break;
        };
    } forEach _turrets;
};

if (_muzzle == "this") then {
    _muzzle = _turret;
};

if (_turret isEqualTo "" || {_muzzle isEqualTo ""}) exitWith {false};

private _weaponState = weaponState [_vehicle, _turretPath, _muzzle];
// load mag type if exists and is not currently loaded
if (_foundMag isNotEqualTo "" && {_foundMag isNotEqualTo (_weaponState select 3)}) then {
    _vehicle loadMagazine [_turretPath, _turret, _foundMag];
    if (GVAR(debug_functions)) then {
        ["%1 loading magazine %2 into turret %3", typeOf _vehicle, _foundMag, _turret] call FUNC(debugLog);
    };
};

// switch to muzzle if currently not active
if (_switchMuzzle) then {
    private _modes = getArray (configFile >> "CfgWeapons" >> _turret >> "modes");
    private _topDownIndex = _modes findIf {(toUpperANSI _x) isEqualTo "TOPDOWN"};

    // if muzzle is the same as that it wants to switch to, and if there is a topdown fire mode and it is already selected, skip
    if !((currentMuzzle _gunner) isNotEqualTo _muzzle || {
        _topDownIndex > -1 && {(_modes select _topDownIndex) isNotEqualTo (_weaponState select 2)}}) exitWith {};
    if (_topDownIndex > -1) then {
        // if weapon has a topdown mode, use it
        // works sadly unreliable, the AI likes to switch firemode right before firing
        _gunner selectWeapon [_turret, _muzzle, _modes select _topDownIndex];
        if (GVAR(debug_functions)) then {
            ["%1 switching to muzzle %2 with mode %4 in %3", _gunner, _muzzle, typeOf _vehicle, _modes select _topDownIndex] call FUNC(debugLog);
        };
    } else {
        _gunner selectWeapon _muzzle;
        if (GVAR(debug_functions)) then {
            ["%1 switching to muzzle %2 in %3", _gunner, _muzzle, typeOf _vehicle] call FUNC(debugLog);
        };
    }
};

true
