#include "script_component.hpp"
/*
 * Author: nkenny
 * Checks if unit is allowed to play animations. Used in civilian danger.fsm
 *
 * Arguments:
 * 0: unit fleeing <OBJECT>
 *
 * Return Value:
 * boolean
 *
 * Example:
 * bob call lambs_danger_fnc_fsmAllowAnimation;
 *
 * Public: No
*/
!(EGVAR(main,disableAIGestures))
&& {isNull objectParent _this}
&& {weapons _this isEqualTo []}
&& {_this checkAIFeature "PATH"}
&& {_this checkAIFeature "MOVE"}
&& {!(((expectedDestination _this) select 1) isEqualTo "DoNotPlan")}
&& {!isForcedWalk _this}
&& {!(surfaceIsWater getPosASL _this)}
