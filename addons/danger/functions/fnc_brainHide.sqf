#include "script_component.hpp"
/*
 * Author: nkenny
 * handles hiding from danger!
 *
 * Arguments:
 * 0: unit doing the avaluation <OBJECT>
 * 1: type of data <NUMBER>
 * 2: position of danger<OBJECT>
 *
 * Return Value:
 * bool
 *
 * Example:
 * [bob, 0, getpos angryBob] call lambs_danger_fnc_brainHide;
 *
 * Public: No
*/

/*
    Hide actions
    0 Enemy detected (but far)
    4 Explosion
    7 Scream
*/

params ["_unit", ["_type", 0], ["_pos", [0, 0, 0]]];

// timeout
private _timeout = time + 4;

// look at problem
_unit lookAt _pos;

// indoor units exit
if (RND(0.05) && {_unit call EFUNC(main,isIndoor)}) exitWith {
    _unit forceSpeed 0;
    _timeout
};

// find nearby building
private _buildingPos = [_unit, 22, true, true] call EFUNC(main,findBuildings);
_buildingPos = _buildingPos select {_unit distance _x < ([GVAR(searchForHide), 2.5] select (_unit call EFUNC(main,isIndoor)))};

if !(_buildingPos isEqualTo []) exitWith {
    _unit doMove selectRandom _buildingPos;
    _timeout + 6
};

// find nearest cover
private _cover = nearestTerrainObjects [_unit, [], GVAR(searchForHide), true, true]; //"BUSH", "TREE", "HIDE", "WALL", "FENCE"
if !(_cover isEqualTo []) then {
    _cover = (_cover select 0) getPos [-1.3, (_cover select 0) getDir _pos];
    [_unit, _cover] call FUNC(doCover);
};

// end
_timeout
