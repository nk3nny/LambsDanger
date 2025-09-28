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

{
    private _suppressed = (getSuppression _x) > 0.5;
    _x setUnitPos (["MIDDLE", "DOWN"] select _suppressed);

    // move
    _x doMove (_overwatch vectorAdd [-2 + random 4, -2 + random 4, 0]);
    _x setDestination [_overwatch, "LEADER PLANNED", true];
    _x setVariable [QEGVAR(danger,forceMove), !_suppressed];
    _x setVariable [QGVAR(currentTask), "Group Flank", GVAR(debug_functions)];

    // suppress
    private _posASL = AGLToASL (selectRandom _posList);
    private _eyePos = eyePos _x;
    _posASL = _eyePos vectorAdd ((_posASL vectorDiff _eyePos) vectorMultiply 0.6);

    if (
        (_forEachIndex % 2) isEqualTo _teamAlpha
        && {_x isNotEqualTo (leader _x)}
        && {[_x, "VIEW", objNull] checkVisibility [_eyePos, _posASL] isEqualTo 1}
    ) then {
        [{_this call FUNC(doSuppress)}, [_x, _posASL vectorAdd [0, 0, random 1], true], random 1] call CBA_fnc_waitAndExecute;
    };
} forEach _units;

// reset alpha status
_teamAlpha = parseNumber (_teamAlpha isEqualTo 0);

// vehicles
_vehicles doWatch (selectRandom _posList);
{

    // sort out vehicles
    [_posList, true] call CBA_fnc_shuffle;
    private _index = [_x, _posList] call FUNC(checkVisibilityList);

    if (_index isEqualTo -1) then {

        // loaded vehicles move quickly
        if (count crew _x > 3) exitWith {_x doMove _overwatch;};

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
}
forEach (_vehicles select {(currentCommand _x) isNotEqualTo "Suppress"});

// recursive cyclic
if (_units isNotEqualTo [] && { _group getVariable [QEGVAR(danger,isExecutingTactic), false] }) then {
    [
        {_this call FUNC(doGroupFlank)},
        [_group, _units, _vehicles, _posList, _overwatch, _teamAlpha],
        10 + random 8
    ] call CBA_fnc_waitAndExecute;
};

// end
true
