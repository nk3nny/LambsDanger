#include "script_component.hpp"
/*
 * Author: nkenny
 * Deploy commando mortar introduced in Reaction Forced CDLC
 *
 * Arguments:
 * 0: unit carrying mortar <OBJECT>
 * 1: position to deploy weapon <ARRAY>
 *
 * Return Value:
 * bool
 *
 * Example:
 * [unit, getPos angryJoe] call lambs_main_fnc_doGroupCommandoDeploy;
 *
 * Public: No
*/

params ["_unit", ["_weaponPos", []]];

// alive and update pos
if !(_unit call EFUNC(main,isAlive)) exitWith {false};

// add eventhandler
private _EH = _unit addEventHandler ["WeaponAssembled", {
    params ["_unit", "_weapon"];

    // get in weapon
    _unit assignAsGunner _weapon;
    _unit moveInGunner _weapon;

    // check artillery
    if (GVAR(Loaded_WP) && {_weapon getVariable [QGVAR(isArtillery), getNumber (configOf _weapon >> "artilleryScanner") > 0]}) then {
        [group _unit] call EFUNC(wp,taskArtilleryRegister);
    };

    // remove EH
    _unit removeEventHandler ["WeaponAssembled", _thisEventHandler];
}];

// find position
if (_weaponPos isEqualTo []) then {
    private _unitPos = getPos _unit;
    _weaponPos = [_unitPos, 0, 7, 3, 0, 0.07, 0, [], [_unitPos, _unitPos]] call BIS_fnc_findSafePos;
    _weaponPos set [2, 0];
};

// ready unit
doStop _unit;
_unit doWatch _weaponPos;
_unit setUnitPos "MIDDLE";
_unit forceSpeed 24;
_unit setVariable [QEGVAR(danger,forceMove), true];
_unit setVariable [QGVAR(currentTask), "Deploy Commando Mortar", GVAR(debug_functions)];
_unit setVariable [QGVAR(currentTarget), _weaponPos, GVAR(debug_functions)];
_unit doMove _weaponPos;
_unit setDestination [_weaponPos, "LEADER DIRECT", true];

// do it
[
    {
        // condition
        params ["_gunner", "_weaponPos"];
        (_gunner call FUNC(isAlive)) && { _gunner distance2D _weaponPos < 1.2 || { unitReady _gunner } }
    },
    {
        // on near gunner
        params ["_gunner"];

        // assemble weapon
        private _weaponHolder = createVehicle ["GroundWeaponHolder_Scripted", getPos _gunner, [], 0, "NONE"];
        _gunner action ["Assemble", _weaponHolder];

        // organise weapon and gunner
        [
            {
                params ["_gunner"];
                private _weapon = vehicle _gunner;
                _weapon setVectorUp ( surfaceNormal ( getPos _weapon ) );

                // register
                private _group = group _gunner;
                private _weaponList = _group getVariable [QGVAR(staticWeaponList), []];
                _weaponList pushBackUnique _weapon;
                _group setVariable [QGVAR(staticWeaponList), _weaponList, true];

                // reset
                _gunner setVariable [QEGVAR(danger,forceMove), nil];
                _gunner setUnitPos "AUTO";
            }, [_gunner], 1
        ] call CBA_fnc_waitAndExecute;
    },
    [_unit, _weaponPos, _EH], 9,
    {
        // on timeout
        params ["_gunner", "", "_EH"];
        [_gunner] doFollow (leader _gunner);
        _gunner setVariable [QEGVAR(danger,forceMove), nil];
        _gunner setUnitPos "AUTO";
        _gunner removeEventHandler ["WeaponAssembled", _EH];
    }
] call CBA_fnc_waitUntilAndExecute;

// end
true
