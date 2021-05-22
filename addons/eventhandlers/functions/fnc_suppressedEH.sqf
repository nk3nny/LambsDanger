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
params ["_unit"];
if (
    morale _unit > 0
    || {getSuppression _unit < 0.97}
    || {!local _unit}
    || {!isNull objectParent _unit}
    || {_unit getVariable [QEGVAR(danger,forceMove), false]}
    || {_this getVariable [QEGVAR(danger,disableAI), false]}
    || {RND(GVAR(panicChance))}
    || {isPlayer _unit || {isPlayer (leader _unit)}}
) exitWith {false};

// doPanic
_unit call EFUNC(main,doPanic);

// debug informaiton to be removed before release -- nkenny
systemchat "PANIC INITATED!";
[_unit, format ["PANIC - %2 | %1", getSuppression _unit, morale _unit]] call lambs_main_fnc_dotMarker;
// debug information!!!

// end
true
