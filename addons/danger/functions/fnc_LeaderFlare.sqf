#include "script_component.hpp"
/*
 * Author: nkenny
 * Picks one unit from an array to shoot flare if available
 *
 * Arguments:
 * 0: Units  <ARRAY>
 *
 * Return Value:
 * available units
 *
 * Example:
 * [units bob] call lambs_danger_fnc_doFlare;
 *
 * Public: No
*/

params ["_units"];

// find grenade launcher
private _flare = "";
private _muzzle = "";
private _unit = _units findIf {

    private _weapon = primaryWeapon _x;

    if !(_weapon isEqualTo "") then {

        _muzzle = (getArray (configfile >> "CfgWeapons" >> _weapon >> "muzzles") - ["SAFE", "this"]) param [0, ""];

        // find flares
        if !(_muzzle isEqualTo "") then {
            private _findFlares = getArray (configfile >> "CfgWeapons" >> _weapon >> _muzzle >> "magazines");
            _findFlares = _findFlares arrayIntersect (magazines _x);
            if (_findFlares isEqualTo []) exitWith {false};

            // sort flares
            private _index = _findFlares findIf {
                private _ammo = getText (configfile >> "CfgMagazines" >> _x >> "Ammo");
                private _flareSize = getNumber (configfile >> "CfgAmmo" >> _ammo >> "flareSize");
                _flareSize != 0
            };
            
            if (_index == -1) exitWith {false};
            _flare = _findFlares select _index;
        };
    };
    !(_flare isEqualTo "")
};

// execute
if (_unit == -1) exitWith {_units};
_unit = _units select _unit;

// debug
systemchat format ["%1 grenadier %2 has %3", side _unit, name _unit, _flare];

// force
doStop _unit;
_unit setUnitPosWeak "MIDDLE";
_unit setVariable [QGVAR(ForceMove), true];

// variable
_unit setVariable [QGVAR(currentTask), "Shoot flare"];

// dummy ~ seems necessary to get the AI to shoot up! -nkenny
_dummy = "Sign_Sphere10cm_F" createvehicle (getpos _unit);
_dummy setpos ((_unit getPos [50, getDir formationLeader _unit]) vectorAdd [0, 0, 200]);
_unit reveal _dummy;

// store - remove
_unit addMagazine (currentMagazine _unit);
_unit removeMagazine _flare;
_unit addWeaponItem [currentWeapon _unit, _flare];

// watch
//_unit doWatch ((_unit getPos [50, formationDirection _unit]) vectorAdd [0, 0, 125]);
_unit doTarget _dummy;

// force fire
[
    {
        params ["_unit", "_muzzle", "_dummy"];

        // select & fire
        _unit selectWeapon _muzzle;
        _unit forceWeaponFire [_muzzle, weaponState _unit select 2];

        // clean
        _unit doWatch objNull;
        _unit doFollow (leader _unit);
        deleteVehicle _dummy;

    }, [_unit, _muzzle, _dummy], 2
] call cba_fnc_waitAndExecute;

// end
_units - [_unit]