#include "script_component.hpp"
// Zone marker
// version 1.0
// nkenny

/*
Create a marker Zone
Arguments
  0, position    [Array or Object]
  1, size        [Array]
  2, colour      [String]
  3, brush type: [String]
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
  4, rectangle -- [Boolean] (Default false)
*/

// init
params ["_pos", ["_size", [100, 100]], ["_color", "colorEAST"], ["_brush", "FDiagonal"], ["_shape", false]];
_pos = _pos call CBA_fnc_getPos;

// create
private _m = createMarker [format["mzone_%1%2%3", (floor(_pos select 0)), (floor(_pos select 1)), count allmapMarkers], _pos];
_m setMarkerShape "ELLIPSE";
_m setmarkerColor _color;
_m setMarkerBrush _brush;
_m setMarkerSize _size;

// optional Rectangle
if (_shape) then {_m setMarkerShape "RECTANGLE";};

// Return marker!
_m
