#include "script_component.hpp"
/*
 * Author: nkenny
 * Checks if the unit is a ready leader at FSM level
 *
 * Arguments:
 * 0: unit being tested <OBJECT>
 *
 * Return Value:
 * bool
 *
 * Example:
 * [bob] call lambs_danger_fnc_isLeader;
 *
 * Public: No
*/
params ["_unit"];
getSuppression _unit < 0.2
&& {!(group _unit getVariable [QGVAR(isExecutingTactic), false])}
&& {(leader _unit) isEqualTo _unit || {RND(0.9) && {isFormationLeader _unit || {!((leader _unit) call EFUNC(main,isAlive))}}}}
