#include "script_component.hpp"
/*
 * Author: nkenny
 * Deploy static weapons
 *
 * Arguments:
 * 0: units <ARRAY>
 * 1: target or target position <ARRAY>, <OBJECT>
 * 2: position to deploy weapon <ARRAY>
 *
 * Return Value:
 * units in array
 *
 * Example:
 * [units bob, getPos angryJoe] call lambs_main_fnc_doGroupStaticDeploy;
 *
 * Public: No
*/
params ["_units", ["_target", []], ["_weaponPos", []]];

// sort units
switch (typeName _units) do {
    case ("OBJECT"): {
        _units = [_units] call FUNC(findReadyUnits);
    };
    case ("GROUP"): {
        _units = [leader _units] call FUNC(findReadyUnits);
    };
};

// prevent deployment of static weapons
if (_units isEqualTo []) exitWith { _units };

// find gunner
private _gunnerIndex = _units findIf { (unitBackpack _x) isKindOf "Weapon_Bag_Base" };
if (_gunnerIndex isEqualTo -1) exitWith { _units };

// define gunner
private _gunner = _units deleteAt _gunnerIndex;

//check for commando Mortar
if ("CommandoMortar" in (backpack _gunner)) exitWith {
    [_gunner, _weaponPos] call FUNC(doGroupCommandoDeploy);
    _units
};

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
    _units pushBack _gunner;
    _units
};
private _assistant = _units deleteAt _assistantIndex;

// check pos
if (_target isEqualType objNull) then {_target = _target call CBA_fnc_getPos;};
if (_target isEqualTo [] || {_target distance2D _gunner < 2}) then {
    _target = _gunner findNearestEnemy _gunner;
    if (isNull _target) then {_target = _gunner getPos [100, formationDirection (leader _gunner)];};
};

// Manoeuvre gunner
private _EH = _gunner addEventHandler ["WeaponAssembled", {
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

// callout
[formationLeader _gunner, "aware", "AssembleThatWeapon"] call FUNC(doCallout);

// find position
if (_weaponPos isEqualTo []) then {
    private _leaderPos = getPos (leader _gunner);
    _weaponPos = [_leaderPos, 0, 16, 3, 0, 0.07, 0, [], [_leaderPos, _leaderPos]] call BIS_fnc_findSafePos;
    _weaponPos set [2, 0];
};

// ready units
{
    doStop _x;
    _x doWatch _weaponPos;
    _x setUnitPos "MIDDLE";
    _x forceSpeed 24;
    _x setVariable [QEGVAR(danger,forceMove), true];
    _x setVariable [QGVAR(currentTask), "Deploy Static Weapon", GVAR(debug_functions)];
    _x setVariable [QGVAR(currentTarget), _weaponPos, GVAR(debug_functions)];
    _x doMove _weaponPos;
    _x setDestination [_weaponPos, "LEADER DIRECT", true];
} forEach [_gunner, _assistant];

// do it
[
    {
        // condition
        params ["_gunner", "_assistant", "", "_weaponPos"];
        _gunner distance2D _weaponPos < 2 || {_gunner distance2D _assistant < 3}
        // use of OR here to facilitate the sometimes irreverent A3 pathfinding ~ nkenny
    },
    {
        // on near gunner
        params ["_gunner", "_assistant", "_target"];
        if (
            !(_gunner call FUNC(isAlive))
            || {!(_assistant call FUNC(isAlive))}
            || {[_gunner] call FUNC(isIndoor)}
        ) exitWith {false};

        // assemble weapon
        doStop _gunner;
        _gunner action ["PutBag", _assistant];
        _gunner action ["Assemble", unitBackpack _assistant];

        // organise weapon and gunner
        [
            {
                params ["_gunner", "_target"];
                private _weapon = vehicle _gunner;
                _weapon setDir (_gunner getDir _target);
                _weapon setVectorUp ( surfaceNormal ( getPos _weapon ) );
                _weapon doWatch _target;

                // register
                private _group = group _gunner;
                private _weaponList = _group getVariable [QGVAR(staticWeaponList), []];
                _weaponList pushBackUnique _weapon;
                _group setVariable [QGVAR(staticWeaponList), _weaponList, true];

                // reset
                _gunner setVariable [QEGVAR(danger,forceMove), nil];
                _gunner setUnitPos "AUTO";
            }, [_gunner, _target], 1
        ] call CBA_fnc_waitAndExecute;

        // assistant
        doStop _assistant;
        _assistant doWatch _target;
        [_assistant, "gesturePoint"] call FUNC(doGesture);

        // reset fsm
        _assistant setVariable [QEGVAR(danger,forceMove), nil];
        _assistant setUnitPos "AUTO";

    },
    [_gunner, _assistant, _target, _weaponPos, _EH], 12,
    {
        // on timeout
        params ["_gunner", "_assistant", "", "", "_EH"];
        {
            [_x] doFollow (leader _x);
            _x setVariable [QEGVAR(danger,forceMove), nil];
            _x setUnitPos "AUTO";
        } forEach [_gunner, _assistant];
        _gunner removeEventHandler ["WeaponAssembled", _EH];
    }
] call CBA_fnc_waitUntilAndExecute;

// end
_units
