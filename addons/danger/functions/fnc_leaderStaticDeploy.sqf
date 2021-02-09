#include "script_component.hpp"
/*
 * Author: nkenny
 * Deploy static weapons
 *
 * Arguments:
 * 0: units <ARRAY>
 * 1: danger pos <ARRAY>
 * 2: oosition to deploy weapon <ARRAY>
 *
 * Return Value:
 * units in array
 *
 * Example:
 * [units bob, getPos angryJoe] call lambs_danger_fnc_leaderStaticDeploy;
 *
 * Public: No
*/
params ["_units", "_pos", ["_weaponPos", []]];

// sort units
switch (typeName _units) do {
    case ("OBJECT"): {
        _units = [_units] call EFUNC(main,findReadyUnits);
    };
    case ("GROUP"): {
        _units = [leader _units] call EFUNC(main,findReadyUnits);
    };
};

// prevent deployment of static weapons
if (_units isEqualTo []) exitWith { _units };

// find gunner
private _gunnerIndex = _units findIf { (unitBackpack _x) isKindOf "Weapon_Bag_Base" };
if (_gunnerIndex isEqualTo -1) exitWith { _units };

// define gunner
private _gunner = _units deleteAt _gunnerIndex;

// crudely and unapologetically lifted from BIS_fnc_unpackStaticWeapon by Rocket and Killzone_Kid
private _cfgBase = configFile >> "CfgVehicles" >> backpack _gunner >> "assembleInfo" >> "base";
private _compatibleBases = if (isText _cfgBase) then { [getText _cfgBase] } else { getArray _cfgBase };
if (_compatibleBases isEqualTo [""]) then {_compatibleBases = []};

// find assistant
private _assistantIndex = _units findIf {
    private _cfgBaseAssistant = configFile >> "CfgVehicles" >> backpack _x >> "assembleInfo" >> "base";
    private _compatibleBasesAssistant = if (isText _cfgBaseAssistant) then {[getText _cfgBaseAssistant]} else {getArray _cfgBaseAssistant};
    (backpack _x) in _compatibleBases || { (backpack _gunner) in _compatibleBasesAssistant}
};

// define assistant
if (_assistantIndex isEqualTo -1) exitWith {
    _units pushback _gunner;
    _units
};
private _assistant = _units deleteAt _assistantIndex;

// Manoeuvre gunner
private _EH = _gunner addEventHandler ["WeaponAssembled", {
    params ["_unit", "_weapon"];

    // get in weapon
    _unit assignAsGunner _weapon;
    _unit moveInGunner _weapon;

    // check artillery
    if (GVAR(Loaded_WP) && {_weapon getVariable [QEGVAR(wp,isArtillery), getNumber (configFile >> "CfgVehicles" >> (typeOf _weapon) >> "artilleryScanner") > 0]}) then {
        [group _unit] call EFUNC(wp,taskArtilleryRegister);
    };

    // remove EH
    _unit removeEventHandler ["WeaponAssembled", _thisEventHandler];
}];

// callout
[formationLeader _gunner, "aware", "AssembleThatWeapon"] call EFUNC(main,doCallout);

// find position ~ kept simple for now!
if (_weaponPos isEqualTo []) then {
    _weaponPos = [getPos _gunner, 0, 15, 2, 0, 0.19, 0, [], [getPos _assistant, getPos _assistant]] call BIS_fnc_findSafePos;
    _weaponPos set [2, 0];
};

// ready units
{
    doStop _x;
    _x setUnitPosWeak "MIDDLE";
    _x forceSpeed 24;
    _x setVariable [QGVAR(forceMove), true];
    _x setVariable [QEGVAR(main,currentTask), "Deploy Static Weapon", EGVAR(main,debug_functions)];
    _x setVariable [QEGVAR(main,currentTarget), _weaponPos, EGVAR(main,debug_functions)];
    _x doMove _weaponPos;
} foreach [_gunner, _assistant];

// do it
[
    {
        // condition
        params ["_gunner", "_assistant", "", "_weaponPos"];
        _gunner distance2D _weaponPos < 2 || {_gunner distance2D _assistant < 3}
        // use of OR here to facilitiate the sometimes irreverent A3 pathfinding ~ nkenny
    },
    {
        // on near gunner
        params ["_gunner", "_assistant", "_pos"];
        if (
            !(_gunner call EFUNC(main,isAlive))
            || {!(_assistant call EFUNC(main,isAlive))}
        ) exitWith {false};

        // assemble weapon
        _gunner action ["PutBag", _assistant];
        _gunner action ["Assemble", unitBackpack _assistant];

        // organise weapon and gunner
        [
            {
                params ["_gunner", "_pos"];
                private _weapon = vehicle _gunner;
                _weapon setDir (_gunner getDir _pos);
                _weapon setVectorUp surfaceNormal position _weapon;
                _weapon doWatch _pos;

                // register
                private _group = group _gunner;
                private _weaponList = _group getVariable [QGVAR(staticWeaponList), []];
                _weaponList pushBackUnique _weapon;
                _group setVariable [QGVAR(staticWeaponList), _weaponList, true];
            }, [_gunner, _pos], 1
        ] call CBA_fnc_waitAndExecute;

        // assistant
        doStop _assistant;
        _assistant doWatch _pos;
        [_assistant, "gesturePoint"] call EFUNC(main,doGesture);

        // reset fsm
        {
            _x setVariable [QGVAR(forceMove), nil];
        } foreach [_gunner, _assistant];
    },
    [_gunner, _assistant, _pos, _weaponPos, _EH], 8,
    {
        // on timeout
        params ["_gunner", "_assistant", "", "", "_EH"];
        {
            [_x] doFollow (leader _x);
            _x setVariable [QGVAR(forceMove), nil];
        } foreach [_gunner, _assistant];
        _gunner removeEventHandler ["WeaponAssembled", _EH];
    }
] call CBA_fnc_waitUntilAndExecute;

// end
_units
