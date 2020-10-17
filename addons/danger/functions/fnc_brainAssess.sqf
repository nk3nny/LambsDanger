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

    // check body
    [_unit, _pos] call FUNC(doCheckBody);

    // pop smoke
    [{_this call EFUNC(main,doSmoke)}, [_unit, _pos], random 2] call CBA_fnc_waitAndExecute;

    // end
    _timeout + 3
};

// check bodies ~ enemy group!
private _group = group _unit;
private _groupMemory = _group getVariable [QGVAR(groupMemory), []];
if (_type isEqualTo 6) exitWith {

    // communicate danger!
    [{_this call FUNC(shareInformation)}, [_unit, objNull, GVAR(radioShout), true], 2 + random 3] call CBA_fnc_waitAndExecute;

    // add body to move routine
    _groupMemory pushBack _pos;
    _group setVariable [QGVAR(groupMemory), _groupMemory, false];

    _unit setVariable [QGVAR(currentTarget), _pos, EGVAR(main,debug_functions)];
    _unit setVariable [QGVAR(currentTask), "Checking bodies (unknown)", EGVAR(main,debug_functions)];

    // end
    _timeout + 3
};

// Sympathetic CQB/Suppressive fire
if !(_groupMemory isEqualTo []) exitWith {
    [_unit, _groupMemory] call FUNC(doAssaultMemory);
    _timeout + 6
};

// check self
private _indoor = _unit call EFUNC(main,isIndoor);

// speed adjustment
if (!isFormationLeader _unit) then {
    _unit forceSpeed ([_unit, formLeader _unit] call FUNC(assaultSpeed));
};

// cover
if (!_indoor && {speed _unit < 1}) exitWith {

    //move into cover
    [_unit] call FUNC(doCover);

    // end
    _timeout
};

// building
if (_indoor && {RND(GVAR(indoorMove))}) exitWith {

    // get building positions
    private _buildingPos = [_unit, 21, true, true, true] call EFUNC(main,findBuildings);
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
