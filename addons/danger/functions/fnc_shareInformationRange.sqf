#include "script_component.hpp"
// Share information Range
// version 1.43
// by nkenny

/*
    Design
        Returns an array with Unit doing the call and a radio range.

    Returns
        Unit doing the call
        Radio range
        Has backpack radio
*/

// init
params ["_unit",["_range",1000],["_override",false],["_radio",false]];

// override
if (_override) exitWith {[_unit,_range,_radio]};

// get range by faction
_range = switch (side _unit) do {
    case WEST: {GVAR(radio_WEST)};
    case EAST: {GVAR(radio_EAST)};
    default {GVAR(radio_GUER)};
};

// tweak by VD
_range = _range min viewDistance;

// Sort long range radios
_radio = false;
{
    // in vehicle (and close), has backpack, or TFAR radio
    // or lambs_danger_fnc_dangerRadio is set to true
    _hasRadio = (
        _x getVariable [QGVAR(dangerRadio),false]
        || {(!isNull objectParent _x && {_x distance2d _unit < 70})}
        || {(toLower backpack _x) find "b_radiobag_01_" isEqualTo 0}
        || {isNumber (configFile >> "CfgVehicles" >> (backpack _x) >> "tf_range")}
    );

    // exit on radio
    if (_hasRadio) exitWith {
        _unit = _x;
        _range = _range + GVAR(radio_backpack);
        _radio = true;
    };
} foreach (units _unit select {alive _x && {_x distance2d _unit < 150}});

// tweak by height above sea-level
_range = _range + (linearConversion [ -200, 600, (getposASL _unit) select 2, -400, 2000, true ] );

// return unit and range
[_unit,_range,_radio]
