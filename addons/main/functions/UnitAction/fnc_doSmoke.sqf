#include "script_component.hpp"
/*
 * Author: nkenny
 * Unit finds and throws smoke grenade at location
 *
 * Arguments:
 * 0: Unit  <OBJECT>, <ARRAY> or <GROUP>
 * 1: Position <ARRAY>, optional
 * 2: Type, corresponds to ai usage flags <NUMBER>, optional
 *
 * Return Value:
 * boolean
 *
 * Example:
 * [bob, getPos angryJoe] call lambs_main_fnc_doSmoke;
 *
 * Public: Yes
*/

params [
    ["_unit", objNull, [grpNull, objNull, []]],
    ["_pos", [], [[]]],
    ["_type", AI_AMMO_USAGE_FLAG_CONCEALMENT, [0]]
];

// single unit
if (_unit isEqualType []) then {_unit = selectRandom _unit;};
if (_unit isEqualType grpNull) then {_unit = leader _unit;};

// local
if (!local _unit || {isPlayer _unit}) exitWith {false};

// get magazines
private _magazines = magazinesAmmo _unit;
_magazines = _magazines select {(_x select 1) isEqualTo 1};
_magazines = _magazines apply {_x select 0};
if (_magazines isEqualTo []) exitWith {false};

// find smoke shell
private _smokeshell = _magazines findIf {
    [_x, _type] call FUNC(checkMagazineAiUsageFlags);
};

// select smoke
if (_smokeshell == -1) exitWith {false};
_smokeshell = (_magazines select _smokeshell);

// get muzzle
private _muzzle = _smokeshell call FUNC(getCompatibleThrowMuzzle);

// select muzzle
if (_muzzle isEqualTo "") exitWith {false};

_unit setVariable [QGVAR(currentTarget), objNull, GVAR(debug_functions)];
// turn towards target
if (_pos isNotEqualTo []) then {
    _unit doWatch _pos;
    _unit setVariable [QGVAR(currentTarget), _pos, GVAR(debug_functions)];
};

// variable
_unit setVariable [QGVAR(currentTask), "Throwing smoke grenade", GVAR(debug_functions)];

// execute
[BIS_fnc_fire, [_unit, _muzzle], 1] call CBA_fnc_waitAndExecute;

// end
true
