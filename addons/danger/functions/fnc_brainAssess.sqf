#include "script_component.hpp"
/*
 * Author: nkenny
 * handles assessment of own situation
 *
 * Arguments:
 * 0: unit doing the avaluation <OBJECT>
 * 1: type of data <NUMBER>
 * 2: known target threatening unit <OBJECT>
 *
 * Return Value:
 * number, timeout!
 *
 * Example:
 * [bob] call lambs_danger_fnc_brainAssess;
 *
 * Public: No
*/

/*
        Assess actions
        5 DeadBodyGroup
        6 DeadBody
*/

params ["_unit", ["_type", -1], ["_pos", [0, 0, 0]], ["_target", objNull]];

// timeout
private _timeout = time + 3;

// stopped units stay put   // || {currentCommand _unit isEqualTo "MOVE"}
if (stopped _unit) exitWith {
    _timeout + random 4
};

// enemy
if (isNull _target) then {
    _target = _unit findNearestEnemy _pos;
};

// check bodies ~ own group!
if (_type isEqualTo 5) exitWith {

    // find body + rearm
    private _bodies = allDeadMen findIf { (_x distance2D _pos) < 3 };
    if (_bodies != -1) then {
        _unit doMove _pos;
        _unit setVariable [QGVAR(forceMove), true];
        [
            {
                // condition
                params ["_unit", "_body"];
                (_unit distance _body < 0.7) || {!(_unit call EFUNC(main,isAlive))}
            },
            {
                // on near body
                params ["_unit", "_body"];
                if (_unit call EFUNC(main,isAlive)) then {
                    [QGVAR(OnCheckBody), [_unit, group _unit, _body]] call EFUNC(main,eventCallback);
                    _unit action ["rearm", _body];
                    _unit doFollow leader _unit;
                };
            },
            [_unit, allDeadMen select _bodies], 8,
            {
                // on timeout
                params ["_unit"];
                if (_unit call EFUNC(main,isAlive)) then {
                    _unit doFollow leader _unit;
                    _unit setVariable [QGVAR(forceMove), nil];
                };
            }
        ] call CBA_fnc_waitUntilAndExecute;
    };

    // pop smoke
    [{_this call EFUNC(main,doSmoke)}, [_unit, _pos], random 2] call CBA_fnc_waitAndExecute;

    _unit setVariable [QGVAR(currentTarget), _pos, EGVAR(main,debug_functions)];
    _unit setVariable [QGVAR(currentTask), "Checking bodies", EGVAR(main,debug_functions)];

    // end
    _timeout + 3
};

// check bodies ~ enemy group!
private _group = group _unit;
private _groupMemory = _group getVariable [QGVAR(CQB_pos), []];
if (_type isEqualTo 6) exitWith {

    // suppress nearby enemies
    if (!isNull _target) then {
        _unit forceSpeed 1;
        [{_this call FUNC(doSuppress)}, [_unit, eyePos _target], random 2] call CBA_fnc_waitAndExecute;
    };

    // add body to move routine
    _groupMemory pushBack _pos;
    _group setVariable [QGVAR(CQB_pos), _groupMemory, false];

    _unit setVariable [QGVAR(currentTarget), _pos, EGVAR(main,debug_functions)];
    _unit setVariable [QGVAR(currentTask), "Checking bodies (unknown)", EGVAR(main,debug_functions)];

    // end
    _timeout + 3

};

// Sympathetic CQB/Suppressive fire
if !(_groupMemory isEqualTo [] || {currentCommand _unit isEqualTo "MOVE"}) exitWith {

    private _pos = _groupMemory select 0;
    private _distance = _unit distance2D _pos;

    // CQB or suppress
    if (RND(0.9) || {_distance < (GVAR(CQB_range) * 1.1)}) then {

        // CQB movement mode
        _unit setUnitPosWeak selectRandom ["UP", "UP", "MIDDLE"];
        _unit forceSpeed ([_unit, _pos] call FUNC(assaultSpeed));

        // execute CQB move
        _unit doMove _pos;

        // variables
        _unit setVariable [QGVAR(currentTarget), _pos, EGVAR(main,debug_functions)];
        _unit setVariable [QGVAR(currentTask), "Assault (Sympathetic)", EGVAR(main,debug_functions)];

    } else {

        // execute suppression
        _unit setUnitPosWeak "MIDDLE";
        _unit forceSpeed ([1, -1] select (getSuppression _unit > 0.8));
        [_unit, (AGLToASL _pos) vectorAdd [0, 0, 1.2], true] call FUNC(doSuppress);
        _unit setVariable [QGVAR(currentTarget), _pos, EGVAR(main,debug_functions)];
        _unit setVariable [QGVAR(currentTask), "Suppress (Sympathetic)!", EGVAR(main,debug_functions)];
    };

    // add to variable
    if (!isNull _target && {_target call EFUNC(main,isAlive)} && {_unit distance2D _target < _distance}) then {
        _groupMemory pushBack (getPosATL _target);
    };

    // update variable
    if (_distance < 2) then {_groupMemory deleteAt 0;};
    _group setVariable [QGVAR(CQB_pos), _groupMemory, false];

    _timeout + 6

};

// check self
private _indoor = _unit call EFUNC(main,isIndoor);

// cover
//_unit forceSpeed ([2, 4] select (getSuppression _unit > 0));

//private _cover = nearestTerrainObjects [_unit, [], GVAR(searchForHide), false, true];
/*
private _cover = nearestTerrainObjects [_unit, [], 3, false, true];
if !(_cover isEqualTo [] || _indoor) exitWith {

    //move into cover
    _unit forceSpeed ([2, -1] select (getSuppression _unit > 0.8));
    //[_unit, getPos (_cover select 0)] call FUNC(doCover);

    // end
    _timeout
};*/

// building
if (_indoor && {RND(GVAR(indoorMove)/100)}) exitWith {

    // get building positions
    private _buildingPos = [_unit, 21, true, true] call EFUNC(main,findBuildings);
    [_buildingPos, true] call CBA_fnc_shuffle;

    // Check if there is a closer building position
    private _distance = _unit distance2D _target;
    private _destination = _buildingPos findIf {_x distance2D _target < _distance};
    if (_destination != -1) then {
        _unit doMove ((_buildingPos select _destination) vectorAdd [-1 + random 2, -1 + random 2, 0]);
        _unit forceSpeed ([_unit, _buildingPos select _destination] call FUNC(assaultSpeed));
        _unit setVariable [QGVAR(currentTarget), _buildingPos select _destination, EGVAR(main,debug_functions)];
        _unit setVariable [QGVAR(currentTask), "Repositioning", EGVAR(main,debug_functions)];
    } else {
        // stay indoors
        _unit setVariable [QGVAR(currentTask), "Stay inside (assessing)", EGVAR(main,debug_functions)];
    };

    // end
    _timeout + 5
};

// end
_timeout
