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
params ["_unit",["_target",ObjNull],["_range",350],["_override",false]];

// nil or captured
if (_unit distance _target > 3000) exitWith {false};
if ((_unit getVariable ["ace_captives_isHandcuffed",false]) || {_unit getVariable ["ace_captives_issurrendering",false]}) exitWith {false};

_unit setVariable [QGVAR(currentTarget), _target];
_unit setVariable [QGVAR(currentTask), "Share Information"];

// range
_range = [rank _unit,_range,_override] call {
    params ["_rank","_range"];
    if (_override) exitWith {_range};  // to allow for custom short range updates
    if (_rank isEqualTo "SERGEANT") exitWith {500};
    if (_rank isEqualTo "LIEUTENANT") exitWith {800};
    if (_rank isEqualTo "CAPTAIN") exitWith {1000};
    if (_rank isEqualTo "MAJOR") exitWith {2000};
    if (_rank isEqualTo "COLONEL") exitWith {3000};
    _range
};

// limit by viewdistance
_range = _range min viewDistance;

// find units
private _grp = allGroups select {local _x && {side _x isEqualTo side _unit} && {leader _x distance2d _unit < _range} && {_x != group _unit} && {!(behaviour leader _x isEqualTo "CARELESS")}};

// share information
{
    if (!isNull _target) then {_x reveal [_target,_unit knowsAbout _target];};
    if (leader _x distance _unit < (250 min _range)) then {_x setBehaviour "COMBAT";_x setFormDir ((leader _x) getDir _unit);};
    true
} count _grp;

// debug
if (GVAR(debug_functions)) then {systemchat format ["%1 share information (knows %2 to %3 groups at %4m range)",side _unit,_unit knowsAbout _target,count _grp,round _range];};

// end
true
