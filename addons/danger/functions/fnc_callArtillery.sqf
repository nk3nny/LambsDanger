#include "script_component.hpp"
// Call friendly artillery
// version 1.0
// by nkenny

/*

    Calls friendly artillery on target location!

    Arguments
        0, unit doing the calling     [Object]
        1, target of artillery         [Object or Object]

    Other
        Thanks Alex2k for doing the basic grunt work

*/

// init
private _unit = param [0];
private _target = param [1];

// check if mod active
if (!GVAR(WP)) exitWith {if (GVAR(debug_functions)) then {systemchat format ["Danger.fnc Artillery mode not enabled", ""]}};

// sort target
private _pos = _target call bis_fnc_position;
if (_unit distance _pos < 100) exitWith {if (GVAR(debug_functions)) then {systemchat format ["Danger.fnc %1 Artillery failed -- target too close", side _unit]}};

_unit setVariable [QGVAR(currentTarget), _target];
_unit setVariable [QGVAR(currentTask), "Call Artillery"];

// settings
private _artillery = missionNamespace getVariable ["lambs_artillery_" + str (side _unit), []];
_artillery select {
    canFire _x && {unitReady _x} && {_pos inRangeOfArtillery [[_x], getArtilleryAmmo [_x] select 0]};
};

// exit on no ready artillery
if (count _artillery < 1) exitWith {if (GVAR(debug_functions)) then {systemchat format ["Danger.fnc %1 Artillery failed -- no available artillery", side _unit]}};

private _gun = selectRandom _artillery;

// perform it
[_gun, _pos] spawn FUNC(taskArtillery);

// end
true
