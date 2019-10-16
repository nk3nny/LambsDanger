#include "script_component.hpp"
/*
 * Author: nkenny
 * Determines range which information is shared
 *
 * Arguments:
 * 0: Unit sharing information <OBJECT>
 *
 * Return Value:
 * Array containing, unit doing the call, radio range, and presence of backpack radio
 *
 * Example:
 * [bob] call lambs_danger_fnc_shareInformationRange;
 *
 * Public: Yes
*/
params ["_unit", ["_range",1000], ["_override",false], ["_radio",false]];

// override
if (_override) exitWith { [_unit, _range, _radio] };

// get range by faction
_range = switch (side _unit) do {
    case WEST: { GVAR(radio_WEST) };
    case EAST: { GVAR(radio_EAST) };
    default { GVAR(radio_GUER) };
};

// tweak by VD
_range = _range min viewDistance;

// Sort long range radios
private _target = _unit;

private _units = (units _unit select {alive _x && {_x distance2d _unit < 150}});
private _index = _units findIf {
        _x getVariable [QGVAR(dangerRadio), false]
        || {(!isNull objectParent _x && {_x distance2d _unit < 70})}
        || {(toLower backpack _x) find "b_radiobag_01_" isEqualTo 0}
        || {isNumber (configFile >> "CfgVehicles" >> (backpack _x) >> "tf_range")}
};
_radio = _index != -1;
if (_radio) then {
    _target = _unit select _index;
    _range = _range + GVAR(radio_Backpack);
};
// tweak by height above sea-level
_range = _range + (linearConversion [-200, 600, (getposASL _unit) select 2, -400, 2000, true]);

// return unit and range
[_target, _range, _radio]
