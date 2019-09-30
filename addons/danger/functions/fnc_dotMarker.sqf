#include "script_component.hpp"
// Dot marker
// pilfered from somewhere, tweaked, rewritten, tweaked again.
// nkenny

/*
Arguments
    0 position    [Array or Object]
    1 text        [String] (Default "none")
    2 colour      [String] (Default Black)
    3 type        [String] (Default military dot)
*/

// init
params ["_pos",["_text",""],["_color","colorBlack"],["_type","mil_dot"]];
_pos = _pos call bis_fnc_position;

// create
_m = createMarkerLocal [format["mdot_%1%2%3",(floor(_pos select 0)),(floor(_pos select 1)),count allmapMarkers],_pos];
_m setMarkerShapeLocal "Icon";
_m setMarkerColorLocal _color;
_m setMarkerTypeLocal _type;
_m setMarkerTextLocal _text;

// Return marker!
_m
