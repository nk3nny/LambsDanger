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
    _pos = _target call CBA_fnc_getPos;
};

// check if mod active
if (!GVAR(Loaded_WP)) exitWith {if (GVAR(debug_functions)) then {format ["%1 Artillery failed -- mod not enabled", side _unit] call FUNC(debugLog);}};

// settings

// exit on no ready artillery
if !([side _unit, _pos] call EFUNC(WP,sideHasArtillery)) exitWith {if (GVAR(debug_functions)) then {format ["%1 Artillery failed -- no available artillery in range of Target", side _unit] call FUNC(debugLog);}};

_unit setVariable [QGVAR(currentTarget), _target];
_unit setVariable [QGVAR(currentTask), "Leader Artillery"];

// find caller
private _unit = ([_unit, nil, false] call FUNC(shareInformationRange)) select 0;
_unit setVariable [QGVAR(currentTask), "Call Artillery"];

// Gesture
doStop _unit;
[_unit, ["HandSignalRadio"]] call FUNC(gesture);

// callout
[_unit, "aware", "SupportRequestRGArty", 75] call FUNC(doCallout);

// perform it
[side _unit, _pos, _unit] spawn EFUNC(WP,taskArtillery);

// end
true
