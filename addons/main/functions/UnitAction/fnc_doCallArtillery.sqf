#include "script_component.hpp"
/*
 * Author: nkenny
 * Unit calls friendly artillery if available
 *
 * Arguments:
 * 0: unit calling artillery <OBJECT>
 * 1: target of artillery, unit <OBJECT> or position <ARRAY>
 * 2: position of artillery target <ARRAY>
 *
 * Return Value:
 * success
 *
 * Example:
 * [bob, angryJoe] call lambs_main_fnc_doCallArtillery;
 *
 * Public: No
*/
params ["_unit", "_target", ["_pos", []]];

if (_pos isEqualTo []) then {
    _pos = _target call CBA_fnc_getPos;
};

// check if mod active
if (!GVAR(Loaded_WP)) exitWith {if (GVAR(debug_functions)) then {["%1 Artillery failed -- mod not enabled", side _unit] call FUNC(debugLog);}};

// settings

// exit on no ready artillery
if !([side _unit, _pos] call EFUNC(WP,sideHasArtillery)) exitWith {
    if (GVAR(debug_functions)) then {
        ["%1 Artillery failed -- no available artillery in range of target", side _unit] call FUNC(debugLog);
    };
};

_unit setVariable [QGVAR(currentTarget), _target, GVAR(debug_functions)];
_unit setVariable [QGVAR(currentTask), "Leader Artillery", GVAR(debug_functions)];

// find caller
_unit = ([_unit, nil, false] call FUNC(getShareInformationParams)) select 0;

// movement
_unit forceSpeed 0;
_unit setUnitPosWeak selectRandom ["DOWN", "MIDDLE"];
_unit setVariable [QEGVAR(danger,forceMove), true];
_unit doWatch _pos;

// reset forceMove
[{
    _this setVariable [QEGVAR(danger,forceMove), nil];
    _this forceSpeed -1;
    _this doFollow (leader _this);
}, _unit, 20] call CBA_fnc_waitAndExecute;

// Gesture
doStop _unit;
[_unit, "HandSignalRadio"] call FUNC(doGesture);

// binoculars if appropriate!
if (!(binocular _unit isEqualTo "")) then {
    _unit selectWeapon (binocular _unit);
};

// callout
[_unit, "aware", "SupportRequestRGArty", 75] call FUNC(doCallout);

// perform it
[side _unit, _pos, _unit] call EFUNC(WP,taskArtillery);

// end
true
