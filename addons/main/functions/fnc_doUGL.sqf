#include "script_component.hpp"
/*
 * Author: nkenny
 * Picks one unit from an array to shoot flare if available
 *
 * Arguments:
 * 0: Units  <ARRAY>, <GROUP> or <OJECT>
 *
 * Return Value:
 * available units
 *
 * Example:
 * [units bob] call lambs_main_fnc_doUGL;
 *
 * Public: Yes
*/

params [
    ["_units", objNull, [grpNull, objNull, []]],
    ["_pos", [0, 0, 0], [[]]],
    ["_type", "shotIlluminating", [""]]
];

// single unit
if (_units isEqualType objNull) then {_units = [_units];};
if (_units isEqualType grpNull) then {_units = units _units;};

// local
_units = _units select {local _x};

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
                private _flareSimulation = getText (configfile >> "CfgAmmo" >> _ammo >> "simulation");
                _flareSimulation isEqualTo _type
            };

            if (_index == -1) exitWith {false};
            _flare = _findFlares select _index;
        };
    };
    !(_flare isEqualTo "")
};

// execute
if (_unit == -1) exitWith {_units};
_unit = _units deleteAt _unit;

// force
doStop _unit;
_unit setUnitPosWeak "MIDDLE";
_unit setVariable [QGVAR(forceMove), true];

// variable
_unit setVariable [QGVAR(currentTask), "Shoot UGL", GVAR(debug_functions)];
_unit setVariable [QGVAR(currentTarget), objNull, GVAR(debug_functions)];
// dummy ~ seems necessary to get the AI to shoot up! -nkenny
private _flarePos = [_pos, (_unit getPos [80, getDir leader _unit]) vectorAdd [0, 0, 200]] select (_pos isEqualTo []);
private _dummy = "Target_F" createVehicle _flarePos;
_dummy setPos _flarePos;
_unit reveal _dummy;

// store - remove
_unit addMagazine (currentMagazine _unit);
_unit removeMagazine _flare;
_unit addWeaponItem [currentWeapon _unit, _flare];

// watch
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
] call CBA_fnc_waitAndExecute;

// end
_units
