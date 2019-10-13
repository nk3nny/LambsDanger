#include "script_component.hpp"
// Call friendly artillery
// version 1.01
// by nkenny

/*

    Calls friendly artillery on target location!

    Arguments
        0, unit doing the calling     [Object]
        1, target of artillery         [Object or Array]

    Other
        Thanks Alex2k for doing the basic grunt work
        Thanks to AnAngrySalad for refinement of idea

*/

// init
params ["_unit", "_target", ["_pos", []]];

if (_pos isEqualTo []) then {
    _pos = _target call cba_fnc_getPos;
};

// check if mod active
if (!GVAR(Loaded_WP)) exitWith {if (GVAR(debug_functions)) then {systemchat format ["%1 Artillery failed -- mod not enabled", side _unit]}};

// sort target
if (_unit distance _pos < 100) exitWith {if (GVAR(debug_functions)) then {systemchat format ["%1 Artillery failed -- target too close", side _unit]}};

// settings
private _artillery = missionNamespace getVariable ["lambs_artillery_" + str (side _unit), []];
_artillery select {
    canFire _x
    && {unitReady _x}
    && {_pos inRangeOfArtillery [[_x], getArtilleryAmmo [_x] select 0]};
};

// exit on no ready artillery
if (_artillery isEqualTo []) exitWith {if (GVAR(debug_functions)) then {systemchat format ["%1 Artillery failed -- no available artillery", side _unit]}};

_unit setVariable [QGVAR(currentTarget), _target];
_unit setVariable [QGVAR(currentTask), "Leader Artillery"];

// pick closest artillery
_artillery = [_artillery, [], { _target distance _x }, "ASCEND"] call BIS_fnc_sortBy;

private _gun = _artillery select 0;
[QGVAR(OnArtilleryCalled), [_unit, group _unit, _gun, _pos]] call FUNC(eventCallback);

// find caller
private _unit = ([_unit, nil, false] call FUNC(shareInformationRange)) select 0;
_unit setVariable [QGVAR(currentTask), "Call Artillery"];

// Gesture
if (stance _unit != "PRONE") then {
    [_unit, ["MountOptic"]] call FUNC(gesture);
};

// perform it
[_gun, _pos, _unit] spawn EFUNC(WP,taskArtillery);

// end
true
