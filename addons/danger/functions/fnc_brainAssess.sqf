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
private _timeout = time + 4;

// enemy
if (isNull _target) then {

    _target = _unit findNearestEnemy _pos;

};

// check bodies ~ own group!
if (_type isEqualTo 5) exitWith {

    // find body + rearm
    private _bodies = allDeadMen select { (_x distance2D _pos) < 3 };
    if !(_bodies isEqualTo []) then {
        _unit action ["rearm", _bodies select 0];
    };

    // pop smoke
    [EFUNC(main,doSmoke), [_unit, _pos], random 2] call CBA_fnc_waitAndExecute;

    // end
    _timeout + 2
};

// check bodies ~ enemy group!
private _groupVariable = group _unit getVariable [QGVAR(CQB_pos), []];
if (_type isEqualTo 6) exitWith {

    // suppress nearby enemies
    if (!isNull _target) then {
        [FUNC(doSuppress), [_unit, eyePos _target], random 2] call CBA_fnc_waitAndExecute;
    };

    // add body to move routine
    _groupVariable pushBack _pos;
    group _unit setVariable [QGVAR(CQB_pos), _groupVariable, false];

    // end
    _timeout + 2

};

// Sympathetic CQB/Suppressive fire
if !(_groupVariable isEqualTo []) exitWith {

    _pos = [_groupVariable select 0, _groupVariable deleteAt 0] select (_unit distance2D _pos < 10);

    // CQB or suppress
    if (RND(0.9) || {_unit distance2D _pos < (GVAR(CQB_range) * 1.1)}) then {
        
        // CQB movement mode
        _unit setUnitPosWeak selectRandom ["UP", "UP", "MIDDLE"];
        _unit forceSpeed ([_unit, _target] call FUNC(assaultSpeed));

        // execute CQB move
        _unit doWatch objNull;
        _unit doMove _pos;
        
        // variables
        _unit setVariable [QGVAR(currentTarget), _pos, EGVAR(main,debug_functions)];
        _unit setVariable [QGVAR(currentTask), "Assault (Sympathetic)", EGVAR(main,debug_functions)];

    } else {

        // execute suppression
        _unit setUnitPosWeak "MIDDLE";
        [_unit, (AGLToASL _pos) vectorAdd [0, 0, 1.2], true] call FUNC(doSuppress);
        _unit setVariable [QGVAR(currentTarget), _pos, EGVAR(main,debug_functions)];
        _unit setVariable [QGVAR(currentTask), "Suppress (Sympathetic)!", EGVAR(main,debug_functions)];
    };

    // update variable
    group _unit setVariable [QGVAR(CQB_pos), _groupVariable, false];

    _timeout + 6

};

// check self
private _indoor = _unit call EFUNC(main,isIndoor);

// cover
private _cover = nearestTerrainObjects [_unit, [], GVAR(searchForHide), false, true];
if !(_cover isEqualTo [] || _indoor) exitWith {

    //move into cover
    [_unit, getPos (_cover select 0)] call FUNC(doCover);

    // end
    _timeout + 4
};

// building
if (_indoor && {random 100 < GVAR(indoorMove)}) exitWith {

    // get building pos
    private _buildingPos = [_unit, 21, true, true] call EFUNC(main,findBuildings);

    // destination
    private _distance = _unit distance2D _target;
    private _destination = _buildingPos findIf {_x distance2D _target < _distance};
    if (_destination != -1) then {
        _unit doMove (_buildingPos select _destination);
        _unit setVariable [QGVAR(currentTarget), _buildingPos select _destination, EGVAR(main,debug_functions)];
        _unit setVariable [QGVAR(currentTask), "Repositioning", EGVAR(main,debug_functions)];
    };

    // end
    _timeout + 2
};

// end
_timeout
