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
if (_unit distance _target > viewDistance) exitWith {false};
if ((_unit getVariable ["ace_captives_isHandcuffed", false]) || {_unit getVariable ["ace_captives_issurrendering", false]}) exitWith {false};

_unit setVariable [QGVAR(currentTarget), _target];
_unit setVariable [QGVAR(currentTask), "Share Information"];

// range
private _radio = [_unit,_range,_override] call FUNC(shareInformationRange);
_unit = _radio select 0;
_range = _radio select 1;
_radio = _radio select 2;   // has backpack radio -nk

// find units
private _groups = allGroups select {
    local _x
    && {side _x isEqualTo side _unit}
    && {leader _x distance2d _unit < _range}
    && {behaviour leader _x != "CARELESS"}
    && {_x != group _unit}
};

private _knowsAbout = _unit knowsAbout _target;
// share information
{
    if (!isNull _target) then {
        _x reveal [_target, _knowsAbout];
    };
    
    if (leader _x distance _unit < (250 min _range)) then {
        _x setBehaviour "COMBAT";
        _x setFormDir ((leader _x) getDir _unit);
    };
} foreach _groups;

[QGVAR(OnInformationShared), [_unit, group _unit, _target, _groups]] call FUNC(eventCallback);

// debug
if (GVAR(debug_functions)) then {systemchat format ["%1 share information (knows %2 to %3 groups at %4m range)", side _unit, _unit knowsAbout _target, count _groups, round _range];};

// end
true
