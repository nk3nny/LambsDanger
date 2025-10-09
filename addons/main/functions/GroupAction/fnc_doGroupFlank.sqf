#include "script_component.hpp"
/*
 * Author: nkenny
 * Actualises flanking cycle
 *
 * Arguments:
 * 0: group conducting the flanking <GROUP>
 * 1: units list <ARRAY>
 * 2: list of group vehicles <ARRAY>
 * 3: list of building/enemy positions <ARRAY>
 * 4: destination <ARRAY>
 *
 * Return Value:
 * bool
 *
 * Example:
 * [units bob] call lambs_main_fnc_doGroupFlank;
 *
 * Public: No
*/
params [["_group", grpNull], ["_units", []], ["_vehicles", []], ["_posList", []], ["_overwatch", [0, 0, 0]], ["_teamAlpha", 0]];

// exit!
if !(_group getVariable [QEGVAR(danger,isExecutingTactic), false]) exitWith {false};

// update
_units = _units select { !( _x getVariable [QEGVAR(danger,disableAI), false] ) && { _x call FUNC(isAlive) } && { !isPlayer _x } };
_vehicles = _vehicles select { canFire _x };

// group has reached destination
private _leader = leader _group;
if ( _leader distance2D _overwatch < 4 ) exitWith {
    _group setVariable [QEGVAR(danger,isExecutingTactic), false];
    _group setVariable [QGVAR(groupMemory), _posList, false];
};

// leader has no friendlies within 45 meters
private _leaderAlone = ( ( _units - crew _leader) findIf { _x distanceSqr _leader < 2025 } ) isEqualTo -1;

{
    private _unit = _x;
    private _suppressed = (getSuppression _x) > 0.5;
    _unit setUnitPos (["MIDDLE", "DOWN"] select (_suppressed || {_unit isEqualTo _leader && _leaderAlone}));
    _unit setVariable [QEGVAR(danger,forceMove), !_suppressed];

    // move
    _unit doMove _overwatch;
    _unit setDestination [_overwatch, "LEADER PLANNED", false];
    _unit setVariable [QGVAR(currentTask), "Group Flank", GVAR(debug_functions)];

    // suppress
    private _posASL = AGLToASL (selectRandom _posList);
    private _eyePos = eyePos _unit;
    _posASL = _eyePos vectorAdd ((_posASL vectorDiff _eyePos) vectorMultiply 0.6);

    if (
        (_forEachIndex % 2) isEqualTo _teamAlpha
        && {!(_leaderAlone && {isNull (objectParent (effectiveCommander _leader))})}
        && {(currentCommand _unit) isNotEqualTo "Suppress"}
        && {_unit isNotEqualTo (leader _unit)}
        && {[_unit, "VIEW", objNull] checkVisibility [_eyePos, _posASL] isEqualTo 1}
    ) then {

        // shoot
        [{_this call FUNC(doSuppress)}, [_unit, _posASL vectorAdd [0, 0, random 1], false], random 2] call CBA_fnc_waitAndExecute;

    };

} forEach _units;

// reset alpha status
_teamAlpha = parseNumber (_teamAlpha isEqualTo 0);

// vehicles
_vehicles doWatch (selectRandom _posList);
[_posList, true] call CBA_fnc_shuffle;
{

    // loaded vehicles move quickly
    if (_leaderAlone || {count (crew _x) > 3} || { _x isNotEqualTo _leader && { _leader distance2D _overwatch < 35 } } ) exitWith {_vehicles doMove _overwatch;};

    // sort out vehicles
    private _index = [_x, _posList] call FUNC(checkVisibilityList);

    if (
        _index isEqualTo -1
    ) then {

        // move up behind leader
        private _leaderPos = _leader getPos [35 min (_leader distance2D _x), _overwatch getDir _leader];
        if ((vehicle _leader) isEqualTo _x) then {_leaderPos = _x getPos [35, _x getDir _overwatch]};

        // check for roads
        private _roads = _leaderPos nearRoads 50;
        if (_roads isNotEqualTo []) exitWith {_x doMove (ASLToAGL (getPosASL (selectRandom _roads)));};
        _x doMove _leaderPos;

    } else {

        // do suppressive fire
        [_x, _posList select _index] call FUNC(doVehicleSuppress);
    };
} forEach _vehicles;

// recursive cyclic
if (_units isNotEqualTo [] && { _group getVariable [QEGVAR(danger,isExecutingTactic), false] }) then {
    [
        {_this call FUNC(doGroupFlank)},
        [_group, _units, _vehicles, _posList, _overwatch, _teamAlpha],
        11 + random 8
    ] call CBA_fnc_waitAndExecute;
};

// end
true
