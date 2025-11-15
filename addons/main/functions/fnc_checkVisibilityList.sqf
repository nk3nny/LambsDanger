#include "script_component.hpp"
/*
 * Author: nkenny
 * Find a location a unit can see from a list of position AGL
 *
 * Arguments:
 * 0: Unit doing looking <OBJECT>
 * 1: Array of possible locations in AGL <ARRAY>
 * 2: Max arrays <NUMBER>, default 4
 *
 * Return Value:
 * index
 *
 * Example:
 * [bob, []] call lambs_main_fnc_checkVisibilityList;
 *
 * Public: Yes
*/

params [["_unit", objNull], ["_posList", []], ["_max", 4]];
private _vehicle = vehicle _unit;
private _eyePos = eyePos _vehicle;
if (_unit distance2D (_posList select 0) > viewDistance) exitWith {-1};
private _checkList = _posList select [0, _max];

private _return = _checkList findIf {

    // get variables
    private _posASL = AGLToASL _x;
    //_posASL = _eyePos vectorAdd ((_posASL vectorDiff _eyePos) vectorMultiply 0.6); ~ uncommented until we may return to checkVisibility test ~ nk

    // check visibility
    !(terrainIntersectASL [_eyePos, _posASL])

};
_return
