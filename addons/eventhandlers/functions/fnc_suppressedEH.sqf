#include "script_component.hpp"
/*
 * Author: nkenny
 * Suppression eventhandler that may trigger panic
 *
 * Arguments:
 * 0: Unit  <OBJECT>
 *
 * Return Value:
 * boolean
 *
 * Example:
 * [bob] call lambs_eventhandlers_fnc_suppressionEH;
 *
 * Public: No
*/

// init
params ["_unit", "", "_shooter"];
if (
    !local _unit
    || {morale _unit > 0}
    || {getSuppression _unit < 0.97}
    || {!isNull objectParent _unit}
    || {_unit getVariable [QEGVAR(danger,forceMove), false]}
    || {_unit getVariable [QEGVAR(danger,disableAI), false]}
    || {RND(GVAR(panicChance))}
    || {_unit distanceSqr _shooter < 1225}  // ~ exit if shooter is within 35m
    || {isPlayer _unit || {isPlayer (leader _unit)}}
) exitWith {false};

// doPanic
_unit call EFUNC(main,doPanic);

// end
true
