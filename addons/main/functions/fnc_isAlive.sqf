#include "script_component.hpp"
/*
 * Author: jokoho482
 * Checks if a Unit is Alive and Awake
 *
 * Arguments:
 * 0: Unit being checked <OBJECT>
 *
 * Return Value:
 * boolean
 *
 * Example:
 * bob call lambs_main_fnc_isAlive;
 *
 * Public: No
*/
alive _this
&& {!(_this getVariable ["ACE_isUnconscious", false])}
&& {!((lifeState _this) in ["DEAD", "INCAPACITATED"])}
