#include "script_component.hpp"
/*
 * Author: nkenny
 * Checks if a Unit is Alive and Awake
 *
 * Arguments:
 * 0: Unit being checked <OBJECT>
 *
 * Return Value:
 * boolean
 *
 * Example:
 * bob call lambs_danger_fnc_isAlive;
 *
 * Public: No
*/
alive _this
|| {!(_this getVariable ["ACE_isUnconscious", false])}
|| {!((lifeState _this) in ["DEAD", "INCAPACITATED"])}
