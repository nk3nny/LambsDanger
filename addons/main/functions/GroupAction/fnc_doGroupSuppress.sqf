#include "script_component.hpp"
/*
 * Author: nkenny
 * Actualisation of Suppression cycle
 *
 * Arguments:
 * 0: group conducting the suppression <GROUP>
 * 1: units list <ARRAY>
 * 2: list of group vehicles <ARRAY>
 * 3: list of building/enemy positions <ARRAY>
 *
 * Return Value:
 * success
 *
 * Example:
 * [bob, angryJoe] call lambs_main_fnc_doGroupSuppress;
 *
 * Public: No
*/
params [["_group", grpNull], ["_units", []], ["_vehicles", []], ["_posList", []]];

// exit!
if !(_group getVariable [QEGVAR(danger,isExecutingTactic), false]) exitWith {false};

// update
_units = _units select { !( _x getVariable [QEGVAR(danger,disableAI), false] ) && { _x call FUNC(isAlive) } && { !isPlayer _x } };
_vehicles = _vehicles select { canFire _x };

// get leader
private _leader = leader _group;

// infantry
[_posList, true] call CBA_fnc_shuffle;
private _index = -1;

{
    // find target
    if (_index isEqualTo -1)then {_index = [_x, _posList] call FUNC(checkVisibilityList);};

    // found good target
    if (_index isNotEqualTo -1) then {

        // suppressive fire
        _x forceSpeed 1;
        _x setUnitPosWeak "MIDDLE";
        private _suppressing = [_x, AGLToASL ((_posList select _index) vectorAdd [0, 0, random 1])] call FUNC(doSuppress);
        _x setVariable [QGVAR(currentTask), "Group Suppress", GVAR(debug_functions)];
        if (!_suppressing) then {
            _index = -1;
        };
    };

    // failed to suppress
    if (_index isEqualTo -1) then {

        // move forward
        _x forceSpeed 3;
        _x doMove (_x getPos [20, _x getDir (_posList select -1)]);
        _x setVariable [QGVAR(currentTask), "Group Suppress (Move)", GVAR(debug_functions)];

    };
} forEach (_units select {(currentCommand _x) isNotEqualTo "Suppress"});

// vehicles
{

    // find target
    if (_index isEqualTo -1)then {_index = [_x, _posList] call FUNC(checkVisibilityList);};

    // execute suppression
    if (_index isNotEqualTo -1) then {

        // vehicle suppress
        private _suppressing = [_x, (_posList select _index) vectorAdd [0, 0, random 1]] call FUNC(doVehicleSuppress);
        if (!_suppressing) then {
            _index = -1;
        };
    };

    // failed to suppress
    if (_index isEqualTo -1) then {

        private _lookPos = _posList select _index;

        // move up behind leader
        _x doWatch _lookPos;
        private _leaderPos = call {
            if ((vehicle _leader) isEqualTo (vehicle _x)) exitWith {
                _x getPos [20, _x getDir _lookPos];
            };
            _leader getPos [35 min (_x distance2D _leader), _lookPos getDir _leader]
        };

        // check for roads
        private _roads = _leaderPos nearRoads 50;
        if (_roads isNotEqualTo []) exitWith {_x doMove (ASLToAGL (getPosASL (selectRandom _roads)));};
        _x doMove _leaderPos;

    };

} forEach (_vehicles select {(currentCommand _x) isNotEqualTo "Suppress"});

// recursive cyclic
if (_units isNotEqualTo [] && { _group getVariable [QEGVAR(danger,isExecutingTactic), false] }) then {
    [
        {_this call FUNC(doGroupSuppress)},
        [_group, _units, _vehicles, _posList],
        6 + random 2
    ] call CBA_fnc_waitAndExecute;
};

// end
true
