#include "script_component.hpp"
/*
 * Author: nkenny
 * Creates a map marker at location
 *
 * Arguments:
 * 0: Position to place dot, either as position <ARRAY>, unit <OBJECT> or group <GROUP>
 * 1: Text to display at location, default is none <STRING>
 * 2: Color of marker, default is black <STRING>
 * 3: Type of dot, default is military dot, <STRING>
 *
 * Return Value:
 * marker
 *
 * Example:
 * [bob, "Here is bob","colorRED","mil_dot"] call lambs_main_fnc_dotMarker;
 *
 * Public: Yes
*/
params ["_pos", ["_text", ""], ["_color", "colorBlack"], ["_type", "mil_dot"]];
_pos = _pos call CBA_fnc_getPos;

// create
private _m = createMarkerLocal [format["mdot_%1%2%3", (floor(_pos select 0)), (floor(_pos select 1)), count allmapMarkers], _pos];
_m setMarkerShapeLocal "Icon";
_m setMarkerColorLocal _color;
_m setMarkerTypeLocal _type;
_m setMarkerTextLocal _text;

// Return marker!
_m
