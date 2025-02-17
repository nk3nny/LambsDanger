#include "script_component.hpp"
/*
 * Author: nkenny
 * Actualises assault cycle
 *
 * Arguments:
 * 0: cycles <NUMBER>
 * 1: units list <ARRAY>
 * 2: list of building/enemy positions <ARRAY>
 *
 * Return Value:
 * bool
 *
 * Example:
 * [units bob] call lambs_main_fnc_doGroupAssault;
 *
 * Public: No
*/
params ["_cycle", "_units", "_pos"];

// update
_units = _units select {_x call FUNC(isAlive) && {!isPlayer _x} && {!fleeing _x}};
if (_units isEqualTo [] || {_pos isEqualTo []}) exitWith {
    // early reset
    {
        _x setVariable [QEGVAR(danger,forceMove), nil];
        _x doFollow (leader _x);
        _x forceSpeed -1;
    } forEach _units;
    false
};

// get targetPos
private _targetPos = _pos select 0;

// reorder positions
_pos = _pos apply {[(round (_targetPos select 2)) + (round (_x select 2)), _targetPos distanceSqr _x, _x]};
_pos sort true;
_pos = _pos apply {_x select 2};

{
    // get unit
    private _unit = _x;
    private _assaultPos = _targetPos;
    if (((_forEachIndex % 4) isEqualTo 0) && {count _pos > 1}) then {_assaultPos = _pos select 1};

    // enemy
    private _enemy = _unit findNearestEnemy _unit;
    if (alive _enemy) then {
        private _vis = [objNull, "VIEW", objNull] checkVisibility [eyePos _unit, aimPos _enemy] > 0.9;

        // can see enemy or enemy within 5 meters
        if (_vis || {_unit distanceSqr _enemy < 25}) then {
            _unit lookAt (ASLToAGL (aimPos _enemy));
            _assaultPos = getPosATL _enemy;
        };
    };

    // unit situation
    private _distance2D = _unit distance2D _assaultPos;
    private _indoor = [_unit] call FUNC(isIndoor);

    // manoeuvre
    _unit forceSpeed ([4, 2] select (_indoor || {_distance2D < 10}));
    _unit setUnitPos (["UP", "MIDDLE"] select ((getSuppression _unit) isNotEqualTo 0 || {_distance2D > 8}));
    _unit setVariable [QGVAR(currentTask), format ["Group Assault @ %1m", round _distance2D], GVAR(debug_functions)];
    _unit setVariable [QEGVAR(danger,forceMove), true];

    // modify assaultPos
    private _nearMen = _assaultPos nearEntities ["CAManBase", 1];
    if (_nearMen isNotEqualTo []) then {
        _enemy = _nearMen select 0;
        private _enemyPos = getPosASL _enemy;
        private _surface = lineIntersectsSurfaces [_enemyPos vectorAdd [0, 0, 2], _enemyPos vectorAdd [-15 + random 30, -15 + random 30, -4], _enemy, objNull, true, 1, "GEOM", "VIEW"];
        if (_surface isNotEqualTo []) then {
            _assaultPos = (ASLToAGL ((_surface select 0) select 0));
        };
    };

    // modify movement (if far)
    if (!_indoor && {_distance2D > 20}) then {
        _assaultPos = _unit getPos [20, _unit getDir _assaultPos];
    };

    // set movement
    if (
        ((expectedDestination _unit) select 0) distanceSqr _assaultPos > 1
        && {!((getUnitState _unit) in ["BUSY", "DELAY"])}
    ) then {
        _unit lookAt (_assaultPos vectorAdd [0, 0, 1]);
        _unit doMove _assaultPos;
        _unit setDestination [_assaultPos, "LEADER PLANNED", true];
    };

    // remove positions
    _pos = _pos select {[objNull, "VIEW", objNull] checkVisibility [eyePos _unit, (AGLToASL _x) vectorAdd [0, 0, 0.5]] < 0.01};

} forEach _units;

// update group variable
(group (_units select 0)) setVariable [QGVAR(groupMemory), _pos, false];

// remove  positions ~ uncommented. CheckVisibility should be sufficient. Worth testing first ~ nkenny
// _pos = _pos select {(_units select 0) distance _x > 3};
// if (RND(0.95)) then {_pos deleteAt 0;};

// recursive cyclic
if !(_cycle <= 1 || {_units isEqualTo []}) then {
    [
        {_this call FUNC(doGroupAssault)},
        [_cycle - 1, _units, _pos],
        3
    ] call CBA_fnc_waitAndExecute;
};

// end
true
