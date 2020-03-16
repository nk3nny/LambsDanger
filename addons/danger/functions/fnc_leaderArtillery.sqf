#include "script_component.hpp"
/*
 * Author: nkenny
 * Unit calls friendly artillery if available
 *
 * Arguments:
 * 0: Unit calling artillery <OBJECT>
 * 1: Target of artillery, unit <OBJECT> or position <ARRAY>
 *
 * Return Value:
 * success
 *
 * Example:
 * [bob, angryJoe] call lambs_danger_fnc_leaderArtillery;
 *
 * Public: No
*/
params ["_unit", "_target", ["_pos", []]];

if (_pos isEqualTo []) then {
    _pos = _target call cba_fnc_getPos;
};

// check if mod active
if (!GVAR(Loaded_WP)) exitWith {if (GVAR(debug_functions)) then {format ["%1 Artillery failed -- mod not enabled", side _unit] call FUNC(debugLog);}};

// settings
private _artillery = [EGVAR(main,SideArtilleryHash), side _unit] call CBA_fnc_hashGet;
_artillery = _artillery select {
    canFire _x
    && {unitReady _x}
    && {_pos inRangeOfArtillery [[_x], getArtilleryAmmo [_x] select 0]};
};

// exit on no ready artillery
if (_artillery isEqualTo []) exitWith {if (GVAR(debug_functions)) then {format ["%1 Artillery failed -- no available artillery in rage of Target", side _unit] call FUNC(debugLog);}};

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
doStop _unit;
[_unit, ["HandSignalRadio"]] call FUNC(gesture);

// perform it
[_gun, _pos, _unit] spawn EFUNC(WP,taskArtillery);

// end
true
