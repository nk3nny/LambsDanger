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
 * [bob, angryJoe] call lambs_danger_fnc_coward;
 *
 * Public: No
*/
params ["_unit", "_target"];

// units moving or otherwise enable are not cowards
if (
    !isNull objectParent _unit // vehicles are never coward
    || {side _unit isEqualTo side _target} // units of same side do not trigger
    || {stopped _unit}
    || {!(_unit checkAIFeature "PATH")}
    || {!(_unit checkAIFeature "MOVE")}
    || {isPlayer (leader _unit)}
    || {isPlayer _unit}
    || {currentCommand _unit in ["GET IN", "ACTION", "HEAL", "ATTACK"]}
) exitWith {false};

// Units without weapons are always cowards
if ((weapons _unit) isEqualTo []) exitWith {true};

// Sort enemy tanks and air assets and own launcher
private _enemyVehicle = _target isKindOf "Tank" || {_target isKindOf "Air"};
private _noLauncher = secondaryWeapon _unit isEqualTo "";

// tough vehicle and no launcher? hide
if (_enemyVehicle && {_noLauncher}) exitWith {
    _unit setVariable [QGVAR(currentTarget), _target];
    _unit setVariable [QGVAR(currentTask), "Cowardice"];
    true
};

// else
false
