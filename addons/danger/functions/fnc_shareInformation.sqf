#include "script_component.hpp"
// Share information
// version 1.41
// by nkenny

/*
    Design
        Rank increases range information is shared

    Arguments
        0, unit in question         [Object]
        1, target being reported    [Object]
        2, default range             [Number] (default 350m)
        3, override range and rank?    [Boolean] (default false)
*/

// init
params ["_unit", ["_target", objNull], ["_range", 350], ["_override", false]];

// nil or captured
if (_unit distance _target > 3000) exitWith {false};
if ((_unit getVariable ["ace_captives_isHandcuffed", false]) || {_unit getVariable ["ace_captives_issurrendering", false]}) exitWith {false};

_unit setVariable [QGVAR(currentTarget), _target];
_unit setVariable [QGVAR(currentTask), "Share Information"];

// range
if (!_override) then {
    _range = switch (rank _unit) do {
        case ("SERGEANT"): {
            500
        };
        case ("LIEUTENANT"): {
            800
        };
        case ("CAPTAIN"): {
            1000
        };
        case ("MAJOR"): {
            2000
        };
        case ("COLONEL"): {
            3000
        };
        default {
            _range
        };
    };
};

// limit by viewdistance
_range = _range min viewDistance;

private _side = side _unit;
private _grp = group _unit;
// find units
private _groups = allGroups select {
    local _x
    && {(side _x) isEqualTo _side}
    && {((leader _x) distance2d _unit) < _range}
    && {_x != _grp}
    && {!((behaviour (leader _x)) isEqualTo "CARELESS")}
};

private _knowsAbout = _unit knowsAbout _target;
// share information
{
    if (!isNull _target) then {
        _x reveal [_target, _knowsAbout];
    };
    if (((leader _x) distance _unit) < (250 min _range)) then {
        _x setBehaviour "COMBAT";
        _x setFormDir ((leader _x) getDir _unit);
    };
    true
} count _groups;

[QGVAR(OnInformationShared), [_unit, group _unit, _target, _groups]] call FUNC(eventCallback);

// debug
if (GVAR(debug_functions)) then {systemchat format ["%1 share information (knows %2 to %3 groups at %4m range)", side _unit, _unit knowsAbout _target, count _groups, round _range];};

// end
true
