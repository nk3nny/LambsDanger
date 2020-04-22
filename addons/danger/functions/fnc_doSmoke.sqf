#include "script_component.hpp"
/*
 * Author: nkenny
 * Unit finds and throws smoke grenade at location
 *
 * Arguments:
 * 0: Unit  <OBJECT>
 * 1: Position <ARRAY>, optional
 * 2: Type, corresponds to ai usage flags <string> optional
 *
 * Return Value:
 * boolean
 *
 * Example:
 * [bob, getpos angryJoe] call lambs_danger_fnc_doSmoke;
 *
 * Public: No
*/

params ["_unit", ["_pos", []], ["_type", "4 + 2"]];

// no autnomous smoke throwing  <--- TODO nkenny (also do check elsewhere to preserve usefullness of this function)
if (false) exitWith {false};

// get magazines
private _magazines = magazinesAmmo _unit;
_magazines = _magazines select {(_x select 1) isEqualTo 1};
_magazines = _magazines apply {_x select 0};
if (_magazines isEqualTo []) exitWith {false};

// find smoke shell
private _smokeshell = _magazines findIf {
    private _ammo = getText (configfile >> "CfgMagazines" >> _x >> "Ammo");
    private _aiAmmoUsage = getText (configfile >> "CfgAmmo" >> _ammo >> "aiAmmoUsageFlags");
    _aiAmmoUsage isEqualTo _type
};

// select smoke
if (_smokeshell == -1) exitWith {false};
_smokeshell = (_magazines select _smokeshell);

// get muzzle -- This is where Joko could do some fancy caching ~ nkenny
private _muzzleList = "true" configClasses (configFile >> "cfgWeapons" >> "throw");

private _muzzle = _muzzleList findIf {

    private _compatible = getArray (configFile >> "cfgWeapons" >> "throw" >> configName _x >> "magazines");
    _smokeshell in _compatible
};

// select muzzle
if (_muzzle == -1) exitWith {false};
_muzzle = configName (_muzzleList select _muzzle);

// turn towards target 
if !(_pos isEqualTo []) then {
    _unit doWatch _pos
    _unit setVariable [QGVAR(currentTarget), _pos];
};

// variable
_unit setVariable [QGVAR(currentTask), "Throwing smoke grenade"];

// execute
[
    {
        _this call bis_fnc_fire;
    }, [_unit, _muzzle], 1
] call cba_fnc_waitAndExecute;

// end
true