#include "script_component.hpp"
/*
 * Author: nkenny
 * Unit performs suppressive fire on target location
 *
 * Arguments:
 * 0: Unit suppressing <OBJECT>
 * 1: Target position <ARRAY>
 *
 * Return Value:
 * success
 *
 * Example:
 * [bob, getpos angryJoe] call lambs_danger_fnc_suppress;
 *
 * Public: No
*/
params ["_unit", "_pos"];

// no primary weapons exit? Player led groups do not auto-suppress
if (
    getSuppression _unit > 0.5
    || {terrainIntersect [_unit, _pos]}
    || {(primaryWeapon _unit) isEqualTo ""}
    || {currentCommand _unit isEqualTo "Suppress"}
    || {isPlayer (leader _unit) && {GVAR(disableAIPlayerGroupSuppression)}}
) exitWith {false}; // possibly add a more intelligent system here -nkenny

_unit setVariable [QGVAR(currentTarget), _pos];
_unit setVariable [QGVAR(currentTask), "Suppress"];

// do it!
_unit doSuppressiveFire ((AGLToASL _pos) vectorAdd [0, 0, 0.2 + random 1.2]);

// extend suppressive fire for machineguns
if (_unit ammo (currentWeapon _unit) > 32) then {
    _unit suppressFor (3 + random 7);
};

// debug
if (GVAR(debug_functions)) then {
    systemchat format ["%1 Suppression (%2 @ %3m)", side _unit, name _unit, round (_unit distance _pos)];

    // markers
    [_pos, "SUPPRESS"] call FUNC(dotMarker);
    _sign = createVehicle ["Sign_Arrow_Green_F",_pos, [], 0, "CAN_COLLIDE"];
    _sign setPos (_pos vectorAdd [0, 0, 0.2 + random 1.2]);
};

// end
true
