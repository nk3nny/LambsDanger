#include "script_component.hpp"
/*
 * Author: nkenny
 * Checks if unit is allowed to play animations. Used in civilian danger.fsm
 *
 * Arguments:
 * 0: Unit fleeing <OBJECT>
 *
 * Return Value:
 * boolean
 *
 * Example:
 * bob call lambs_danger_fnc_fsmAllowAnimation;
 *
 * Public: No
*/
isNull objectParent _this
&& {count weapons _this < 1}
&& {_this checkAIFeature "PATH"}
&& {_this checkAIFeature "MOVE"}
