#include "script_component.hpp"
/*
 * Author: nkenny
 * check to see if unit should be coward based on own and enemy situation
 *
 * Arguments:
 * 0: Unit assault cover <OBJECT>
 * 1: Enemy <OBJECT>
 *
 * Return Value:
 * boolean
 *
 * Example:
 * [bob, angryJoe] call lambs_danger_fnc_isCoward;
 *
 * Public: No
*/
params ["_unit", "_target"];

// vehicles are never coward
if (!isNull objectParent _unit) exitWith {false};

// units of same side do not trigger
if (side _unit isEqualTo side _target) exitWith {false};

// units moving or otherwise enable are not cowards
if (
    stopped _unit
    || {!(_unit checkAIFeature "PATH")}
    || {!(_unit checkAIFeature "MOVE")}
    || {isPlayer (leader _unit)}
    || {currentCommand _unit in ["GET IN", "ACTION", "HEAL", "ATTACK"]}
    || {GVAR(disableAIHideFromTanksAndAircraft)}
) exitWith {false};

// Units without weapons are always cowards
if ((weapons _unit) isEqualTo []) exitWith {true};

// Sort enemy tanks and air assets and own launcher
private _enemyVehicle = _target isKindOf "Tank" || {_target isKindOf "Air"};
private _noLauncher = secondaryWeapon _unit isEqualTo "";

// tough vehicle and no launcher? hide
if (_enemyVehicle && {_noLauncher}) exitWith {
    _unit setVariable [QGVAR(currentTarget), _target, EGVAR(main,debug_functions)];
    _unit setVariable [QGVAR(currentTask), "Cowardice", EGVAR(main,debug_functions)];
    true
};

// else
false
