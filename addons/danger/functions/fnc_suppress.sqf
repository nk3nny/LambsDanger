#include "script_component.hpp"
/*
 * Author: nkenny
 * Unit performs suppressive fire on target location
 *
 * Arguments:
 * 0: Unit suppressing <OBJECT>
 * 1: Target position <ARRAY> (ASL position)
 * 2: Override target search <BOOL>
 *
 * Return Value:
 * success
 *
 * Example:
 * [bob, getposASL angryJoe, false] call lambs_danger_fnc_suppress;
 *
 * Public: No
*/
params ["_unit", "_pos",["_override", false]];

// variable
_unit setVariable [QGVAR(currentTarget), _pos];
_unit setVariable [QGVAR(currentTask), "Deliberate Fire"];

// no primary weapons exit? Player led groups do not auto-suppress
if (
    getSuppression _unit > 0.5
    || {terrainIntersect [_unit, ASLtoAGL _pos]}
    || {(primaryWeapon _unit) isEqualTo ""}
    || {(currentCommand _unit) isEqualTo "Suppress"}
    || {isPlayer (leader _unit) && {GVAR(disableAIPlayerGroupSuppression)}}
) exitWith {false};

// override
if (!_override) then {

    _pos = AGLtoASL (_unit getHideFrom (_unit findNearestEnemy _unit));
    private _vis = lineIntersectsSurfaces [eyePos _unit, _pos, _unit, vehicle _unit, true, 2];
    if (count _vis > 1) then {_pos = (_vis select 0) select 0;};
};

// mod pos
_pos = _pos vectorAdd [0, 0, 0.2 + random 1];

// final range check
if (_unit distance2d _pos < GVAR(minSuppression_range)) exitWith {false};

// do it!
_unit forceSpeed 0;
_unit doSuppressiveFire _pos;

// Suppressive fire
_unit setVariable [QGVAR(currentTask), "Suppressive Fire"];

// extend suppressive fire for machineguns
if (_unit ammo (currentWeapon _unit) > 32) then {
    _unit suppressFor (7 + random 20);
};

// debug
if (GVAR(debug_functions)) then {
    format ["%1 Suppression (%2 @ %3m)", side _unit, name _unit, round (_unit distance _pos)] call FUNC(debugLog);

    private _sphere = createSimpleObject ["Sign_Sphere100cm_F", _pos, true];
    _sphere setObjectTexture [0, [_unit] call FUNC(debugObjectColor)];
    [{deleteVehicle _this}, _sphere, 20] call cba_fnc_waitAndExecute;
};

// end
true
