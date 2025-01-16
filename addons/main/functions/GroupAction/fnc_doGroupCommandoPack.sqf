#include "script_component.hpp"
/*
 * Author: nkenny
 * Pack commando mortar introduced in Reaction Forced CDLC
 *
 * Arguments:
 * 0: weapon to pack <OBJECT>
 *
 * Return Value:
 * bool
 *
 * Example:
 * [units bob, getPos angryJoe] call lambs_main_fnc_doGroupCommandoPack;
 *
 * Public: No
*/

params ["_gun"];

private _gunner = gunner _gun;

// callout
[leader _gunner, "aware", "DisassembleThatWeapon"] call FUNC(doCallout);

_gunner addEventHandler ["WeaponDisassembled", {
        params ["_gunner", "_weaponBag"];

        // get bags
        _gunner action ["TakeBag", _weaponBag];

        // remove EH
        _gunner removeEventHandler ["WeaponDisassembled", _thisEventHandler];
    }
];

// get mortar
private _vehicle = vehicle _gunner;

// disassemble
moveOut _gunner;
(group _gunner) leaveVehicle (assignedVehicle _gunner);
unassignVehicle _gunner;

// do action
_gunner action ["Disassemble", _vehicle];

// end
true
