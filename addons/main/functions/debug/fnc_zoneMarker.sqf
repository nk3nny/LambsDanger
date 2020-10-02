#include "script_component.hpp"
/*
 * Author: nkenny
 * Creates a zone map marker at location
 *
 * Arguments:
 * 0: Position to place dot, either as position <ARRAY>, unit <OBJECT> or group <GROUP>
 * 1: Size of marker expressed as an array of two numbers, default [100,100], <ARRAY>
 * 2: Color of marker, default is black <STRING>
 * 3: brush type of marker, default Diagonal lines <STRING>
 * 4: Rectangle, default false <BOOLEAN>
 *
 * Return Value:
 * marker
 *
 * Example:
 * [bob, [200,200],"colorBLUE","Cross",false] call lambs_main_fnc_zoneMarker;
 *
 * Public: Yes
*/

/*
  BRUSH LISTS:
    "Solid"
    "SolidFull"
    "Horizontal"
    "Vertical"
    "Grid"
    "FDiagonal" (Default)
    "BDiagonal"
    "DiagGrid"
    "Cross"
    "Border"
    "SolidBorder"
*/
params ["_pos", ["_size", [100, 100]], ["_color", "colorEAST"], ["_brush", "FDiagonal"], ["_shape", false]];
_pos = _pos call CBA_fnc_getPos;

// create
private _m = createMarkerLocal [format["mzone_%1%2%3", (floor(_pos select 0)), (floor(_pos select 1)), count allmapMarkers], _pos];
_m setMarkerShapeLocal "ELLIPSE";
_m setMarkerColorLocal _color;
_m setMarkerBrushLocal _brush;
_m setMarkerSizeLocal _size;

// optional Rectangle
if (_shape) then {_m setMarkerShape "RECTANGLE";};

// Return marker!
_m
