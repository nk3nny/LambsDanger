#include "script_component.hpp"
/*
 * Author: nkenny
 * Pack static weapon
 *
 * Arguments:
 * 0: Units <ARRAY>, <OBJECT>, <GROUP>
 * 1: Range check <NUMBER>
 * 2: Weapon to pack <ARRAY>
 *
 * Return Value:
 * units in array
 *
 * Example:
 * [units bob] call lambs_danger_fnc_leaderStaticPack;
 *
 * Public: No
*/

params ["_units", ["_guns", []]];

// sort units
switch (typeName _units) do {
    case ("OBJECT"): {
        _units = [_units] call EFUNC(main,findReadyUnits);
    };
    case ("GROUP"): {
        _units = [leader _units] call EFUNC(main,findReadyUnits);
    };
};

// get weapons list
if (_guns isEqualTo []) then {
    _guns = (group (_units select 0)) getVariable [QGVAR(staticWeaponList), []];
};

// check if weapon is unmanned
_guns = _guns select {!(crew _x isEqualTo [])};
if (_guns isEqualTo []) exitWith { _units };

// get gunner
private _weapon = _guns deleteAt 0;
private _gunner = gunner _weapon;

// check for nearest unit without backpack
_units = _units select { isNull objectParent _x && { (backpack _x) isEqualTo ""} };

// get nearest assistant ~ should probably write a function for this! - nkenny
if (_units isEqualTo []) exitWith { _units };
_units = _units apply { [ _x distance2D _gunner, _x ] };
_units sort true;
_units = _units apply { _x select 1 };

// get assistant
private _assistant = _units deleteAt 0;

// eventhandler ~ inspired by BIS_fnc_unpackStaticWeapon by Rocket and Killzone_Kid
_gunner setVariable [QGVAR(staticWeaponAssistant), _assistant];
private _EH = _gunner addEventHandler ["WeaponDisassembled", {
        params ["_gunner", "_weaponBag", "_baseBag"];

        // get assistant
        private _assistant = _gunner getVariable QGVAR(staticWeaponAssistant);

        // get bags
        _gunner action ["TakeBag", _weaponBag];
        _assistant action ["TakeBag", _baseBag];

        // remove EH
        _gunner removeEventHandler ["WeaponDisassembled", _thisEventHandler];
    }
];

// callout
[formationLeader _assistant, "aware", "DisassembleThatWeapon"] call EFUNC(main,doCallout);

// assistant moves to gunner
doStop _assistant;
_assistant doWatch vehicle _gunner;
_assistant setUnitPosWeak "MIDDLE";
_assistant forceSpeed 24;
_assistant setVariable [QGVAR(forceMove), true];
_assistant setVariable [QGVAR(currentTask), "Pack Static Weapon", EGVAR(main,debug_functions)];
_assistant setVariable [QGVAR(currentTarget), getPos _gunner, EGVAR(main,debug_functions)];
_assistant doMove getposATL (vehicle _gunner);

// do it
[
    {
        // condition
        params ["_gunner", "_assistant", "_pos"];
        (_assistant distance2D _pos < 5 || {unitReady _assistant}) || {fleeing _gunner} || {fleeing _assistant}
    },
    {
        // on success
        params ["_gunner", "_assistant", "", "_EH"];

        if (fleeing _gunner || {fleeing _assistant} || {!(_assistant call EFUNC(main,isAlive))}) exitWith {false};

        // gunner leaves weapon triple threat
        private _weapon = vehicle _gunner;
        moveOut _gunner;
        (group _gunner) leaveVehicle assignedVehicle _gunner;
        unassignVehicle _gunner;

        // dissassemble weapon
        _gunner action ["Disassemble", _weapon];

        // de-register
        private _weaponList = group _gunner getVariable [QGVAR(staticWeaponList), []];
        _weaponList = _weaponList - [_weapon];
        group _gunner setVariable [QGVAR(staticWeaponList), _weaponList, true];

    },
    [_gunner, _assistant, getposATL _weapon, _EH], 8,
    {
        // on timeout
        params ["_gunner", "_assistant", "", "_EH"];

        // assistant reverts
        _assistant doFollow (leader _assistant);

        // removes eventhandler
        _gunner removeEventHandler ["WeaponDisassembled", _EH];

    }
] call CBA_fnc_waitUntilAndExecute;

// end
_units
