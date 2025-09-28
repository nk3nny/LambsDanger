#include "script_component.hpp"
/*
 * Author: nkenny
 * Find a location a unit can see from a list of position AGL
 *
 * Arguments:
 * 0: Unit doing looking <OBJECT>
 * 1: Array of possible locations in AGL <ARRAY>
 *
 * Return Value:
 * index
 *
 * Example:
 * [bob, []] call lambs_main_fnc_checkVisibilityList;
 *
 * Public: Yes
*/

params [["_unit", objNull], ["_posList", []]];

private _eyePos = eyePos (vehicle _unit);
private _return = _posList findIf {

    // get variables
    private _posASL = AGLToASL _x;
    _posASL = _eyePos vectorAdd ((_posASL vectorDiff _eyePos) vectorMultiply 0.6);

    // check visibility
    [vehicle _unit, "VIEW", objNull] checkVisibility [_eyePos, _posASL] isEqualTo 1
};
_return
